
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
  final int ayahsPerPage = 8;
  @override
  Widget build(BuildContext context) {
    int totalPages = (widget.translatedAyahs.length / ayahsPerPage).ceil();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: gridContainerColor,
          title:
          Text(widget.surahEnglishName)
      ),
      body: PageView.builder(
          itemCount: totalPages,
          //primary: false,
          reverse: true,
          //scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final ayah = widget.translatedAyahs[index];
            //final nim=widget.numberInSurah;
            int startIndex = index * ayahsPerPage;
            int endIndex = startIndex + ayahsPerPage;
            if (endIndex > widget.translatedAyahs.length) {
              endIndex = widget.translatedAyahs.length;
            }
            List<dynamic> ayahsOnPage = widget.translatedAyahs.sublist(startIndex, endIndex);
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: ayahsOnPage.map((ayah) {
                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        title: Text(

                          ayah['text'].toString(),
                          textAlign: TextAlign.justify,
                          maxLines: 25,
                          overflow: TextOverflow.visible,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'Kitab-Bold',
                          ),
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
                            (ayah['numberInSurah'].toString()),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );


            // return Card(
            //   color:gridContainerColor ,
            //   child: Padding(
            //     padding: const EdgeInsets.only(left: 10),
            //     child: ListTile(
            //
            //       title: Text(
            //         //softWrap: true,
            //
            //         //maxLines: 15,
            //         //overflow: TextOverflow.ellipsis,
            //
            //         ayah['text'].toString(),
            //         style: const TextStyle(
            //             //wordSpacing: 2,
            //
            //             fontFamily: 'Kitab-Bold',
            //             color: Colors.white,
            //             fontSize: 18, fontWeight: FontWeight.bold),
            //         textAlign: TextAlign.justify,
            //
            //
            //       ),
            //       leading:   Container(
            //         alignment: Alignment.center,
            //         height: 35,
            //         width: 35,
            //         decoration: const BoxDecoration(
            //           shape: BoxShape.circle,
            //           color: Colors.grey,
            //         ),
            //         child: Text(
            //           ( ayah['numberInSurah'].toString()),
            //           style: const TextStyle(color: Colors.white),
            //
            //         ),
            //       ),
            //
            //
            //     ),
            //   ),
            // );

          }),
    );
  }
}