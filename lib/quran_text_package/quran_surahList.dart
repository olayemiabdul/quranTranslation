import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:quran_complete_ui/constant.dart';
import 'package:quran_complete_ui/quran_text_package/quran_ayahText.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranTextPage extends StatefulWidget {
  const QuranTextPage({super.key});

  @override
  State<QuranTextPage> createState() => _QuranTextPageState();
}

class _QuranTextPageState extends State<QuranTextPage> {
  List<dynamic> quranData = [];



  Future<void> getQuranText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('quranData');

    if (cachedData != null) {
      setState(() {
        quranData = json.decode(cachedData)["data"]["surahs"];
      });
    }
    else {
      final response = await http.get(Uri.parse("https://api.alquran.cloud/v1/quran/quran-uthmani"));
      if (response.statusCode == 200) {
        setState(() {
          quranData = json.decode(response.body)["data"]["surahs"];
        });
        await prefs.setString('quranData', response.body);
      } else {
        throw Exception('Failed to load data');
      }
    }
  }
  @override
  void initState() {
    super.initState();

    //getQuranTextData();
    getQuranText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: gridContainerColor,
        title: const Text('Complete Quran'),
      ),
      backgroundColor: gridContainerColor,
      body: quranData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: quranData.length,
              itemBuilder: (context, index) {
                final uthmanisurah = quranData[index];
                //final utmaniayah=quranData[index]

                return Card(
                  color: gridContainerColor,
                  child: ListTile(
                    title: Text(
                        'Surah ${quranData[index]["number"]}: ${quranData[index]["englishName"]}'),
                    subtitle: Text(
                        ' ${quranData[index]["ayahs"].length} Verses-${quranData[index]['revelationType']}'),
                    trailing: Text(
                      '${quranData[index]['name']}\n${quranData[index]['englishNameTranslation']}',
                      style: const TextStyle(
                          //wordSpacing: 2,

                          fontFamily: 'Kitab-Bold',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    leading: Container(
                      alignment: Alignment.center,
                      height: 30,
                      width: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: gridContainerColor,
                      ),
                      child: Text(
                        quranData[index]['number'].toString(),
                        style: const TextStyle(
                            fontSize: 26,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UthmaniDetailPage(
                            ayahs: uthmanisurah['ayahs'],
                            surahEnglishName: uthmanisurah['englishName'],
                            numberInSurah: uthmanisurah['ayahs'],
                          ),
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
