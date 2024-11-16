



import 'eng_arabic_model_class.dart';

class QuranPageEngArabic {
  final int pageNumber;
  final List<PageContentEngArabic> engArabicContents;


  QuranPageEngArabic({
    required this.pageNumber,
    required this.engArabicContents,

  });
}

// Model class for Page Content (can contain parts of multiple surahs)
class PageContentEngArabic {
  final String englishName;
  final String surahName;
  final List<AyahEngArabic> ayahsn;
  final bool isNewSurah;

  PageContentEngArabic({
    required this.surahName,
    required this.ayahsn,
    required this.isNewSurah,
    required this.englishName,
  });
}