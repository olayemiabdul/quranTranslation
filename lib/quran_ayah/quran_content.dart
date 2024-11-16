

import 'package:quran_complete_ui/quran_ayah/surah_class.dart';

class QuranPage {
  final int pageNumber;
  final List<PageContent> contents;


  QuranPage({
    required this.pageNumber,
    required this.contents,

  });
}

// Model class for Page Content (can contain parts of multiple surahs)
class PageContent {
  final String englishName;
  final String surahName;
  final List<Ayah> ayahs;
  final bool isNewSurah;

  PageContent({
    required this.surahName,
    required this.ayahs,
    required this.isNewSurah,
    required this.englishName,
  });
}