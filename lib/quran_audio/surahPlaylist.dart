import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';



import '../dropdown_class/reciter_list.dart';
import '../model/Audio_model.dart';
import '../provider/theme_provider.dart';
import 'audio_player.dart';

class AudioSurahList extends StatefulWidget {
  const AudioSurahList({super.key});

  @override
  _AudioSurahListState createState() => _AudioSurahListState();
}

class _AudioSurahListState extends State<AudioSurahList> {
  List<Surah> audioSurahs = [];
  late AudioPlayer audioPlayer;
  TextEditingController reciterController = TextEditingController();
  ReciterName? selectedReciter;
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    getAudioReciterList();
  }
  @override
  void dispose() {
    audioPlayer.dispose(); // Dispose of audio player
    reciterController.dispose(); // Dispose of text controller
    super.dispose();
  }
  Future<void> getAudioReciterList() async {
    const String url = 'https://api.alquran.cloud/v1/quran/ar.alafasy';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data']['surahs'] as List;
        setState(() {
          audioSurahs = data.map((json) => Surah.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load');
      }
    } catch (e) {
      print("Error fetching audio for reciter: $e");
    }
  }

  Future<void> getAudioSurahList(String reciter, String ayahNumber) async {
    String url = 'https://api.alquran.cloud/v1/quran/$reciter??ar.alafasy/$ayahNumber.mp3';
    try {
      setState(() => isLoading = true);
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data']['surahs'] as List;
        setState(() {
          audioSurahs = data.map((json) => Surah.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load');
      }
    } catch (e) {
      print("Error fetching surahs: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkTheme = themeNotifier.themeModeNotifier.value == ThemeMode.dark;

    final scrollView = Platform.isIOS
        ? CupertinoScrollbar(
      child: ListView.builder(
        itemCount: audioSurahs.length,
        itemBuilder: (context, index) {
          final myAudioSurah = audioSurahs[index];
          return ListTile(
            title: Text(
              '${myAudioSurah.number}: ${myAudioSurah.englishName}',
              style: const TextStyle(color: Colors.amber),
            ),
            subtitle: Text(myAudioSurah.name),
            trailing: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(Icons.play_arrow, color: Colors.green),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SurahAudioPage(surah: myAudioSurah),
                ),
              );
            },
          );
        },
      ),
    )
        : Scrollbar(
      child: ListView.builder(
        itemCount: audioSurahs.length,
        itemBuilder: (context, index) {
          final myAudioSurah = audioSurahs[index];
          return ListTile(
            title: Text(
              '${myAudioSurah.number}: ${myAudioSurah.englishName}',
              style: const TextStyle(color: Colors.amber),
            ),
            subtitle: Text(myAudioSurah.name),
            trailing: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(Icons.play_arrow, color: Colors.green),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SurahAudioPage(surah: myAudioSurah),
                ),
              );
            },
          );
        },
      ),
    );

    return Scaffold(
      backgroundColor: isDarkTheme ? Colors.black87 : Colors.teal,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const BackButton(),
        title: const Text('Audio Quran'),
      ),
      body: audioSurahs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 60,
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return DropdownButton<ReciterName>(
                    value: selectedReciter,
                    dropdownColor: isDarkTheme ? Colors.black54 : Colors.white,
                    hint: Text(
                      "Select Reciter",
                      style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black),
                    ),
                    style: TextStyle(
                        color: isDarkTheme ? Colors.white : Colors.black87),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_downward, color: Colors.amberAccent),
                    onChanged: (ReciterName? reciter) {
                      setState(() {
                        selectedReciter = reciter;
                      });
                      final myAudioSurah=audioSurahs[index].ayahs[index].audio;
                      getAudioSurahList(selectedReciter!.text, myAudioSurah.toString());
                    },
                    items: ReciterName.values
                        .map<DropdownMenuItem<ReciterName>>(
                            (ReciterName reciter) {
                          return DropdownMenuItem<ReciterName>(
                            value: reciter,
                            child: Text(
                              reciter.label,
                              style: TextStyle(
                                color: isDarkTheme ? Colors.white : Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                  );
                },


              ),
            ),
          ),
          const SizedBox(height: 5),
          Expanded(child: scrollView),
        ],
      ),
    );
  }


}
