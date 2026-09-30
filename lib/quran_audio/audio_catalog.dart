import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// One surah's metadata. No ayah text, no audio URLs — those are derived.
class SurahMeta {
  final int number;
  final String name; // Arabic
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  /// Global number (1..6236) of this surah's first ayah. Every audio URL on
  /// the CDN is keyed by that number, so this is all we need to build them.
  final int firstAyahNumber;

  const SurahMeta({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
    required this.firstAyahNumber,
  });

  bool get isMakki => revelationType.toLowerCase().startsWith('mecc');

  int ayahNumberAt(int indexInSurah) => firstAyahNumber + indexInSurah;

  Map<String, dynamic> toJson() => {
    'number': number,
    'name': name,
    'englishName': englishName,
    'englishNameTranslation': englishNameTranslation,
    'numberOfAyahs': numberOfAyahs,
    'revelationType': revelationType,
  };
}

/// Surah metadata and audio URLs for the recitation player.
///
/// The old screen fetched `/v1/quran/{reciter}` — the WHOLE Quran, all 6,236
/// ayahs with their text and audio links, several megabytes — every single
/// time the Audio tab was opened, and again on every reciter change, with no
/// cache at all. It did that to show a list of 114 surah names.
///
/// This fetches `/v1/surah` instead: 114 rows, about 15 KB, cached forever.
/// Audio URLs are then built directly, because the CDN keys them by the
/// global ayah number:
///   https://cdn.islamic.network/quran/audio/{bitrate}/{edition}/{n}.mp3
/// So changing reciter now costs nothing at all.
class AudioCatalog {
  AudioCatalog._();
  static final AudioCatalog instance = AudioCatalog._();

  static const _cacheKey = 'audio_surah_meta_v1';
  static const _endpoint = 'https://api.alquran.cloud/v1/surah';
  static const _cdn = 'https://cdn.islamic.network/quran/audio';

  List<SurahMeta>? _surahs;
  Future<List<SurahMeta>>? _inFlight;

  List<SurahMeta>? get cached => _surahs;

  Future<List<SurahMeta>> load({bool forceRefresh = false}) {
    if (!forceRefresh && _surahs != null) return Future.value(_surahs!);
    return _inFlight ??= _load(
      forceRefresh,
    ).whenComplete(() => _inFlight = null);
  }

  Future<List<SurahMeta>> _load(bool forceRefresh) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        try {
          final parsed = _parse(json.decode(raw) as List);
          if (parsed.length == 114) {
            _surahs = parsed;
            return parsed;
          }
        } catch (_) {
          await prefs.remove(_cacheKey);
        }
      }
    }

    final res = await http
        .get(Uri.parse(_endpoint))
        .timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) {
      throw Exception('Could not load the surah list (${res.statusCode}).');
    }
    final list = json.decode(res.body)['data'] as List;
    final parsed = _parse(list);
    if (parsed.length != 114) {
      throw Exception('The surah list came back incomplete.');
    }

    await prefs.setString(
      _cacheKey,
      json.encode(parsed.map((e) => e.toJson()).toList()),
    );
    _surahs = parsed;
    return parsed;
  }

  /// Runs the cumulative ayah count as it parses, which is what turns a
  /// surah and an index into a CDN URL.
  List<SurahMeta> _parse(List raw) {
    final out = <SurahMeta>[];
    var running = 1;

    for (final e in raw) {
      final m = Map<String, dynamic>.from(e as Map);
      final count = (m['numberOfAyahs'] as num?)?.toInt() ?? 0;
      out.add(
        SurahMeta(
          number: (m['number'] as num?)?.toInt() ?? 0,
          name: (m['name'] ?? '').toString(),
          englishName: (m['englishName'] ?? '').toString(),
          englishNameTranslation: (m['englishNameTranslation'] ?? '')
              .toString(),
          numberOfAyahs: count,
          revelationType: (m['revelationType'] ?? '').toString(),
          firstAyahNumber: running,
        ),
      );
      running += count;
    }

    // 6236 ayahs plus the 1 we started from. A cheap, decisive check that
    // the list is whole before anything builds URLs from it.
    assert(
      running == 6237,
      'Expected 6236 ayahs in total, counted ${running - 1}',
    );
    return out;
  }

  /// The bitrates the CDN actually publishes for each edition, highest
  /// first. Most editions are not at 128 kbps at all, and asking for a
  /// bitrate that is not there is a 404. Checked against the CDN 2026-09-29.
  static const Map<String, List<int>> bitrates = {
    'ar.alafasy': [128, 64],
    'ar.abdulbasitmurattal': [192, 64],
    'ar.abdurrahmaansudais': [192, 64],
    'ar.abdullahbasfar': [192, 64, 32],
    'ar.abdulsamad': [64],
    'ar.shaatree': [128, 64],
    'ar.ahmedajamy': [128, 64],
    'ar.hanirifai': [192, 64],
    'ar.husary': [128, 64],
    'ar.husarymujawwad': [128, 64],
    'ar.hudhaify': [128, 64, 32],
    'ar.ibrahimakhbar': [32],
    'ar.mahermuaiqly': [128, 64],
    'ar.minshawi': [128],
    'ar.minshawimujawwad': [64],
    'ar.muhammadayyoub': [128],
    'ar.muhammadjibreel': [128],
    'ar.saoodshuraym': [64],
    'ar.parhizgar': [48],
    'ar.aymanswoaid': [64],
    'en.walk': [192],
    'fa.hedayatfarfooladvand': [40],
    'zh.chinese': [128],
    'fr.leclerc': [128],
    'ru.kuliev-audio': [128],
  };

  /// The bitrate to request for [edition]: the best one it has, or with
  /// [dataSaver] the smallest.
  static int bitrateFor(String edition, {bool dataSaver = false}) {
    final available = bitrates[edition] ?? const [128];
    return dataSaver ? available.last : available.first;
  }

  /// The audio file for one ayah, by its global number (1..6236).
  static String urlFor({
    required int ayahNumber,
    required String edition,
    bool dataSaver = false,
  }) =>
      '$_cdn/${bitrateFor(edition, dataSaver: dataSaver)}/$edition/$ayahNumber.mp3';

  /// The audio file for one ayah of a surah.
  /// [indexInSurah] is zero-based.
  String ayahUrl({
    required SurahMeta surah,
    required int indexInSurah,
    required String edition,
    bool dataSaver = false,
  }) => urlFor(
    ayahNumber: surah.ayahNumberAt(indexInSurah),
    edition: edition,
    dataSaver: dataSaver,
  );

  /// Every ayah of a surah, in order.
  List<String> surahUrls({
    required SurahMeta surah,
    required String edition,
    bool dataSaver = false,
  }) => List.generate(
    surah.numberOfAyahs,
    (i) => ayahUrl(
      surah: surah,
      indexInSurah: i,
      edition: edition,
      dataSaver: dataSaver,
    ),
  );

  SurahMeta? byNumber(int number) {
    final list = _surahs;
    if (list == null) return null;
    for (final s in list) {
      if (s.number == number) return s;
    }
    return null;
  }
}
