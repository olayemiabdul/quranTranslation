import 'surah_class.dart';

/// One of the 604 pages of the Mushaf, as flowing text.
class QuranPage {
  final int pageNumber;
  final List<PageContent> contents;

  const QuranPage({required this.pageNumber, required this.contents});

  bool get isEmpty => contents.isEmpty;

  int get juz => contents.isEmpty ? 1 : contents.first.ayahs.first.juz;

  /// The surah a reader would say they are "on" for this page.
  PageContent? get primary => contents.isEmpty ? null : contents.first;
}

/// The run of ayahs from one surah that falls on a given page. A page can
/// hold the end of one surah and the start of the next, so a page has a
/// list of these.
class PageContent {
  final int surahNumber;
  final String surahName; // Arabic
  final String englishName;
  final List<Ayah> ayahs;

  /// True when this run starts the surah, so the page should show the
  /// ornamental header (and the Basmala, where the surah has one).
  final bool isNewSurah;

  /// False for Al-Fatiha and At-Tawbah.
  final bool hasBismillah;

  PageContent({
    required this.surahNumber,
    required this.surahName,
    required this.englishName,
    required this.ayahs,
    required this.isNewSurah,
    required this.hasBismillah,
  });
}

/// Builds all 604 pages once, in surah/ayah order.
///
/// The old version called `firstWhere` on a list it was appending to inside
/// the `orElse`, which is fragile and O(n^2). This walks each surah in order
/// and starts a new run whenever the page changes.
List<QuranPage> buildQuranPages(List<Surah> surahs, {int totalPages = 604}) {
  final byPage = <int, List<PageContent>>{};

  for (final surah in surahs) {
    PageContent? run;
    int? runPage;

    for (final ayah in surah.ayahs) {
      final page = ayah.page;
      if (page < 1) continue;

      if (run == null || runPage != page) {
        run = PageContent(
          surahNumber: surah.number,
          surahName: surah.name,
          englishName: surah.englishName,
          ayahs: <Ayah>[],
          // Only the run that carries ayah 1 opens the surah.
          isNewSurah: ayah.numberInSurah == 1,
          hasBismillah: surah.hasBismillah,
        );
        runPage = page;
        (byPage[page] ??= <PageContent>[]).add(run);
      }
      run.ayahs.add(ayah);
    }
  }

  return List<QuranPage>.generate(totalPages, (i) {
    final n = i + 1;
    return QuranPage(pageNumber: n, contents: byPage[n] ?? const <PageContent>[]);
  });
}
