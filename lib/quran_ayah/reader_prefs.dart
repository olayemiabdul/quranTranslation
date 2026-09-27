import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Reading settings, bookmarks and the translation cache for the Easy Read
/// reader. Everything is stored locally, so the reader works offline once a
/// surah has been opened.
class ReaderPrefs extends ChangeNotifier {
  ReaderPrefs._();
  static final ReaderPrefs instance = ReaderPrefs._();

  static const _kFontSize = 'reader_font_size';
  static const _kLineHeight = 'reader_line_height';
  static const _kShowTranslation = 'reader_show_translation';
  static const _kTranslationEdition = 'reader_translation_edition';
  static const _kReciter = 'reader_reciter';
  static const _kLastPage = 'reader_last_page';
  static const _kBookmarks = 'reader_bookmarks';
  static const _kDefaultMode = 'reader_default_mode'; // 'mushaf' | 'easy'

  double fontSize = 24;
  double lineHeight = 2.1;
  bool showTranslation = false;
  String translationEdition = 'en.sahih';
  String reciter = 'ar.alafasy';
  int lastPage = 1;

  /// Bookmarked ayahs, as "surah:ayah".
  Set<String> bookmarks = <String>{};

  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final p = await SharedPreferences.getInstance();
    fontSize = p.getDouble(_kFontSize) ?? 24;
    lineHeight = p.getDouble(_kLineHeight) ?? 2.1;
    showTranslation = p.getBool(_kShowTranslation) ?? false;
    translationEdition = p.getString(_kTranslationEdition) ?? 'en.sahih';
    reciter = p.getString(_kReciter) ?? 'ar.alafasy';
    lastPage = p.getInt(_kLastPage) ?? 1;
    bookmarks = (p.getStringList(_kBookmarks) ?? const []).toSet();
    _loaded = true;
    notifyListeners();
  }

  Future<void> setFontSize(double v) async {
    fontSize = v.clamp(16, 44);
    notifyListeners();
    (await SharedPreferences.getInstance()).setDouble(_kFontSize, fontSize);
  }

  Future<void> setLineHeight(double v) async {
    lineHeight = v.clamp(1.6, 3.0);
    notifyListeners();
    (await SharedPreferences.getInstance()).setDouble(_kLineHeight, lineHeight);
  }

  Future<void> setShowTranslation(bool v) async {
    showTranslation = v;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool(_kShowTranslation, v);
  }

  Future<void> setTranslationEdition(String v) async {
    translationEdition = v;
    notifyListeners();
    (await SharedPreferences.getInstance()).setString(_kTranslationEdition, v);
  }

  Future<void> setReciter(String v) async {
    reciter = v;
    notifyListeners();
    (await SharedPreferences.getInstance()).setString(_kReciter, v);
  }

  /// Called as the reader is swiped. Deliberately does not notify: it would
  /// rebuild the page on every swipe for no visible gain.
  Future<void> setLastPage(int page) async {
    lastPage = page;
    (await SharedPreferences.getInstance()).setInt(_kLastPage, page);
  }

  bool isBookmarked(String key) => bookmarks.contains(key);

  Future<void> toggleBookmark(String key) async {
    bookmarks.contains(key) ? bookmarks.remove(key) : bookmarks.add(key);
    notifyListeners();
    (await SharedPreferences.getInstance())
        .setStringList(_kBookmarks, bookmarks.toList()..sort());
  }

  Future<String?> defaultMode() async =>
      (await SharedPreferences.getInstance()).getString(_kDefaultMode);

  Future<void> setDefaultMode(String? mode) async {
    final p = await SharedPreferences.getInstance();
    mode == null ? await p.remove(_kDefaultMode) : await p.setString(_kDefaultMode, mode);
  }
}

/// Fetches and caches translations one surah at a time, so opening a page
/// costs at most two or three small requests and nothing after that.
class TranslationStore {
  TranslationStore._();
  static final TranslationStore instance = TranslationStore._();

  final Map<String, Map<int, String>> _memory = {};

  String _key(String edition, int surah) => 'tr_${edition}_$surah';

  /// ayah number in surah -> translated text. Empty map when unavailable.
  Future<Map<int, String>> forSurah(int surah, String edition) async {
    final memKey = _key(edition, surah);
    final cached = _memory[memKey];
    if (cached != null) return cached;

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(memKey);
    if (stored != null) {
      final map = _decode(stored);
      _memory[memKey] = map;
      return map;
    }

    try {
      final res = await http
          .get(Uri.parse('https://api.alquran.cloud/v1/surah/$surah/$edition'))
          .timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) return const {};
      final ayahs = json.decode(res.body)['data']['ayahs'] as List;
      final map = <int, String>{
        for (final a in ayahs) (a['numberInSurah'] as int): (a['text'] ?? '').toString(),
      };
      _memory[memKey] = map;
      await prefs.setString(
          memKey, json.encode(map.map((k, v) => MapEntry(k.toString(), v))));
      return map;
    } catch (_) {
      return const {};
    }
  }

  Map<int, String> _decode(String raw) {
    final decoded = json.decode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(int.parse(k), v.toString()));
  }

  /// A single ayah, used by the tap-an-ayah sheet.
  Future<String?> forAyah(int surah, int ayah, String edition) async {
    final map = await forSurah(surah, edition);
    return map[ayah];
  }
}
