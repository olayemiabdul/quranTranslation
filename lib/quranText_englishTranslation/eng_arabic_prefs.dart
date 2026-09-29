import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings for the Study reader.
///
/// The one that matters is having **two** font sizes. The old page set the
/// Arabic and the English from the same `fontSize` value, computed from the
/// screen height. Uthmani script and Latin type do not read at the same
/// point size — Arabic needs to be noticeably larger to be as legible — so
/// a single slider always left one of them wrong.
class EngArabicPrefs extends ChangeNotifier {
  EngArabicPrefs._();
  static final EngArabicPrefs instance = EngArabicPrefs._();

  static const defaultEdition = 'en.sahih';

  static const _kEdition = 'ea_edition';
  static const _kArabicSize = 'ea_arabic_size';
  static const _kTranslationSize = 'ea_translation_size';
  static const _kShowArabic = 'ea_show_arabic';
  static const _kShowTranslation = 'ea_show_translation';
  static const _kLastPage = 'ea_last_page';
  static const _kBookmarks = 'ea_bookmarks';

  String edition = defaultEdition;
  double arabicSize = 26;
  double translationSize = 16;

  /// Either side can be hidden, which turns this one screen into an
  /// Arabic-only or meaning-only reader without leaving it.
  bool showArabic = true;
  bool showTranslation = true;

  int lastPage = 1;
  Set<String> bookmarks = <String>{};

  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final p = await SharedPreferences.getInstance();
    edition = p.getString(_kEdition) ?? defaultEdition;
    arabicSize = p.getDouble(_kArabicSize) ?? 26;
    translationSize = p.getDouble(_kTranslationSize) ?? 16;
    showArabic = p.getBool(_kShowArabic) ?? true;
    showTranslation = p.getBool(_kShowTranslation) ?? true;
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

  Future<void> setArabicSize(double v) async {
    arabicSize = v.clamp(18, 46);
    notifyListeners();
    (await SharedPreferences.getInstance()).setDouble(_kArabicSize, arabicSize);
  }

  Future<void> setTranslationSize(double v) async {
    translationSize = v.clamp(12, 30);
    notifyListeners();
    (await SharedPreferences.getInstance())
        .setDouble(_kTranslationSize, translationSize);
  }

  /// Refuses to hide both: an empty page helps nobody.
  Future<void> setShowArabic(bool v) async {
    if (!v && !showTranslation) return;
    showArabic = v;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool(_kShowArabic, v);
  }

  Future<void> setShowTranslation(bool v) async {
    if (!v && !showArabic) return;
    showTranslation = v;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool(_kShowTranslation, v);
  }

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
