import 'package:flutter/material.dart';
import 'package:quran_complete_ui/quran_text_package/quran_text_favourite.dart';
import 'package:quran_complete_ui/quran_text_package/quran_surahList.dart';
import 'package:quran_complete_ui/quran_translation_package/quran_translationList.dart';
import 'package:quran_complete_ui/quran_translation_package/quran_translation_favourite.dart';









class QuranTranslationMainPage extends StatefulWidget {
  const QuranTranslationMainPage({super.key});

  @override
  State<QuranTranslationMainPage> createState() => _QuranTranslationMainPageState();
}

class _QuranTranslationMainPageState extends State<QuranTranslationMainPage> {


  @override
  Widget build(BuildContext context) {
    return SafeArea(

      child: DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Quran'),
              bottom: const TabBar(
                tabs: [
                  Tab(
                    //icon: Icon(Icons.book),
                    text: "Surahs",
                  ),

                  Tab(
                    //icon: Icon(Icons.bookmark_add),
                    text: "Bookmarks",
                  ),
                ],
              ),
            ),
            body:  const TabBarView(
              children: [
                //const AudioScreen(),
                QuranTranslationListPage(),


                QuranTranslationFavouritePage ()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
