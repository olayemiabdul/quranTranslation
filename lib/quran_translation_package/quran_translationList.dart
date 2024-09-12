import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_complete_ui/quran_translation_package/quran_translation_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import '../dropdown_class/translator_list.dart';

class QuranTranslationListPage extends StatefulWidget {
  const QuranTranslationListPage({super.key});

  @override
  _QuranTranslationListPageState createState() =>
      _QuranTranslationListPageState();
}

class _QuranTranslationListPageState extends State<QuranTranslationListPage> {
  List<dynamic> quranTranslateData = [];
  final TextEditingController colorController = TextEditingController();

  TranslatorName? selectedTranslator;

  @override
  void initState() {
    super.initState();

    // getQuranTranslationData();
    getQuranText();
  }




  //without offline access
  Future<void> getQuranTranslationData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('mainData');
    if (cachedData != null) {
      setState(() {
        quranTranslateData = json.decode(cachedData)["data"]["surahs"];
      });
    }
  else{
      final response = await http
          .get(Uri.parse('https://api.alquran.cloud/v1/quran/en.ahmedali'));
      if (response.statusCode == 200) {
        setState(() {
          quranTranslateData = json.decode(response.body)['data']['surahs'];
        });
        await prefs.setString('mainData', response.body);
      } else {
        throw Exception('Failed to load Quran data');
      }
    }
  }
  // with shared pref for offline
  Future<void> getQuranText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('translationData');

    if (cachedData != null) {
      setState(() {
        quranTranslateData = json.decode(cachedData)["data"]["surahs"];
      });
    }
    else {
      final response = await http.get(Uri.parse("https://api.alquran.cloud/v1/quran/en.ahmedali"));
      if (response.statusCode == 200) {
        setState(() {
          quranTranslateData = json.decode(response.body)["data"]["surahs"];
        });
        await prefs.setString('translationData', response.body);
      } else {
        throw Exception('Failed to load data');
      }
    }
  }

  Future<void> getQuranTranslationReciter(String reciter) async {
    final response = await http
        .get(Uri.parse('https://api.alquran.cloud/v1/quran/$reciter'));
    if (response.statusCode == 200) {
      setState(() {
        quranTranslateData = json.decode(response.body)['data']['surahs'];
      });
    } else {
      throw Exception('Failed to load Quran data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Translation'),
      ),
      backgroundColor: gridContainerColor,
      body: quranTranslateData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(
                  height: 60,
                ),
                DropdownMenu<TranslatorName>(
                  requestFocusOnTap: true,
                  width: 300,
                  menuStyle: MenuStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(gridContainerColor),
                  ),
                  enableFilter: true,
                  textStyle: TextStyle(color: Colors.amberAccent),
                  enableSearch: true,
                  //initialSelection: TranslatorName.values.first,
                  controller: colorController,
                  // requestFocusOnTap is enabled/disabled by platforms when it is null.
                  // On mobile platforms, this is false by default. Setting this to true will
                  // trigger focus request on the text field and virtual keyboard will appear
                  // afterward. On desktop platforms however, this defaults to true.
                  //requestFocusOnTap: true,
                  label: const Text('Select Language/Translator'),
                  onSelected: (TranslatorName? reciter) {
                    setState(() {
                      selectedTranslator = reciter;
                      //to change the translation

                    });
                    getQuranTranslationReciter(selectedTranslator!.text);
                  },
                  dropdownMenuEntries: TranslatorName.values
                      .map<DropdownMenuEntry<TranslatorName>>(
                          (TranslatorName reciter) {
                    return DropdownMenuEntry<TranslatorName>(
                      value: reciter,
                      label: reciter.label.toString(),
                      enabled: reciter.label != 'Grey',
                      //leadingIcon: Icon(Icons.search, color: Colors.white,),
                      style: MenuItemButton.styleFrom(
                        backgroundColor: gridContainerColor,
                      ),
                    );
                  }).toList(),
                ),
                //Text(colorController.text),
                Expanded(
                  child: ListView.builder(
                    itemCount: quranTranslateData.length,
                    itemBuilder: (context, index) {
                      final translatedtext = quranTranslateData[index];
                      //final utmaniayah=quranData[index]

                      return Card(
                        color: gridContainerColor,
                        child: ListTile(
                            title: Text(
                                'Surah ${quranTranslateData[index]["number"]}: ${quranTranslateData[index]["englishName"]}'),
                            subtitle: Text(
                                ' ${quranTranslateData[index]["ayahs"].length} Verses-${quranTranslateData[index]['revelationType']}'),
                            trailing: Text(
                              '${quranTranslateData[index]['name']}\n ${quranTranslateData[index]['englishNameTranslation']}',
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
                                quranTranslateData[index]['number'].toString(),
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
                                    builder: (context) =>
                                        QuranTranslationTextPage(
                                          translatedAyahs:
                                              translatedtext['ayahs'],
                                          surahEnglishName:
                                              translatedtext['englishName'],
                                          numberInSurah:
                                              translatedtext['ayahs'],
                                        )),
                              );
                            }),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
