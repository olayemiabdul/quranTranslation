import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_complete_ui/quranText_UrduTranslation/quran_text_UrduTranslation.dart';
import 'package:quran_complete_ui/quranText_englishTranslation/qurantext_engTrans_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';




class UrduArabicTextSurahListPage extends StatefulWidget {
  const UrduArabicTextSurahListPage({super.key});

  @override
  _UrduArabicTextSurahListPageState createState() => _UrduArabicTextSurahListPageState();
}

class _UrduArabicTextSurahListPageState extends State<UrduArabicTextSurahListPage> {
  List<dynamic> quranTextUrdu = [];
  List<dynamic> translationQuranTexturdu = [];

  Future<void> getQuranTextOnly() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('aData');
    if (cachedData != null) {
      setState(() {
      quranTextUrdu= json.decode(cachedData)['data']['surahs'];
      });
    }
    else{
      final response = await http.get(Uri.parse("https://api.alquran.cloud/v1/quran/quran-uthmani"));
      if (response.statusCode == 200) {
        setState(() {
          quranTextUrdu = json.decode(response.body)['data']['surahs'];
        });
        await prefs.setString('aData', response.body);
      } else {
        throw Exception('Failed to load data');
      }
    }

  }
  Future<void> getQuranTransOnly() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('urduData');
    if (cachedData != null) {
      setState(() {
        translationQuranTexturdu= json.decode(cachedData)['data']['surahs'];
      });
    }
    else{
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/quran/ur.ahmedali'));
      if (response.statusCode == 200) {
        setState(() {
          translationQuranTexturdu= json.decode(response.body)['data']['surahs'];
        });
        await prefs.setString('urduData', response.body);
      } else {
        throw Exception('Failed to load Quran data');
      }
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
          title: const Text('Urdu-Quran'),
        ),
        body: quranTextUrdu.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: quranTextUrdu.length,

          itemBuilder: (context, index) {
            final uthmanisurah = quranTextUrdu[index];
            final translationData=translationQuranTexturdu[index];
            return Card(

              color: gridContainerColor,
              child: ListTile(


                title: Text('Surah ${quranTextUrdu[index]["number"]}: ${quranTextUrdu[index]["englishName"]}'),
                subtitle: Text(' ${quranTextUrdu[index]["ayahs"].length} Verses-${quranTextUrdu[index]['revelationType']}'),
                trailing: Text('${quranTextUrdu[index]['name']}-${quranTextUrdu[index]['englishNameTranslation']}'),
                leading: Container(
                  alignment: Alignment.center,
                  height: 30,
                  width: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: gridContainerColor,
                  ),
                  child: Text(
                    quranTextUrdu[index]['number'].toString(),
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
                      builder: (context) =>  UrduArabicTextPage(ayahs: uthmanisurah['ayahs'], ayahstext: translationData ['ayahs'], surahEnglishName: uthmanisurah['englishName'], numberInSurah: uthmanisurah['ayahs'], surahEnglishNameT: uthmanisurah['englishName'], numberInSurahT: uthmanisurah['ayahs'],  ),
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
