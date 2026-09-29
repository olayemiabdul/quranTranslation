import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'surah_class.dart';

/// Loads the full Arabic Quran once and keeps it in memory for the session.
///
/// The surah list screen used to hold this logic privately, so anything else
/// that needed the text had to fetch it again. Both readers and the
/// "continue reading" tile now share this single loader and its cache.
class QuranData {
  QuranData._();
  static final QuranData instance = QuranData._();

  static const _cacheKey = 'surahs';
  static const _endpoint = 'https://api.alquran.cloud/v1/quran/quran-uthmani';

  List<Surah>? _surahs;
  Future<List<Surah>>? _inFlight;

  List<Surah>? get cached => _surahs;

  /// Whether the Quran is saved on this device, without loading it.
  static Future<bool> isOnDevice() async =>
      (await SharedPreferences.getInstance()).containsKey(_cacheKey);

  /// Returns the 114 surahs, from memory, then disk, then the network.
  /// Throws only when there is nothing cached and the network fails.
  Future<List<Surah>> load({bool forceRefresh = false}) {
    if (!forceRefresh && _surahs != null) return Future.value(_surahs!);
    return _inFlight ??= _load(forceRefresh).whenComplete(() => _inFlight = null);
  }

  Future<List<Surah>> _load(bool forceRefresh) async {
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
          await prefs.remove(_cacheKey); // corrupt cache, fetch again
        }
      }
    }

    final res =
        await http.get(Uri.parse(_endpoint)).timeout(const Duration(seconds: 40));
    if (res.statusCode != 200) {
      throw Exception('Could not load the Quran (${res.statusCode}).');
    }
    final list = json.decode(res.body)['data']['surahs'] as List;
    await prefs.setString(_cacheKey, json.encode(list));
    _surahs = _parse(list);
    return _surahs!;
  }

  List<Surah> _parse(List raw) => raw
      .map((e) => Surah.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(growable: false);

  /// The Mushaf page a surah begins on.
  int pageOf(int surahNumber) {
    final s = _surahs;
    if (s == null) return 1;
    for (final surah in s) {
      if (surah.number == surahNumber && surah.ayahs.isNotEmpty) {
        return surah.ayahs.first.page;
      }
    }
    return 1;
  }
}
