import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_complete_ui/quran_translation_package/quran_translation_text.dart';

import '../constant.dart';
import '../reciter_class/reciter_list.dart';

class QuranTranslationListPage extends StatefulWidget {
  const QuranTranslationListPage({super.key});

  @override
  _QuranTranslationListPageState createState() =>
      _QuranTranslationListPageState();
}

class _QuranTranslationListPageState extends State<QuranTranslationListPage> {
  List<dynamic> quranTranslateData = [];
  final TextEditingController colorController = TextEditingController();

  TranslatorName? selectedReciter;

  @override
  void initState() {
    super.initState();

    getQuranTranslationData();
  }

  String? _selectedAuthor;

  final List<DropdownMenuItem<String>> _authors = [
    const DropdownMenuItem(
      value: 'AhmedAli',
      child: Text('AhmedAli (en.ahmedali)'),
    ),
    const DropdownMenuItem(
      value: 'Muhiuddin',
      child: Text('Muhiuddin (bn.bengali)'),
    ),
    const DropdownMenuItem(
      value: 'VasimMammadaliyevandZiyaBunyadov',
      child: Text('VasimMammadaliyevandZiyaBunyadov (az.mammadaliyev)'),
    ),
    const DropdownMenuItem(
      value: 'Alikhan',
      child: Text('Alikhan (az.musayev)'),
    ),
    const DropdownMenuItem(
      value: 'Prekled',
      child: Text('Prekled (cs.hrbek)'),
    ),
  ];

  Future<void> getQuranTranslationData() async {
    final response = await http
        .get(Uri.parse('https://api.alquran.cloud/v1/quran/en.ahmedali'));
    if (response.statusCode == 200) {
      setState(() {
        quranTranslateData = json.decode(response.body)['data']['surahs'];
      });
    } else {
      throw Exception('Failed to load Quran data');
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
                        MaterialStateProperty.all<Color>(gridContainerColor),
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
                      selectedReciter = reciter;
                      //to change the translation
                      getQuranTranslationReciter(selectedReciter!.text);
                    });
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
