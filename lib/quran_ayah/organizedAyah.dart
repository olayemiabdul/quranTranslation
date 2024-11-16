 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_complete_ui/quran_ayah/quran_content.dart';
import 'package:quran_complete_ui/quran_ayah/surah_class.dart';

import '../provider/theme_provider.dart';
import 'ayah_page.dart';


class OrganizedAyahViewScreen extends StatefulWidget {
  final List<Surah> surahs;
  final int initialPage;

  OrganizedAyahViewScreen({
    required this.surahs,
    this.initialPage = 1,
  });

  @override
  _OrganizedAyahViewScreenState createState() => _OrganizedAyahViewScreenState();
}

class _OrganizedAyahViewScreenState extends State<OrganizedAyahViewScreen> {
  PageController pageController = PageController();
  List<QuranPage> quranPages = [];
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
    Map<int, List<PageContent>> pageContents = {};

    for (var surah in widget.surahs) {
      for (var ayah in surah.ayahs) {
        pageContents[ayah.page] ??= [];
        bool isNewSurah = surah.ayahs.first == ayah;
        PageContent? existingContent = pageContents[ayah.page]!
            .firstWhere(
              (content) => content.surahName == surah.name,
          orElse: () {
            var newContent = PageContent(
              surahName: surah.name,
              ayahs: [],
              isNewSurah: isNewSurah, englishName: surah.englishName,
            );
            pageContents[ayah.page]!.add(newContent);
            return newContent;
          },
        );
        existingContent.ayahs.add(ayah);
      }
    }

    quranPages = List.generate(604, (index) {
      int pageNumber = index + 1;
      return   QuranPage(
        pageNumber: pageNumber,
        contents: pageContents[pageNumber] ?? [],
      );
    });
  }

  void updateCurrentSurahAndJuz(int pageIndex) {
    QuranPage currentQuranPage = quranPages[pageIndex];
    if (currentQuranPage.contents.isNotEmpty) {
      var firstAyah = currentQuranPage.contents[0].ayahs.first;
      setState(() {
        currentSurahName = currentQuranPage.contents[0].surahName;
        currentJuzNumber = firstAyah.juz;
        englishName=currentQuranPage.contents[0].englishName;

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
          return AyahPageView(page: quranPages[index]);
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
