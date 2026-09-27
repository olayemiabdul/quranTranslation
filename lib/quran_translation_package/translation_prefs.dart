import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'translation_data.dart';

/// Reading settings for the Translation reader, kept separate from the
/// Arabic readers: translated prose wants a different size and measure from
/// Uthmani script, so sharing one slider between them helps nobody.
class TranslationPrefs extends ChangeNotifier {
  TranslationPrefs._();
  static final TranslationPrefs instance = TranslationPrefs._();

  static const _kEdition = 'tr_edition';
  static const _kFontSize = 'tr_font_size';
  static const _kLineHeight = 'tr_line_height';
  static const _kLastPage = 'tr_last_page';
  static const _kBookmarks = 'tr_bookmarks';
  static const _kSerif = 'tr_serif';
  static const _kShowVerseNumbers = 'tr_verse_numbers';

  String edition = TranslationData.defaultEdition;
  double fontSize = 18;
  double lineHeight = 1.7;
  bool serif = true;
  bool showVerseNumbers = true;
  int lastPage = 1;
  Set<String> bookmarks = <String>{};

  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final p = await SharedPreferences.getInstance();
    edition = p.getString(_kEdition) ?? TranslationData.defaultEdition;
    fontSize = p.getDouble(_kFontSize) ?? 18;
    lineHeight = p.getDouble(_kLineHeight) ?? 1.7;
    serif = p.getBool(_kSerif) ?? true;
    showVerseNumbers = p.getBool(_kShowVerseNumbers) ?? true;
    lastPage = p.getInt(_kLastPage) ?? 1;
    bookmarks = (p.getStringList(_kBookmarks) ?? const []).toSet();
    _loaded = true;
    notifyListeners();
  }

  Future<void> setEdition(String v) async {
    edition = v;
    notifyListeners();
    (await SharedPreferences.getInstance()).setString(_kEdition, v);
  }

  Future<void> setFontSize(double v) async {
    fontSize = v.clamp(13, 34);
    notifyListeners();
    (await SharedPreferences.getInstance()).setDouble(_kFontSize, fontSize);
  }

  Future<void> setLineHeight(double v) async {
    lineHeight = v.clamp(1.3, 2.4);
    notifyListeners();
    (await SharedPreferences.getInstance()).setDouble(_kLineHeight, lineHeight);
  }

  Future<void> setSerif(bool v) async {
    serif = v;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool(_kSerif, v);
  }

  Future<void> setShowVerseNumbers(bool v) async {
    showVerseNumbers = v;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool(_kShowVerseNumbers, v);
  }

  /// Deliberately silent: this fires on every swipe and a rebuild would
  /// cost more than it is worth.
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
}
