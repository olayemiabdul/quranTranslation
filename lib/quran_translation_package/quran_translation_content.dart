



import 'package:quran_complete_ui/quran_translation_package/translations_model_class.dart';


class QuranPageTranslation {
  final int pageNumber;
  final List<PageContentTranslation> contents;


  QuranPageTranslation({
    required this.pageNumber,
    required this.contents,

  });
}

// Model class for Page Content (can contain parts of multiple surahs
class PageContentTranslation {
  final String englishName;
  final String surahName;
  final List< AyahTranslation > ayahs;
  final bool isNewSurah;

  PageContentTranslation({
    required this.surahName,
    required this.ayahs,
    required this.isNewSurah,
    required this.englishName,
  });
}