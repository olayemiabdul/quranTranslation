import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_complete_ui/quran_ayah/quran_content.dart';

import 'package:quran_complete_ui/quran_translation_package/quran_translation_ayahText.dart';
import 'package:quran_complete_ui/quran_translation_package/quran_translation_content.dart';
import 'package:quran_complete_ui/quran_translation_package/translations_model_class.dart';

import '../provider/theme_provider.dart';
import '../quranText_englishTranslation/eng_arabic_model_class.dart';
import '../quranText_englishTranslation/quran_content_engArabic.dart';



class OrganizedTranslationAyahViewScreen extends StatefulWidget {
  final List<TranslationSurahClass> surahs;
  final int initialPage;

  OrganizedTranslationAyahViewScreen({
    required this.surahs,
    this.initialPage = 1,
  });

  @override
  _OrganizedTranslationAyahViewScreenState createState() => _OrganizedTranslationAyahViewScreenState();
}

class _OrganizedTranslationAyahViewScreenState extends State<OrganizedTranslationAyahViewScreen> {
  PageController pageController = PageController();
  List<QuranPageTranslation> quranPages = [];
  int currentPage = 1;
  String currentSurahName = '';
  int currentJuzNumber = 1;
  String englishName='';


  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.initialPage);
    organizePages();
    updateCurrentSurahAndJuz(widget.initialPage);
    currentPage = widget.initialPage + 1;
  }

  void organizePages() {
    Map<int, List< PageContentTranslation>> pageContent = {};


    for (var surah in widget.surahs) {

      for (var ayahEA in surah.ayahsEA) {

        pageContent[ayahEA.page] ??= [];
        bool isNewSurah = surah.ayahsEA == ayahEA;
        PageContentTranslation? existingContent = pageContent[ayahEA.page]!.firstWhere(
              (content) => content.englishName == surah.englishName,
          orElse: () {
            var newContent =  PageContentTranslation(
              surahName: surah.englishName,
              englishName: surah.englishName,

              isNewSurah: isNewSurah, ayahs: [],
            );
            pageContent[ayahEA.page]!.add(newContent);
            return newContent;
          },
        );
        existingContent.ayahs.add(ayahEA );
      }
    }

    quranPages = List.generate(604, (index) {
      int pageNumber = index + 1;
      return QuranPageTranslation(
        pageNumber: pageNumber,
       contents: pageContent[pageNumber] ?? [],
      );
    });
  }

  void updateCurrentSurahAndJuz(int pageIndex) {
    if (pageIndex < quranPages.length && quranPages[pageIndex].contents.isNotEmpty) {
      var firstAyah = quranPages[pageIndex].contents[0].ayahs.first;
      setState(() {
        currentSurahName = quranPages[pageIndex].contents[0].surahName;
        currentJuzNumber = firstAyah.juz;
        englishName = quranPages[pageIndex].contents[0].englishName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkTheme = themeNotifier.themeModeNotifier.value == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currentSurahName,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 45,),
            Center(
              child: Text(
                englishName,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 45,),
            Text(
              'Juz $currentJuzNumber',
              style: const TextStyle(fontSize: 14),
            ),

          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkTheme ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: themeNotifier.toggleTheme,
          ),
        ],
        centerTitle: true,
      ),
      body: PageView.builder(
        reverse: true,
        controller: pageController,
        itemCount: 604,
        onPageChanged: (page) {
          setState(() {
            currentPage = page + 1;
            updateCurrentSurahAndJuz(page);
          });
        },
        itemBuilder: (context, index) {
          return AllTranslationTextPage(page: quranPages[index],);
        },
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
