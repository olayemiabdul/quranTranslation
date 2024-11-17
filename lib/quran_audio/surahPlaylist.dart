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
import 'package:provider/provider.dart';
import 'package:quran_complete_ui/constant.dart';
import 'package:quran_complete_ui/dropdown_class/reciter_list.dart';





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
  TextEditingController reciterController=TextEditingController();
  ReciterName? selectedReciter;
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getAudioReciterList();

    //audioPlayer = AudioPlayer();
  }

  Future<void> getAudioReciterList() async {



      const String url='https://api.alquran.cloud/v1/quran/ar.alafasy';
   try{
     final response = await http.get(
         Uri.parse(url));
     if (response.statusCode == 200) {
       final data = json.decode(response.body)['data']['surahs'] as List;
       setState(() {
         audioSurahs = data.map((json) => Surah.fromJson(json)).toList();
          isLoading = false;
       });

     } else {
       throw Exception('Failed to load');
     }
   }catch (e){
     print("Error fetching audio for reciter: $e");
   }

  }
  Future<void> getAudioSurahList(String reciter, String ayahNumber) async {


      String url='https://api.alquran.cloud/v1/quran/$reciter??ar.alafasy/$ayahNumber.mp3';
      try{
        setState(() => isLoading = true);
        final response = await http.get(
            Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body)['data']['surahs'] as List;
          setState(() {
            audioSurahs = data.map((json) => Surah.fromJson(json)).toList();
            isLoading = false;
          });

        } else {
          throw Exception('Failed to load');
        }
      } catch(e){
        print("Error fetching surahs: $e");
      }

  }


  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkTheme = themeNotifier.themeModeNotifier.value == ThemeMode.dark;
    return Scaffold(
      backgroundColor: isDarkTheme ? Colors.black87 : Colors.teal,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const BackButton(

        ),
        title: const Text('Audio Quran'),
      ),
      body:audioSurahs.isEmpty?const Center(child: CircularProgressIndicator()): Column(
        children: [
          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(height: 60,
              child: ListView.builder(
                itemCount: 1,

                itemBuilder: (BuildContext context, int index) {

                  return   Padding(
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
                        child: DropdownButton<ReciterName>(
                          value: selectedReciter,
                          dropdownColor: isDarkTheme ? Colors.black54 : Colors.grey,
                          hint: Text("Select Reciter", style: TextStyle(color: isDarkTheme ? Colors.black54 : Colors.grey)),
                          style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black87),
                          isExpanded: true,


                          icon: const Icon(Icons.arrow_downward, color: Colors.amberAccent),
                          onChanged: (ReciterName? reciter) {
                            setState(() {
                              selectedReciter = reciter;


                            });
                            final myAudioSurah = audioSurahs[index].ayahs[index].audio;
                            getAudioSurahList(selectedReciter!.text,myAudioSurah.toString());
                          },
                          items: ReciterName.values.map<DropdownMenuItem<ReciterName>>((ReciterName reciter) {
                            return DropdownMenuItem<ReciterName>(
                              value: reciter,
                              child: Text(reciter.label,
                                style: TextStyle(
                                  color: isDarkTheme ? Colors.white : Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
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