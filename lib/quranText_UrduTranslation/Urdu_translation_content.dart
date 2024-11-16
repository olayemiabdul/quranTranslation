




import 'Urdu_Model_Class.dart';


class UrduQuranPageTranslation {
  final int pageNumber;
  final List<UrduPageContentTranslation> contents;


  UrduQuranPageTranslation({
    required this.pageNumber,
    required this.contents,

  });
}

// Model class for Page Content (can contain parts of multiple surahs
class UrduPageContentTranslation {
  final String englishName;
  final String surahName;
  final List< UrduAyahTranslation  > ayahs;
  final bool isNewSurah;

  UrduPageContentTranslation({
    required this.surahName,
    required this.ayahs,
    required this.isNewSurah,
    required this.englishName,
  });
}