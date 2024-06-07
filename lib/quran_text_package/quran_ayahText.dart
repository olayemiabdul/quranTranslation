import 'dart:convert';
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:quran_complete_ui/constant.dart';
class UthmaniDetailPage extends StatefulWidget {
  final List<dynamic> ayahs;
  final String surahEnglishName;// to request for the appbar title from quran_list page
  final List<dynamic> numberInSurah;// to request for the appbar title from quran_list page


  const UthmaniDetailPage({super.key, required this.ayahs, required this.surahEnglishName, required this.numberInSurah, });

  @override
  State<UthmaniDetailPage> createState() => _UthmaniDetailPageState();
}

class _UthmaniDetailPageState extends State<UthmaniDetailPage> {
  ArabicNumbers arabicNumber = ArabicNumbers();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

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
            itemCount: widget.ayahs.length,
            primary: false,
            //scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final ayah = widget.ayahs[index];
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
                          wordSpacing: 2,

                            fontFamily: 'Kitab-Bold',
                            color: Colors.white,
                            fontSize: 25, fontWeight: FontWeight.normal),
                      textAlign: TextAlign.right,


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
                        arabicNumber.convert( ayah['numberInSurah'].toString()),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),

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
