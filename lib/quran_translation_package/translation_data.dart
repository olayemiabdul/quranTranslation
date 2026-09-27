import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../enum/translator_list_enum.dart';
import 'translations_model_class.dart';

/// An edition the Translation reader offers in its picker.
class TranslationEdition {
  final String label;
  final String code;
  const TranslationEdition(this.label, this.code);

  /// Offered here but not in the shared [TranslatorName] enum, which also
  /// feeds the Mushaf and Easy Read verse sheets. Urdu is what lets this one
  /// reader cover what the separate Urdu reader does.
  static const _extra = [
    TranslationEdition('Ahmed Ali (Urdu)', 'ur.ahmedali'),
    TranslationEdition('Fateh Muhammad Jalandhry (Urdu)', 'ur.jalandhry'),
  ];

  /// Every edition, each code once (the enum lists `ru.porokhova` twice).
  static final List<TranslationEdition> all = () {
    final seen = <String>{};
    return [
      for (final t in TranslatorName.values)
        if (seen.add(t.text)) TranslationEdition(t.label.trim(), t.text),
      for (final e in _extra)
        if (seen.add(e.code)) e,
    ];
  }();

  static String labelFor(String code) {
    for (final e in all) {
      if (e.code == code) return e.label;
    }
    return code;
  }
}

/// Downloads, caches and parses a whole translation edition.
///
/// What this replaces:
///  * the old screen cached only the default edition, under one key, so every
///    time the reader switched translator it re-downloaded several megabytes
///    and threw the result away on the next visit;
///  * the download reported nothing, which on a slow connection looked like a
///    frozen spinner;
///  * the reader's chosen translator was never remembered.
class TranslationData {
  TranslationData._();
  static final TranslationData instance = TranslationData._();

  static const String defaultEdition = 'en.sahih';
  static const int totalPages = 604;

  /// Editions whose script runs right to left. The old app shipped a whole
  /// duplicate reader for Urdu because this reader assumed left to right;
  /// handling it here means one reader serves every language.
  static const Set<String> _rtlLanguages = {
    'ar', 'ur', 'fa', 'ps', 'sd', 'he', 'ug', 'dv', 'ku', 'yi',
  };

  /// True for an edition identifier such as `ur.jalandhry` or `fa.makarem`.
  static bool isRtl(String edition) {
    final code = edition.split('.').first.toLowerCase();
    return _rtlLanguages.contains(code);
  }

  static String _cacheKey(String edition) => 'translation_$edition';
  static const _downloadedKey = 'translation_downloaded_editions';
  static const _legacyKey = 'translationData';

  final Map<String, List<TranslationSurahClass>> _memory = {};
  final Map<String, Future<List<TranslationSurahClass>>> _inFlight = {};

  List<TranslationSurahClass>? cached(String edition) => _memory[edition];

  /// Editions already on the device, so the picker can mark them offline.
  Future<Set<String>> downloadedEditions() async =>
      ((await SharedPreferences.getInstance()).getStringList(_downloadedKey) ??
              const <String>[])
          .toSet();

  /// Memory, then disk, then the network. [onProgress] reports 0..1 during a
  /// network download only.
  Future<List<TranslationSurahClass>> load(
    String edition, {
    ValueChanged<double>? onProgress,
    bool forceRefresh = false,
  }) {
    if (!forceRefresh && _memory[edition] != null) {
      return Future.value(_memory[edition]!);
    }
    return _inFlight[edition] ??= _load(edition, onProgress, forceRefresh)
        .whenComplete(() => _inFlight.remove(edition));
  }

  Future<List<TranslationSurahClass>> _load(
    String edition,
    ValueChanged<double>? onProgress,
    bool forceRefresh,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _cacheKey(edition);

    // The old reader's single cache. Nothing reads it any more, and
    // SharedPreferences loads every key into memory at startup.
    if (prefs.containsKey(_legacyKey)) await prefs.remove(_legacyKey);

    if (!forceRefresh) {
      final raw = prefs.getString(key);
      if (raw != null) {
        try {
          final parsed = _parse(json.decode(raw));
          if (parsed.length == 114) {
            _memory[edition] = parsed;
            return parsed;
          }
        } catch (_) {
          await prefs.remove(key); // corrupt cache: fetch it again
        }
      }
    }

    final body = await _download(edition, onProgress);
    final decoded = json.decode(body);
    final parsed = _parse(decoded);
    if (parsed.length != 114) {
      throw Exception('That translation came back incomplete. Try again.');
    }

    await prefs.setString(key, body);
    final done = (prefs.getStringList(_downloadedKey) ?? <String>[]).toSet()
      ..add(edition);
    await prefs.setStringList(_downloadedKey, done.toList()..sort());

    _memory[edition] = parsed;
    return parsed;
  }

  /// Streamed so the UI can show real progress instead of a spinner that
  /// looks stuck on a slow connection.
  Future<String> _download(String edition, ValueChanged<double>? onProgress) async {
    final client = http.Client();
    try {
      final res = await client
          .send(http.Request(
              'GET', Uri.parse('https://api.alquran.cloud/v1/quran/$edition')))
          .timeout(const Duration(seconds: 60));

      if (res.statusCode != 200) {
        throw Exception('Could not load that translation (${res.statusCode}).');
      }

      final total = res.contentLength ?? 0;
      final bytes = <int>[];
      await for (final chunk in res.stream) {
        bytes.addAll(chunk);
        if (total > 0) onProgress?.call((bytes.length / total).clamp(0, 1));
      }
      onProgress?.call(1);
      return utf8.decode(bytes);
    } finally {
      client.close();
    }
  }

  /// Parses a decoded `/v1/quran/{edition}` response. Exposed for tests.
  @visibleForTesting
  List<TranslationSurahClass> parse(dynamic decoded) => _parse(decoded);

  List<TranslationSurahClass> _parse(dynamic decoded) {
    final surahs = (decoded['data']['surahs'] as List)
        .map((e) => TranslationSurahClass.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return _liftBasmala(surahs);
  }

  /// Gives every surah except Al-Fatiha (where the Basmala is ayah 1) and
  /// At-Tawbah (which has none) the edition's own Basmala as a heading.
  ///
  /// Some texts also glue the Basmala onto the FRONT of ayah 1. We can't
  /// regex that, because it is written differently in every language, so we
  /// take the edition's own Al-Fatiha 1:1 as the reference and strip exactly
  /// that prefix. If the prefix does not match cleanly we strip nothing,
  /// which is the safe outcome: the text stays exactly as the edition wrote
  /// it.
  List<TranslationSurahClass> _liftBasmala(List<TranslationSurahClass> surahs) {
    if (surahs.isEmpty || surahs.first.ayahsEA.isEmpty) return surahs;

    final reference = surahs.first.ayahsEA.first.text;
    final normalizedRef = _normalize(reference);
    if (normalizedRef.length < 8) return surahs;

    return surahs.map((surah) {
      if (surah.number == 1 || surah.number == 9) return surah;
      if (surah.ayahsEA.isEmpty) return surah;

      // Every surah but these two opens with the Basmala, whether or not the
      // edition wrote it into ayah 1. Checked against the live API: none of
      // en.sahih, en.ahmedali, en.yusufali, ur.ahmedali, ur.jalandhry,
      // fr.hamidullah, fa.ayati or id.indonesian glue it on, so without this
      // the heading would never appear.
      final first = surah.ayahsEA.first;
      final remainder = _stripPrefix(first.text, normalizedRef);
      if (remainder == null) return surah.copyWith(bismillah: reference);

      final ayahs = List<AyahTranslation>.from(surah.ayahsEA);
      ayahs[0] = first.copyWith(text: remainder);
      return surah.copyWith(ayahsEA: ayahs, bismillah: reference);
    }).toList();
  }

  String _normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  /// Returns what is left of [original] after the normalized [normRef]
  /// prefix, or null when it does not start with it (or stripping would
  /// leave nothing, which would silently delete an ayah).
  String? _stripPrefix(String original, String normRef) {
    final buffer = StringBuffer();
    var previousWasSpace = false;

    for (var i = 0; i < original.length; i++) {
      final ch = original[i];
      if (ch.trim().isEmpty) {
        if (buffer.isEmpty || previousWasSpace) continue;
        buffer.write(' ');
        previousWasSpace = true;
      } else {
        buffer.write(ch.toLowerCase());
        previousWasSpace = false;
      }

      final soFar = buffer.toString().trimRight();
      if (soFar.length < normRef.length) continue;
      if (soFar != normRef) return null;

      final rest = original.substring(i + 1).trim();
      return rest.isEmpty ? null : rest;
    }
    return null;
  }

  /// Simple case-insensitive search across an edition. Returns at most
  /// [limit] ayahs, in order.
  List<AyahTranslation> search(
    List<TranslationSurahClass> surahs,
    String query, {
    int limit = 300,
  }) {
    final q = query.trim().toLowerCase();
    if (q.length < 2) return const [];

    final hits = <AyahTranslation>[];
    for (final surah in surahs) {
      for (final ayah in surah.ayahsEA) {
        if (ayah.text.toLowerCase().contains(q)) {
          hits.add(ayah);
          if (hits.length >= limit) return hits;
        }
      }
    }
    return hits;
  }
}
