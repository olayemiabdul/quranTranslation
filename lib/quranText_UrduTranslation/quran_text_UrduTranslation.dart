
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';

import '../constant.dart';

class UrduArabicTextPage extends StatefulWidget {
  final List<dynamic> ayahs;
  final List<dynamic> ayahstext;
  final String surahEnglishName;// to request for the appbar title from quran_list page
  final List<dynamic> numberInSurah;// to request for the appbar title from quran_list page
  final String surahEnglishNameT;// to request for the appbar title from quran_list page
  final List<dynamic> numberInSurahT;// to request for the appbar title from quran_list page

  const UrduArabicTextPage({super.key, required this.ayahs, required this.ayahstext, required this.surahEnglishName, required this.numberInSurah, required this.surahEnglishNameT, required this.numberInSurahT,});

  @override
  State<UrduArabicTextPage> createState() => _UrduArabicTextPageState();
}

class _UrduArabicTextPageState extends State<UrduArabicTextPage> {
  ArabicNumbers arabicNumber =ArabicNumbers();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gridContainerColor,
      appBar: AppBar(
          backgroundColor: gridContainerColor,
          title:
          Text(widget.surahEnglishName)
      ),
      body: ListView.builder(
        itemCount: widget.ayahs.length,
        itemBuilder: (context, index) {
          final ayah = widget.ayahs[index];
          final translated=widget.ayahstext[index];
          return Card(
            color:Colors.white ,
            child: ListTile(
              title: Column(
                children: [
                  Text(ayah['text'],
                    softWrap: true,
                    textAlign: TextAlign.right,
                    maxLines: 15,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(

                        fontFamily: 'Kitab-Bold',
                        color: Colors.black,
                        fontSize: 18),
                  ),
                  const SizedBox(height: 6,),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(translated['text'], textAlign: TextAlign.right,
                      maxLines: 15,
                      style: const TextStyle(

                          fontFamily: 'Kitab-Bold',
                          color: Colors.black,
                          fontSize: 18),),
                  ),
                ],
              ),
              // subtitle: Padding(
              //   padding: const EdgeInsets.only(right: 130),
              //   child: Text(translated['text']),
              // ),
              leading:   Container(
                alignment: Alignment.center,
                height: 35,
                width: 35,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: Text(
                  arabicNumber.convert( ayah['numberInSurah'].toString()),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),

                ),
              ),


            ),
          );


        },
      ),
    );
  }
}