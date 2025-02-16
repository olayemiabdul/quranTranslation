import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../dropdown_class/translator_list.dart';
import '../provider/theme_provider.dart';
import 'Urdu_Model_Class.dart';
import 'Urdu_Organized_ayah.dart';



class QuranUrduTranslationListPage extends StatefulWidget {
  const QuranUrduTranslationListPage({super.key});

  @override
  _QuranUrduTranslationListPageState createState() => _QuranUrduTranslationListPageState();
}

class _QuranUrduTranslationListPageState extends State<QuranUrduTranslationListPage> {
  List<UrduSurahClass> quranTranslateData = [];
  TranslatorName? selectedTranslator;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getQuranText(); // Load default translation on page load
  }



  Future<void> getQuranText() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedData = prefs.getString('UrduTranslationData');

      if (cachedData != null) {
        setState(() {
          quranTranslateData = (json.decode(cachedData)["data"]["surahs"] as List)
              .map((item) => UrduSurahClass.fromJson(item))
              .toList();
        });
      } else {
        final response = await http.get(Uri.parse("https://api.alquran.cloud/v1/quran/ur.ahmedali"));

        if (response.statusCode == 200) {
          final data = json.decode(response.body)['data']['surahs'] as List;
          setState(() {
            quranTranslateData = data.map((item) => UrduSurahClass.fromJson(item)).toList();
            isLoading = false;
          });
          await prefs.setString('UrduTranslationData', response.body);
        } else {
          throw Exception('Failed to load data');
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching Quran data: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkTheme = themeNotifier.themeModeNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('URDU Quran Translation'),
        backgroundColor: isDarkTheme ? Colors.white : Colors.teal,
      ),
      body: quranTranslateData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          :    Expanded(
        child: ListView.builder(
          itemCount: quranTranslateData.length,
          itemBuilder: (context, index) {
            final surah = quranTranslateData[index];
            return Card(
              color: isDarkTheme ? Colors.grey[850] : Colors.white,
              child: ListTile(
                title: Text(
                  'Page ${surah.ayahsUA.first.page}: ${surah.englishNameTranslation}',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  '${surah.numberOfAyahs} Verses',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.grey[300] : Colors.black87,
                  ),
                ),
                trailing: Text(
                  '${surah.name}\n${surah.englishName}',
                  style: TextStyle(
                    fontFamily: 'Kitab-Bold',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme ? Colors.cyanAccent : Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
                leading: CircleAvatar(
                  backgroundColor: isDarkTheme ? Colors.black26 : Colors.black54,
                  child: Text(
                    surah.number.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UrduOrganizedTranslationAyahViewScreen(
                        initialPage: surah.ayahsUA.first.page - 1,
                        surahs: quranTranslateData,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
