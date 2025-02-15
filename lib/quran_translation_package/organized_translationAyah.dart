import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_quran/quran_translation_package/quran_translation_ayahText.dart';
import 'package:universal_quran/quran_translation_package/quran_translation_content.dart';
import 'package:universal_quran/quran_translation_package/translations_model_class.dart';

import '../provider/theme_provider.dart';

import '../responsiveness/responsive.dart';

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
  String englishName = '';

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.initialPage);
    organizePages();
    updateCurrentSurahAndJuz(widget.initialPage);
    currentPage = widget.initialPage + 1;
  }

  void organizePages() {
    Map<int, List<PageContentTranslation>> pageContent = {};

    for (var surah in widget.surahs) {
      for (var ayahEA in surah.ayahsEA) {
        pageContent[ayahEA.page] ??= [];
        bool isNewSurah = surah.ayahsEA == ayahEA;
        PageContentTranslation? existingContent = pageContent[ayahEA.page]!.firstWhere(
              (content) => content.englishName == surah.englishName,
          orElse: () {
            var newContent = PageContentTranslation(
              surahName: surah.englishName,
              englishName: surah.englishName,
              isNewSurah: isNewSurah,
              ayahs: [],
            );
            pageContent[ayahEA.page]!.add(newContent);
            return newContent;
          },
        );
        existingContent.ayahs.add(ayahEA);
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
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!isMobile)
              Text(
                currentSurahName,
                style: TextStyle(fontSize: isMobile ? 14 : isTablet ? 16 : 18),
              ),
            const SizedBox(width: 45),
            Center(
              child: Text(
                englishName,
                style: TextStyle(fontSize: isMobile ? 12 : isTablet ? 14 : 16),
              ),
            ),
            const SizedBox(width: 45),
            if (!isMobile)
              Text(
                'Juz $currentJuzNumber',
                style: TextStyle(fontSize: isMobile ? 12 : isTablet ? 14 : 16),
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
      body: ScrollConfiguration(
        behavior: const CupertinoScrollBehavior(),

        child: PageView.builder(
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
            return AllTranslationTextPage(page: quranPages[index]);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}