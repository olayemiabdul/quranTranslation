import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_complete_ui/quranText_englishTranslation/eng_arabic_model_class.dart';
import 'package:quran_complete_ui/quranText_englishTranslation/quran_content_engArabic.dart';

import '../provider/theme_provider.dart';
import 'eng_arabic_text_page.dart';

class OrganizedEngArabicAyahViewScreen extends StatefulWidget {
  final List<SurahEngArabic> surahEA;
  final int initialPage;

  const OrganizedEngArabicAyahViewScreen({
    super.key,
    required this.surahEA,
    this.initialPage = 1,
  });

  @override
  _OrganizedEngArabicAyahViewScreenState createState() => _OrganizedEngArabicAyahViewScreenState();
}

class _OrganizedEngArabicAyahViewScreenState extends State<OrganizedEngArabicAyahViewScreen> {
  late PageController pageController;
  List<QuranPageEngArabic> quranPages = [];
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
    Map<int, List<PageContentEngArabic>> pageContent = {};


    for (var surah in widget.surahEA) {

      for (var ayahEA in surah.ayahsEA) {

        pageContent[ayahEA.page] ??= [];
        bool isNewSurah = surah.ayahsEA == ayahEA;
        PageContentEngArabic? existingContent = pageContent[ayahEA.page]!.firstWhere(
              (content) => content.surahName == surah.name,
          orElse: () {
            var newContent = PageContentEngArabic(
              surahName: surah.name,
              englishName: surah.englishName,
              ayahsn: [],
              isNewSurah: isNewSurah,
            );
            pageContent[ayahEA.page]!.add(newContent);
            return newContent;
          },
        );
        existingContent.ayahsn.add(ayahEA );
      }
    }

    quranPages = List.generate(604, (index) {
      int pageNumber = index + 1;
      return QuranPageEngArabic(
        pageNumber: pageNumber,
        engArabicContents: pageContent[pageNumber] ?? [],
      );
    });
  }

  void updateCurrentSurahAndJuz(int pageIndex) {
    if (pageIndex < quranPages.length && quranPages[pageIndex].engArabicContents.isNotEmpty) {
      var firstAyah = quranPages[pageIndex].engArabicContents[0].ayahsn.first;
      setState(() {
        currentSurahName = quranPages[pageIndex].engArabicContents[0].surahName;
        currentJuzNumber = firstAyah.juz;
        englishName = quranPages[pageIndex].engArabicContents[0].englishName;
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
            const SizedBox(width: 45),
            Center(
              child: Text(
                englishName,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 45),
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
          // Pass each QuranPage to EngArabicTextPageNew for displaying ayahs
          return EngArabicTextPageNew(page: quranPages[index]);
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
