import 'package:flutter/material.dart';
import 'package:quran_complete_ui/quranText_englishTranslation/qurantext_engTrans_favourite.dart';
import 'package:quran_complete_ui/quranText_englishTranslation/qurantext_engTrans_list.dart';
import 'package:quran_complete_ui/quran_text_package/quran_text_favourite.dart';
import 'package:quran_complete_ui/quran_text_package/quran_surahList.dart';
import 'package:quran_complete_ui/quran_translation_package/quran_translationList.dart';
import 'package:quran_complete_ui/quran_translation_package/quran_translation_favourite.dart';









class EngArabicTextMainPage extends StatefulWidget {
  const EngArabicTextMainPage({super.key});

  @override
  State<EngArabicTextMainPage> createState() => _EngArabicTextMainPageState();
}

class _EngArabicTextMainPageState extends State<EngArabicTextMainPage> {


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Scaffold(
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
                EngArabicTextSurahListPage(),


                EngArabicTextFavouritePage ()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
