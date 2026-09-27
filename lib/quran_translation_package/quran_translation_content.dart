import 'translations_model_class.dart';

/// One of the 604 Mushaf pages, as translated text.
class QuranPageTranslation {
  final int pageNumber;
  final List<PageContentTranslation> contents;

  const QuranPageTranslation({
    required this.pageNumber,
    required this.contents,
  });

  bool get isEmpty => contents.isEmpty;

  int get juz => contents.isEmpty ? 1 : contents.first.ayahs.first.juz;

  PageContentTranslation? get primary =>
      contents.isEmpty ? null : contents.first;
}

/// The run of ayahs from one surah that falls on a page. A page can hold the
/// end of one surah and the start of the next.
class PageContentTranslation {
  final int surahNumber;
  final String englishName;
  final String englishNameTranslation;
  final List<AyahTranslation> ayahs;

  /// True when this run opens the surah, so the page shows its heading.
  final bool isNewSurah;

  /// The edition's "In the name of Allah…" line, when the surah has one.
  final String? bismillah;

  PageContentTranslation({
    required this.surahNumber,
    required this.englishName,
    required this.englishNameTranslation,
    required this.ayahs,
    required this.isNewSurah,
    this.bismillah,
  });

  /// Old name. Both fields always held the same value.
  @Deprecated('Use englishName')
  String get surahName => englishName;
}

/// Builds all 604 pages in one ordered pass.
///
/// The old `organizePages()` called `firstWhere` on a list it was appending
/// to inside that same call's `orElse`, which is fragile and quadratic. This
/// walks each surah once and opens a new run whenever the page changes.
List<QuranPageTranslation> buildTranslationPages(
  List<TranslationSurahClass> surahs, {
  int totalPages = 604,
}) {
  final byPage = <int, List<PageContentTranslation>>{};

  for (final surah in surahs) {
    PageContentTranslation? run;
    int? runPage;

    for (final ayah in surah.ayahsEA) {
      final page = ayah.page;
      if (page < 1) continue;

      if (run == null || runPage != page) {
        run = PageContentTranslation(
          surahNumber: surah.number,
          englishName: surah.englishName,
          englishNameTranslation: surah.englishNameTranslation,
          ayahs: <AyahTranslation>[],
          isNewSurah: ayah.numberInSurah == 1,
          bismillah: surah.bismillah,
        );
        runPage = page;
        (byPage[page] ??= <PageContentTranslation>[]).add(run);
      }
      run.ayahs.add(ayah);
    }
  }

  return List<QuranPageTranslation>.generate(totalPages, (i) {
    final n = i + 1;
    return QuranPageTranslation(
      pageNumber: n,
      contents: byPage[n] ?? const <PageContentTranslation>[],
    );
  });
}
