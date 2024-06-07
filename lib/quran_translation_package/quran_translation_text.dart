
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';

import '../constant.dart';
class QuranTranslationTextPage extends StatefulWidget {
  final List<dynamic> translatedAyahs;

  final String surahEnglishName;// to request for the appbar title from quran_list page
  final List<dynamic> numberInSurah;// to request for the appbar title from quran_list page

  const QuranTranslationTextPage({super.key, required this.translatedAyahs, required this.surahEnglishName, required this.numberInSurah});

  @override
  State<QuranTranslationTextPage> createState() => _QuranTranslationTextPageState();
}

class _QuranTranslationTextPageState extends State<QuranTranslationTextPage> {
  ArabicNumbers  arabicNumber=ArabicNumbers();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: gridContainerColor,
          title:
          Text(widget.surahEnglishName)
      ),
      body: Container(
        decoration:  const BoxDecoration(
          color: gridContainerColor,


          //color:gridContainerColor,
        ),
        child: ListView.builder(
            itemCount: widget.translatedAyahs.length,
            primary: false,
            //scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final ayah = widget.translatedAyahs[index];
              //final nim=widget.numberInSurah;


              return Card(
                color:gridContainerColor ,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ListTile(

                    title: Text(
                      //softWrap: true,

                      //maxLines: 15,
                      //overflow: TextOverflow.ellipsis,

                      ayah['text'].toString(),
                      style: const TextStyle(
                          //wordSpacing: 2,

                          fontFamily: 'Kitab-Bold',
                          color: Colors.white,
                          fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.justify,


                    ),
                    leading:   Container(
                      alignment: Alignment.center,
                      height: 35,
                      width: 35,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: Text(
                        ( ayah['numberInSurah'].toString()),
                        style: const TextStyle(color: Colors.white),

                      ),
                    ),


                  ),
                ),
              );

            }),
      ),
    );
  }
}