import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_quran/quran_translation_package/translations_model_class.dart';

import '../dropdown_class/translator_list.dart';
import '../provider/theme_provider.dart';

import 'organized_translationAyah.dart';

class QuranTranslationListPage extends StatefulWidget {
  const QuranTranslationListPage({super.key});

  @override
  _QuranTranslationListPageState createState() => _QuranTranslationListPageState();
}

class _QuranTranslationListPageState extends State<QuranTranslationListPage> {
  List<TranslationSurahClass> quranTranslateData = [];
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
      String? cachedData = prefs.getString('translationData');

      if (cachedData != null) {
        setState(() {
          quranTranslateData = (json.decode(cachedData)["data"]["surahs"] as List)
              .map((item) => TranslationSurahClass.fromJson(item))
              .toList();
        });
      } else {
        final response = await http.get(Uri.parse("https://api.alquran.cloud/v1/quran/en.ahmedali"));

        if (response.statusCode == 200) {
          final data = json.decode(response.body)['data']['surahs'] as List;
          setState(() {
            quranTranslateData = data.map((item) => TranslationSurahClass.fromJson(item)).toList();
            isLoading = false;
          });
          await prefs.setString('translationData', response.body);
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
  // Method to fetch translation based on selected reciter
  Future<void> getQuranTranslationReciter(String reciter) async {
    setState(() => isLoading = true);
    final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/quran/$reciter'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data']['surahs'] as List;
      setState(() {
        quranTranslateData = data.map((item) => TranslationSurahClass.fromJson(item)).toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load Quran data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkTheme = themeNotifier.themeModeNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Translation'),
        //backgroundColor: isDarkTheme ? Colors.black87 : Colors.teal,
      ),
      body: quranTranslateData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkTheme ? Colors.black54 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButton<TranslatorName>(
                  value: selectedTranslator,
                  hint: const Text("Select Language/Translator"),
                  //icon: const Icon(Icons.translate, color: Colors.teal),
                  dropdownColor: isDarkTheme ? Colors.black54 : Colors.white,
                  style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black87),
                  isExpanded: true, // Fix overflow
                    onChanged: (TranslatorName? reciter) {
                      if (reciter != null) {
                        setState(() {
                          selectedTranslator = reciter;
                          quranTranslateData.clear();

                        });
                        getQuranTranslationReciter(reciter.text);
                      }
                    },
                  items: TranslatorName.values.map((TranslatorName translator) {
                    return DropdownMenuItem<TranslatorName>(
                      value: translator,
                      child: Text(
                        translator.label,
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black,fontSize: 20
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: quranTranslateData.length,
              itemBuilder: (context, index) {
                final surah = quranTranslateData[index];
                return Card(
                  color: isDarkTheme ? Colors.grey : Colors.white,
                  child: ListTile(
                    title: Text(
                      'Page ${surah.ayahsEA.first.page}: ${surah.englishNameTranslation}',
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
                      '${surah.englishName}\n${surah.englishNameTranslation}',
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
                          builder: (context) => OrganizedTranslationAyahViewScreen(
                            initialPage: surah.ayahsEA.first.page - 1,
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
        ],
      ),
    );
  }
}
