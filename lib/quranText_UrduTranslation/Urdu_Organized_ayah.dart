import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_quran/quranText_UrduTranslation/urdu_ayahTranslation_text.dart';





import '../provider/theme_provider.dart';
import '../responsiveness/responsive.dart';
import 'Urdu_Model_Class.dart';
import 'Urdu_translation_content.dart';




class UrduOrganizedTranslationAyahViewScreen extends StatefulWidget {
  final List<UrduSurahClass> surahs;
  final int initialPage;

  UrduOrganizedTranslationAyahViewScreen({
    required this.surahs,
    this.initialPage = 1,
  });

  @override
  _UrduOrganizedTranslationAyahViewScreenState createState() => _UrduOrganizedTranslationAyahViewScreenState();
}

class _UrduOrganizedTranslationAyahViewScreenState extends State<UrduOrganizedTranslationAyahViewScreen> {
  PageController pageController = PageController();
  List<UrduQuranPageTranslation> quranPages = [];
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
    Map<int, List< UrduPageContentTranslation>> pageContent = {};


    for (var surah in widget.surahs) {

      for (var ayahEA in surah.ayahsUA) {

        pageContent[ayahEA.page] ??= [];
        bool isNewSurah = surah.ayahsUA == ayahEA;
        UrduPageContentTranslation? existingContent = pageContent[ayahEA.page]!.firstWhere(
              (content) => content.englishName == surah.englishName,
          orElse: () {
            var newContent =  UrduPageContentTranslation(
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
      return UrduQuranPageTranslation(
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
        automaticallyImplyLeading: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currentSurahName,
              style:  TextStyle(  fontSize: Responsive.isMobile(context) ? 10 : 16,),
            ),
            const SizedBox(width: 30,),
            Center(
              child: Text(
                englishName,
                style:  TextStyle(fontSize: Responsive.isMobile(context) ? 10 : 16,),
              ),
            ),
            const SizedBox(width: 30,),
            Text(
              'Juz $currentJuzNumber',
              style:  TextStyle(fontSize: Responsive.isMobile(context) ? 10 : 16,),
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
          return UrduTranslationTextPage(page: quranPages[index],);
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
