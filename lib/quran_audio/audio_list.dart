import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_complete_ui/quran_translation_package/quran_translation_text.dart';

import '../constant.dart';
import '../reciter_class/reciter_list.dart';
import 'audio_player.dart';

class AudioQuranListPage extends StatefulWidget {
  const AudioQuranListPage({super.key});

  @override
  _AudioQuranListPageState createState() => _AudioQuranListPageState();
}

class _AudioQuranListPageState extends State<AudioQuranListPage> {
  List<dynamic> quranTranslateData = [];
  final TextEditingController colorController = TextEditingController();

  TranslatorName? selectedReciter;
  int activePage = 1;

  @override
  void initState() {
    super.initState();

    getQuranAudio();
  }

  Future<void> getQuranAudio() async {
    final response = await http
        .get(Uri.parse('https://api.alquran.cloud/v1/quran/ar.alafasy'));
    if (response.statusCode == 200) {
      setState(() {
        quranTranslateData = json.decode(response.body)['data']['surahs'];
        //activePage=json.decode(response.body)['data']['surah']['ayahs'];
      });
    } else {
      throw Exception('Failed to load Quran data');
    }
  }
  // Future<void> getQuranTranslationReciter(String reciter) async {
  //   final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/quran/$reciter'));
  //   if (response.statusCode == 200) {
  //     setState(() {
  //       quranTranslateData = json.decode(response.body)['data']['surahs'];
  //     });
  //   } else {
  //     throw Exception('Failed to load Quran data');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gridContainerColor,
      appBar: AppBar(
        backgroundColor: gridContainerColor,
      ),

      body: quranTranslateData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                DropdownMenu<TranslatorName>(
                  initialSelection: TranslatorName.AhmedAli,
                  controller: colorController,
                  // requestFocusOnTap is enabled/disabled by platforms when it is null.
                  // On mobile platforms, this is false by default. Setting this to true will
                  // trigger focus request on the text field and virtual keyboard will appear
                  // afterward. On desktop platforms however, this defaults to true.
                  requestFocusOnTap: true,
                  label: const Text('Select Translator'),
                  onSelected: (TranslatorName? reciter) {
                    setState(() {
                      selectedReciter = reciter;
                      //to change the translation
                      //getQuranTranslationReciter(colorController.text);
                    });
                  },
                  dropdownMenuEntries: TranslatorName.values
                      .map<DropdownMenuEntry<TranslatorName>>(
                          (TranslatorName reciter) {
                    return DropdownMenuEntry<TranslatorName>(
                      value: reciter,
                      label: reciter.label.toString(),
                      enabled: reciter.label != 'Grey',
                      style: MenuItemButton.styleFrom(),
                    );
                  }).toList(),
                ),
                Text(colorController.text),
                Expanded(
                  child: ListView.builder(
                    itemCount: quranTranslateData.length,
                    itemBuilder: (context, index) {
                      final translatedtext = quranTranslateData[index];
                      final utmaniayah=quranTranslateData[index];

                      return Card(
                        color: gridContainerColor,
                        child: ListTile(
                            title: Text(
                                'Surah ${quranTranslateData[index]["number"]}: ${quranTranslateData[index]["englishName"]}'),
                            subtitle: Text(
                                ' ${quranTranslateData[index]["ayahs"].length} Verses-${quranTranslateData[index]['revelationType']}'),
                            trailing: Text(
                                '${quranTranslateData[index]['name']}-${quranTranslateData[index]['englishNameTranslation']}'),
                            leading: Container(
                              alignment: Alignment.center,
                              height: 30,
                              width: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: gridContainerColor,
                              ),
                              child: Text(
                                quranTranslateData[index]['text'].toString(),
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
                                    builder: (context) => AudioQuranPage(
                                          surahEnglishName:
                                              translatedtext['englishName'],
                                          numberInSurah:
                                              translatedtext['ayahs'],
                                          audioAyahs: translatedtext['ayahs'], number:translatedtext['number'],
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
