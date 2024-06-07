import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_complete_ui/quranText_englishTranslation/qurantext_engTrans_text.dart';

import '../constant.dart';




class EngArabicTextSurahListPage extends StatefulWidget {
  const EngArabicTextSurahListPage({super.key});

  @override
  _EngArabicTextSurahListPageState createState() => _EngArabicTextSurahListPageState();
}

class _EngArabicTextSurahListPageState extends State<EngArabicTextSurahListPage> {
  List<dynamic> quranText = [];
  List<dynamic> translationQuranText = [];

  Future<void> getQuranTextOnly() async {
    final response = await http.get(Uri.parse("https://api.alquran.cloud/v1/quran/quran-uthmani"));
    if (response.statusCode == 200) {
      setState(() {
        quranText = json.decode(response.body)["data"]["surahs"];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }
  Future<void> getQuranTransOnly() async {
    final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/quran/en.ahmedali'));
    if (response.statusCode == 200) {
      setState(() {
        translationQuranText= json.decode(response.body)["data"]["surahs"];
      });
    } else {
      throw Exception('Failed to load Quran data');
    }
  }

  @override
  void initState() {
    super.initState();
    getQuranTextOnly();
    getQuranTransOnly();
  }

  @override
  Widget build(BuildContext context) {
    return
       Scaffold(
         backgroundColor: gridContainerColor,
        appBar: AppBar(
          backgroundColor: gridContainerColor,
          title: const Text('English and Arabic Quran'),
        ),
        body: quranText.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: quranText.length,

          itemBuilder: (context, index) {
            final uthmanisurah = quranText[index];
            final translationDta=translationQuranText[index];
            return Card(
              color: gridContainerColor,
              child: ListTile(


                title: Text('Surah ${quranText[index]["number"]}: ${quranText[index]["englishName"]}'),
                subtitle: Text(' ${quranText[index]["ayahs"].length} Verses-${quranText[index]['revelationType']}'),
                trailing: Text('${quranText[index]['name']}\n ${quranText[index]['englishNameTranslation']}',
                  style: const TextStyle(
                    //wordSpacing: 2,

                      fontFamily: 'Kitab-Bold',
                      color: Colors.white,
                      fontSize: 18, fontWeight: FontWeight.bold),),
                leading: Container(
                  alignment: Alignment.center,
                  height: 30,
                  width: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: gridContainerColor,
                  ),
                  child: Text(
                    quranText[index]['number'].toString(),
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  EngArabicTextPage(ayahs: uthmanisurah['ayahs'], ayahstext: translationDta ['ayahs'], surahEnglishName: uthmanisurah['englishName'], numberInSurah: uthmanisurah['ayahs'], surahEnglishNameT: uthmanisurah['englishName'], numberInSurahT: uthmanisurah['ayahs'],  ),
                    ),
                  );
                },
              ),
            );


          },
        ),
      );

  }
}
