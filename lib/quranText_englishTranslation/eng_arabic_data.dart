import '../quran_ayah/quran_data.dart';
import '../quran_ayah/surah_class.dart' as ar;
import '../quran_translation_package/translation_data.dart';
import '../quran_translation_package/translations_model_class.dart' as tr;
import 'eng_arabic_model_class.dart';

/// Joins the Arabic Quran with a translation, for the Study reader.
///
/// This downloads NOTHING of its own. Both halves already exist in the app:
///   * the Arabic comes from [QuranData], cached under `surahs`
///   * the translation comes from [TranslationData], cached per edition
///
/// The old screen fetched `/v1/quran/quran-uthmani` AND
/// `/v1/quran/en.ahmedali` — two more full copies of the Quran, about ten
/// megabytes — and stored them under `quranArabicData` and
/// `quranEnglishData`. So a phone that had opened both this screen and the
/// other readers was holding the Arabic Quran twice and an English
/// translation twice, for no benefit at all.
///
/// The old screen also hard-coded `en.ahmedali`, so this reader offered
/// exactly one translation and no way to change it. Any edition works now.
class EngArabicData {
  EngArabicData._();
  static final EngArabicData instance = EngArabicData._();

  final Map<String, List<SurahEngArabic>> _memory = {};
  final Map<String, Future<List<SurahEngArabic>>> _inFlight = {};

  List<SurahEngArabic>? cached(String edition) => _memory[edition];

  Future<List<SurahEngArabic>> load(
    String edition, {
    void Function(double progress)? onProgress,
    bool forceRefresh = false,
  }) {
    if (!forceRefresh && _memory[edition] != null) {
      return Future.value(_memory[edition]!);
    }
    return _inFlight[edition] ??= _load(edition, onProgress, forceRefresh)
        .whenComplete(() => _inFlight.remove(edition));
  }

  Future<List<SurahEngArabic>> _load(
    String edition,
    void Function(double)? onProgress,
    bool forceRefresh,
  ) async {
    final arabic = await QuranData.instance.load(forceRefresh: forceRefresh);
    final translation = await TranslationData.instance.load(
      edition,
      onProgress: onProgress,
      forceRefresh: forceRefresh,
    );

    final byNumber = <int, tr.TranslationSurahClass>{
      for (final s in translation) s.number: s,
    };

    final joined = <SurahEngArabic>[];
    for (final surah in arabic) {
      final other = byNumber[surah.number];

      // Paired by ayah NUMBER, not by position in the list. If an edition
      // ever splits a surah differently, the worst case is a missing
      // translation, never a wrong one lined up under the Arabic.
      final translations = <int, String>{
        if (other != null)
          for (final a in other.ayahsEA) a.numberInSurah: a.text,
      };

      joined.add(SurahEngArabic(
        number: surah.number,
        name: surah.name,
        englishName: surah.englishName,
        englishNameTranslation: surah.englishNameTranslation,
        revelationType: surah.revelationType,
        numberOfAyahs: surah.numberOfAyahs,
        bismillahTranslation: other?.bismillah,
        ayahsEA: [
          for (final a in surah.ayahs)
            _convert(a, translations[a.numberInSurah]),
        ],
      ));
    }

    _memory[edition] = joined;
    return joined;
  }

  AyahEngArabic _convert(ar.Ayah a, String? translation) => AyahEngArabic(
        number: a.number,
        text: a.text,
        numberInSurah: a.numberInSurah,
        surahNumber: a.surahNumber,
        juz: a.juz,
        manzil: a.manzil,
        page: a.page,
        ruku: a.ruku,
        hizbQuarter: a.hizbQuarter,
        sajda: a.sajda,
        translationText: translation,
      );

  /// How many ayahs came back without a translation. Zero is expected; a
  /// non-zero result means the two editions disagree somewhere and is worth
  /// surfacing rather than hiding.
  int missingTranslations(List<SurahEngArabic> surahs) {
    var missing = 0;
    for (final s in surahs) {
      for (final a in s.ayahsEA) {
        if (a.translationText == null || a.translationText!.isEmpty) missing++;
      }
    }
    return missing;
  }

  /// Drops tashkeel and unifies the alif and ya forms, so a search typed
  /// without diacritics still finds the ayah.
  static String _stripArabicMarks(String input) => input
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'), '')
      .replaceAll(RegExp(r'[\u0622\u0623\u0625]'), '\u0627')
      .replaceAll('\u0649', '\u064A')
      .replaceAll('\u0629', '\u0647');

  /// Searches the Arabic and the translation together.
  List<AyahEngArabic> search(
    List<SurahEngArabic> surahs,
    String query, {
    int limit = 300,
  }) {
    final q = query.trim().toLowerCase();
    if (q.length < 2) return const [];

    // Arabic typed without diacritics should still match.
    final normalized = _stripArabicMarks(q);

    final hits = <AyahEngArabic>[];
    for (final surah in surahs) {
      for (final ayah in surah.ayahsEA) {
        final inTranslation =
            (ayah.translationText ?? '').toLowerCase().contains(q);
        final inArabic = _stripArabicMarks(ayah.text).contains(normalized);
        if (inTranslation || inArabic) {
          hits.add(ayah);
          if (hits.length >= limit) return hits;
        }
      }
    }
    return hits;
  }
}
