import 'eng_arabic_model_class.dart';

/// One of the 604 Mushaf pages, with the Arabic and its meaning.
class QuranPageEngArabic {
  final int pageNumber;
  final List<PageContentEngArabic> engArabicContents;

  const QuranPageEngArabic({
    required this.pageNumber,
    required this.engArabicContents,
  });

  bool get isEmpty => engArabicContents.isEmpty;

  int get juz =>
      engArabicContents.isEmpty ? 1 : engArabicContents.first.ayahsn.first.juz;

  PageContentEngArabic? get primary =>
      engArabicContents.isEmpty ? null : engArabicContents.first;
}

/// The run of ayahs from one surah that falls on a page.
class PageContentEngArabic {
  final int surahNumber;
  final String surahName; // Arabic
  final String englishName;
  final String englishNameTranslation;
  final List<AyahEngArabic> ayahsn;

  /// True when this run opens the surah.
  final bool isNewSurah;

  final bool hasBismillah;
  final String? bismillahTranslation;

  PageContentEngArabic({
    required this.surahNumber,
    required this.surahName,
    required this.englishName,
    required this.englishNameTranslation,
    required this.ayahsn,
    required this.isNewSurah,
    required this.hasBismillah,
    this.bismillahTranslation,
  });
}

/// Builds all 604 pages in one ordered pass.
///
/// The old `organizePages()` called `firstWhere` on a list it was appending
/// to inside that same call's `orElse`, and matched runs by surah NAME.
List<QuranPageEngArabic> buildEngArabicPages(
  List<SurahEngArabic> surahs, {
  int totalPages = 604,
}) {
  final byPage = <int, List<PageContentEngArabic>>{};

  for (final surah in surahs) {
    PageContentEngArabic? run;
    int? runPage;

    for (final ayah in surah.ayahsEA) {
      final page = ayah.page;
      if (page < 1) continue;

      if (run == null || runPage != page) {
        run = PageContentEngArabic(
          surahNumber: surah.number,
          surahName: surah.name,
          englishName: surah.englishName,
          englishNameTranslation: surah.englishNameTranslation,
          ayahsn: <AyahEngArabic>[],
          isNewSurah: ayah.numberInSurah == 1,
          hasBismillah: surah.hasBismillah,
          bismillahTranslation: surah.bismillahTranslation,
        );
        runPage = page;
        (byPage[page] ??= <PageContentEngArabic>[]).add(run);
      }
      run.ayahsn.add(ayah);
    }
  }

  return List<QuranPageEngArabic>.generate(totalPages, (i) {
    final n = i + 1;
    return QuranPageEngArabic(
      pageNumber: n,
      engArabicContents: byPage[n] ?? const <PageContentEngArabic>[],
    );
  });
}
