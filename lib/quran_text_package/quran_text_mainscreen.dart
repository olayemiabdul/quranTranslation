import 'package:flutter/material.dart';
import 'package:quran_complete_ui/quran_text_package/quran_text_favourite.dart';
import 'package:quran_complete_ui/quran_text_package/quran_surahList.dart';









class QuranTextMainPage extends StatefulWidget {
  const QuranTextMainPage({super.key});

  @override
  State<QuranTextMainPage> createState() => _QuranTextMainPageState();
}

class _QuranTextMainPageState extends State<QuranTextMainPage> {


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
                QuranTextPage(),


                QuranTextFavourite()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
