// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:audioplayers/audioplayers.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Quran Audio Player',
//       home: QuranAudioPlayer(),
//     );
//   }
// }
//
// class QuranAudioPlayer extends StatefulWidget {
//   @override
//   _QuranAudioPlayerState createState() => _QuranAudioPlayerState();
// }
//
// class _QuranAudioPlayerState extends State<QuranAudioPlayer> {
//   List<dynamic> surahs = [];
//   AudioPlayer audioPlayer = AudioPlayer();
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }
//
//   Future<void> fetchData() async {
//     final response =
//     await http.get(Uri.parse('https://api.alquran.cloud/v1/quran/ar.alafasy'));
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       setState(() {
//         surahs = data['data']['surahs'];
//       });
//     } else {
//       throw Exception('Failed to load surahs');
//     }
//   }
//
//   Future<void> playSurah(String audioUrl) async {
//     int result = await audioPlayer.play(audioUrl);
//     if (result == 1) {
//       // success
//     } else {
//       throw Exception('Failed to play surah');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Quran Audio Player'),
//       ),
//       body: ListView.builder(
//         itemCount: surahs.length,
//         itemBuilder: (context, index) {
//           final surah = surahs[index];
//           final String surahName = surah['englishName'];
//           final List<dynamic> ayahs = surah['ayahs'];
//           // Joining all the audio URLs of ayahs to play the complete surah
//           final List<String> audioUrls =
//           ayahs.map((ayah) => ayah['audio']).toList();
//           return ListTile(
//             title: Text(surahName),
//             onTap: () => playSurahs(audioUrls),
//           );
//         },
//       ),
//     );
//   }
//
//   Future<void> playSurahs(List<String> audioUrls) async {
//     for (var audioUrl in audioUrls) {
//       int result = await audioPlayer.play(Ur);
//       if (result != 1) {
//         throw Exception('Failed to play surah');
//       }
//       // Wait for each ayah to finish playing before playing the next one
//       await Future.delayed(Duration(seconds: 3)); // Adjust this delay as needed
//     }
//   }
//
//   @override
//   void dispose() {
//     audioPlayer.dispose();
//     super.dispose();
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:quran_complete_ui/constant.dart';
import 'package:quran_complete_ui/dropdown_class/reciter_list.dart';





import '../model/Audio_model.dart';
import 'audio_player.dart';





class AudioSurahList extends StatefulWidget {
  const AudioSurahList({super.key});

  @override
  _AudioSurahListState createState() => _AudioSurahListState();
}

class _AudioSurahListState extends State<AudioSurahList> {
  List<Surah> audioSurahs = [];
  late AudioPlayer audioPlayer;
  TextEditingController reciterController=TextEditingController();
  ReciterName? selectedReciter;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    getAudioReciterList();

    //audioPlayer = AudioPlayer();
  }

  Future<void> getAudioReciterList() async {



      const String url='https://api.alquran.cloud/v1/quran/ar.alafasy';
      final response = await http.get(
          Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data']['surahs'] as List;
        setState(() {
          audioSurahs = data.map((json) => Surah.fromJson(json)).toList();
        });

      } else {
        throw Exception('Failed to load');
      }

  }
  Future<void> getAudioSurahList(String reciter, String ayahNumber) async {


      String url='https://api.alquran.cloud/v1/quran/$reciter??ar.alafasy/$ayahNumber.mp3';
      final response = await http.get(
          Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data']['surahs'] as List;
        setState(() {
          audioSurahs = data.map((json) => Surah.fromJson(json)).toList();
        });

      } else {
        throw Exception('Failed to load');
      }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gridContainerColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const BackButton(

        ),
        title: const Text('Audio Quran'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(height: 60,
              child: ListView.builder(
                itemCount: 1,

                itemBuilder: (BuildContext context, int index) {
                  return   DropdownMenu<ReciterName >(
                    initialSelection: ReciterName.alminshawi,
                    controller: reciterController,
                    requestFocusOnTap: true,
                    width: 300,
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          gridContainerColor),
                    ),
                    enableFilter: true,
                    textStyle: const TextStyle(color: Colors.amberAccent),
                    enableSearch: true,
                    label: const Text('Select Language/Reciter'),
                    onSelected: (ReciterName? reciter) {
                      setState(() {
                        selectedReciter = reciter ;


                      });
                      //to change the reciter
                      final myAudioSurah = audioSurahs[index].ayahs[index].audio;
                      getAudioSurahList(selectedReciter!.text,myAudioSurah.toString());
                    },
                    dropdownMenuEntries: ReciterName.values
                        .map<DropdownMenuEntry<ReciterName>>(
                            (ReciterName reciter) {
                          return DropdownMenuEntry<ReciterName>(
                            value: reciter,
                            label: reciter.label.toString(),
                            enabled: reciter.label != 'Grey',
                            style: MenuItemButton.styleFrom(

                            ),
                          );
                        }).toList(),
                  );
                },

              ),
            ),
          ),
        const  SizedBox(height: 5,),
          Expanded(

            child: ListView.builder(
              itemCount: audioSurahs.length,
              itemBuilder: (context, index) {
                final myAudioSurah = audioSurahs[index];
                return ListTile(
                  title: Text('${myAudioSurah.number}: ${myAudioSurah.englishName}', style: const TextStyle(color: Colors.amber),),

                  subtitle: Text(myAudioSurah.name),
                  trailing: Container(
                    decoration:  BoxDecoration(
                      // color: Colors.green,

                      borderRadius: BorderRadius.circular(30),
                      //color:gridContainerColor,
                    ),

                    child: const Icon(Icons.play_arrow, color: Colors.green,),
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}