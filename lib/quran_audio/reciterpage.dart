// // // import 'package:audioplayers/audioplayers.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:quran_complete_ui/reciter_class/reciter_list.dart';
// // //
// // // import '../constant.dart';
// // // import '../model/Audio_model.dart';
// // // import 'package:intl/intl.dart';
// // // class SurahAudioPage extends StatefulWidget {
// // //   final Surah surah;
// // //
// // //   const SurahAudioPage({Key? key, required this.surah}) : super(key: key);
// // //
// // //   @override
// // //   _SurahAudioPageState createState() => _SurahAudioPageState();
// // // }
// // //
// // // class _SurahAudioPageState extends State<SurahAudioPage> {
// // //   AudioPlayer audioPlayer = AudioPlayer();
// // //   late List<String> audioUrls;
// // //   int currentIndex = 0;
// // //   bool isPlaying = false;
// // //   Duration duration = Duration.zero;
// // //   Duration position = Duration.zero;
// // //   ReciterName? selectedReciter;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //
// // //
// // //     // void updateAudioUrls() {
// // //     //   audioUrls = widget.surah.ayahs.map((ayah) {
// // //     //     return 'https://api.alquran.cloud/v1/quran/${selectedReciter.text}/${ayah['number']}.mp3';  // Update this URL format as per your backend setup
// // //     //   }).toList();
// // //     // }
// // //
// // //     audioPlayer = AudioPlayer();
// // //     audioUrls =
// // //         widget.surah.ayahs.map((ayah) => ayah['audio'] as String).toList();
// // //     // audioUrls = widget.surah.ayahs.map((ayah) {
// // //     //
// // //     //   return 'https://api.alquran.cloud/v1/quran/${selectedReciter!.text}/${ayah['number']}.mp3';  // Update this URL format as per your backend setup
// // //     // }).toList();
// // //     audioPlayer.onPlayerStateChanged.listen((state) {
// // //       setState(() {
// // //         isPlaying = state == PlayerState.playing;
// // //       });
// // //     });
// // //     audioPlayer.onDurationChanged.listen((newDuration) {
// // //       setState(() {
// // //         duration=newDuration;
// // //       });
// // //     });
// // //     audioPlayer.onPositionChanged.listen((newPosition) {
// // //       setState(() {
// // //         position=newPosition;
// // //       });
// // //     });
// // //
// // //   }
// // //
// // //
// // //   Future<void> playSurah() async {
// // //     setState(() {
// // //       isPlaying = true;
// // //     });
// // //
// // //
// // //     audioPlayer.onPlayerComplete.listen((_) {
// // //       if (currentIndex < audioUrls.length - 1) {
// // //         currentIndex++;
// // //         playAudio();
// // //       } else {
// // //         setState(() {
// // //           isPlaying = false;
// // //           // to bring back down
// // //           currentIndex = 0;
// // //         });
// // //       }
// // //     });
// // //
// // //
// // //     playAudio();
// // //   }
// // //
// // //   Future<void> playAudio() async {
// // //     String url = audioUrls[currentIndex];
// // //     await audioPlayer.play(
// // //       UrlSource(url),
// // //     );
// // //   }
// // //   Future<void> seek(Duration position) async {
// // //     await audioPlayer.seek(position);
// // //   }
// // //
// // //   Future<void> stop() async {
// // //     await audioPlayer.stop();
// // //   }
// // //   @override
// // //   void dispose() {
// // //     audioPlayer.dispose();
// // //     super.dispose();
// // //   }
// // //
// // //   String formatTime(Duration duration) {
// // //     String twoDigits(int n)=>n.toString().padLeft(2, '0');
// // //     final hours=twoDigits(duration.inHours);
// // //     final minutes=twoDigits(duration.inMinutes.remainder(60));
// // //     final seconds=twoDigits(duration.inSeconds.remainder(60));
// // //     return [
// // //       if(duration.inHours>0)hours,
// // //       minutes, seconds,
// // //     ].join(':');
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text(widget.surah.name),
// // //       ),
// // //       body: Container(
// // //         height: MediaQuery.of(context).size.height,
// // //         decoration: const BoxDecoration(
// // //           image: DecorationImage(
// // //             image: AssetImage(
// // //               'assets/images/mosque2.png',
// // //             ),
// // //             fit: BoxFit.cover,
// // //
// // //             // opacity: 13,
// // //             // colorFilter: ColorFilter.mode(
// // //             //     Colors.white.withOpacity(0.4), BlendMode.dstATop),
// // //           ),
// // //           borderRadius: BorderRadius.only(
// // //               topLeft: Radius.circular(20),
// // //               topRight: Radius.circular(20),
// // //               bottomLeft: Radius.circular(50),
// // //               bottomRight: Radius.circular(50)),
// // //           color: Colors.white,
// // //         ),
// // //         child: Column(
// // //           children: [
// // //             const SizedBox(
// // //               height: 50,
// // //             ),
// // //             Container(
// // //               height: 200,
// // //               width: 350,
// // //               decoration: const BoxDecoration(
// // //                 borderRadius: BorderRadius.only(
// // //                     topLeft: Radius.circular(20),
// // //                     topRight: Radius.circular(20),
// // //                     bottomLeft: Radius.circular(50),
// // //                     bottomRight: Radius.circular(50)),
// // //                 color: gridContainerColor,
// // //               ),
// // //               child: Column(
// // //                 children: [
// // //                   const SizedBox(
// // //                     height: 10,
// // //                   ),
// // //                   Row(
// // //                     children: [
// // //                       Padding(
// // //                         padding: const EdgeInsets.only(left: 130),
// // //                         child: Text(widget.surah.number.toString()),
// // //                       ),
// // //                       Text('- ${widget.surah.englishName}'),
// // //                     ],
// // //                   ),
// // //                   const SizedBox(
// // //                     height: 30,
// // //                   ),
// // //                   Text(
// // //                     widget.surah.name,
// // //                     style: const TextStyle(
// // //                         wordSpacing: 2,
// // //                         fontFamily: 'Kitab-Bold',
// // //                         color: Colors.white,
// // //                         fontSize: 46),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //
// // //             Slider(
// // //
// // //               value: position.inSeconds.toDouble(),
// // //               min: 0,
// // //
// // //               //max: duration.inSeconds.toDouble(), use 20s to avoid range error
// // //               max: 20,
// // //
// // //               onChanged: (value) async {
// // //                 final position=Duration(seconds: value.toInt());
// // //                 await audioPlayer.seek(position);
// // //                 await audioPlayer.resume();
// // //               },
// // //             ),
// // //             Padding(
// // //               padding: const EdgeInsets.symmetric(horizontal: 50),
// // //               child: Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                 children: [
// // //                   Text(formatTime(position)),
// // //                   Text(formatTime(duration-position)),
// // //
// // //               ],),
// // //             ),
// // //             const SizedBox(height: 20,),
// // //             Padding(
// // //               padding: const EdgeInsets.only(left: 100),
// // //               child: Row(
// // //                 children: [
// // //                   Center(
// // //                     child: TextButton(
// // //                       onPressed: () {
// // //                         if (currentIndex>0){
// // //                           currentIndex--;
// // //                           stop();
// // //                           playSurah();
// // //                         }
// // //
// // //
// // //
// // //
// // //
// // //                       },
// // //                         child: const Icon(Icons.skip_previous, size: 40,)
// // //                       //child: Text(isPlaying ? 'Stop/Pause' : 'Play Surah'),
// // //                     ),
// // //                   ),
// // //                   IconButton(onPressed:(
// // //
// // //                       ){
// // //                     if(isPlaying){
// // //                       audioPlayer.pause();
// // //                       setState(() {
// // //                         isPlaying=false;
// // //                       });
// // //                     }else {
// // //                       playSurah();
// // //                     }
// // //                   },  icon: Container(
// // //                       decoration:  BoxDecoration(
// // //                         color: Colors.green,
// // //
// // //                         borderRadius: BorderRadius.circular(30),
// // //                         //color:gridContainerColor,
// // //                       ),
// // //                       child: Icon(isPlaying ? Icons.pause : Icons.play_arrow)),iconSize: 50,),
// // //                   IconButton(
// // //                     onPressed: () {
// // //                       if (currentIndex < audioUrls.length - 1) {
// // //                         currentIndex++;
// // //                         //stop();
// // //                         playSurah();
// // //                       }
// // //                     },
// // //                     icon: const Icon(Icons.skip_next, size: 40,),
// // //                   ),
// // //
// // //                 ],
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //
// // // }
// // //
// // import 'package:audioplayers/audioplayers.dart';
// // import 'package:flutter/material.dart';
// //
// // class AudioQuranPage extends StatefulWidget {
// //   final String surahEnglishName;
// //   final List<dynamic> numberInSurah;
// //   final List<dynamic> audioAyahs;
// //   final int number;
// //
// //   const AudioQuranPage({
// //     Key? key,
// //     required this.surahEnglishName,
// //     required this.numberInSurah,
// //     required this.audioAyahs,
// //     required this.number,
// //   }) : super(key: key);
// //
// //   @override
// //   _AudioQuranPageState createState() => _AudioQuranPageState();
// // }
// //
// // class _AudioQuranPageState extends State<AudioQuranPage> {
// //   late AudioPlayer audioPlayer;
// //   late List<String> audioUrls;
// //   int currentIndex = 0;
// //   bool isPlaying = false;
// //   Duration duration = Duration.zero;
// //   Duration position = Duration.zero;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     audioPlayer = AudioPlayer();
// //     updateAudioUrls();
// //     audioPlayer.onPlayerStateChanged.listen((state) {
// //       setState(() {
// //         isPlaying = state == PlayerState.playing;
// //       });
// //     });
// //     audioPlayer.onDurationChanged.listen((newDuration) {
// //       setState(() {
// //         duration = newDuration;
// //       });
// //     });
// //     audioPlayer.onPositionChanged.listen((newPosition) {
// //       setState(() {
// //         position = newPosition;
// //       });
// //     });
// //   }
// //
// //   void updateAudioUrls() {
// //     audioUrls = widget.audioAyahs
// //         .map((ayah) => ayah['audio'])
// //         .where((audio) => audio != null)
// //         .cast<String>()
// //         .toList();
// //   }
// //
// //   Future<void> playSurah() async {
// //     setState(() {
// //       isPlaying = true;
// //     });
// //     audioPlayer.onPlayerComplete.listen((_) {
// //       if (currentIndex < audioUrls.length - 1) {
// //         currentIndex++;
// //         playAudio();
// //       } else {
// //         setState(() {
// //           isPlaying = false;
// //           currentIndex = 0;
// //         });
// //       }
// //     });
// //     playAudio();
// //   }
// //
// //   Future<void> playAudio() async {
// //     String url = audioUrls[currentIndex];
// //     try {
// //       await audioPlayer.play(UrlSource(url));
// //     } catch (e) {
// //       print('Error playing audio: $e');
// //     }
// //   }
// //
// //   Future<void> seek(Duration position) async {
// //     await audioPlayer.seek(position);
// //   }
// //
// //   Future<void> stop() async {
// //     await audioPlayer.stop();
// //   }
// //
// //   @override
// //   void dispose() {
// //     audioPlayer.dispose();
// //     super.dispose();
// //   }
// //
// //   String formatTime(Duration duration) {
// //     String twoDigits(int n) => n.toString().padLeft(2, '0');
// //     final hours = twoDigits(duration.inHours);
// //     final minutes = twoDigits(duration.inMinutes.remainder(60));
// //     final seconds = twoDigits(duration.inSeconds.remainder(60));
// //     return [
// //       if (duration.inHours > 0) hours,
// //       minutes,
// //       seconds,
// //     ].join(':');
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(widget.surahEnglishName),
// //       ),
// //       body: Column(
// //         children: [
// //           const SizedBox(height: 50),
// //           Text(widget.surahEnglishName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
// //           const SizedBox(height: 30),
// //           Slider(
// //             value: position.inSeconds.toDouble(),
// //             min: 0,
// //             max: duration.inSeconds.toDouble(),
// //             onChanged: (value) async {
// //               final position = Duration(seconds: value.toInt());
// //               await audioPlayer.seek(position);
// //               await audioPlayer.resume();
// //             },
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 50),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Text(formatTime(position)),
// //                 Text(formatTime(duration - position)),
// //               ],
// //             ),
// //           ),
// //           const SizedBox(height: 20),
// //           ElevatedButton(
// //             onPressed: () {
// //               isPlaying ? stop() : playSurah();
// //             },
// //             child: Text(isPlaying ? 'Stop' : 'Play'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';
//
// import '../constant.dart';
// import '../model/Audio_model.dart';
// import 'package:intl/intl.dart';
//
// class SurahAudioPageN extends StatefulWidget {
//   final Surah surah;
//
//   const SurahAudioPageN({super.key, required this.surah});
//
//   @override
//   _SurahAudioPageNState createState() => _SurahAudioPageNState();
// }
//
// class _SurahAudioPageNState extends State<SurahAudioPageN> {
//   AudioPlayer audioPlayer = AudioPlayer();
//   late List<String> audioUrls;
//   int currentIndex = 0;
//   bool isPlaying = false;
//   Duration duration = Duration.zero;
//   Duration position = Duration.zero;
//
//   @override
//   void initState() {
//     super.initState();
//
//     audioPlayer = AudioPlayer();
//     audioUrls = widget.surah.ayahs.map((ayah) => ayah.audio.toString()).toList();
//     audioPlayer.onPlayerStateChanged.listen((state) {
//       setState(() {
//         isPlaying = state == PlayerState.playing;
//       });
//     });
//     audioPlayer.onDurationChanged.listen((newDuration) {
//       setState(() {
//         duration = newDuration;
//       });
//     });
//     audioPlayer.onPositionChanged.listen((newPosition) {
//       setState(() {
//         position = newPosition;
//       });
//     });
//
//     // Keep audio playing when the app goes into the background
//     audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
//       if (state == PlayerState.completed) {
//         if (currentIndex < audioUrls.length - 1) {
//           currentIndex++;
//           playAudio();
//         } else {
//           setState(() {
//             isPlaying = false;
//             currentIndex = 0;
//           });
//         }
//       }
//     });
//   }
//
//   Future<void> playSurah() async {
//     setState(() {
//       isPlaying = true;
//     });
//
//     audioPlayer.onPlayerComplete.listen((_) {
//       if (currentIndex < audioUrls.length - 1) {
//         currentIndex++;
//         playAudio();
//       } else {
//         setState(() {
//           isPlaying = false;
//           currentIndex = 0;
//         });
//       }
//     });
//
//     playAudio();
//   }
//
//   Future<void> playAudio() async {
//     String url = audioUrls[currentIndex];
//     await audioPlayer.play(UrlSource(url));
//   }
//
//   Future<void> seek(Duration position) async {
//     await audioPlayer.seek(position);
//   }
//
//   Future<void> stop() async {
//     await audioPlayer.stop();
//   }
//
//   @override
//   void dispose() {
//     audioPlayer.dispose();
//     super.dispose();
//   }
//
//   String formatTime(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final hours = twoDigits(duration.inHours);
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return [
//       if (duration.inHours > 0) hours,
//       minutes,
//       seconds,
//     ].join(':');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.surah.name),
//       ),
//       body: Container(
//         height: MediaQuery.of(context).size.height,
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage(
//               'assets/images/mosque2.png',
//             ),
//             fit: BoxFit.cover,
//           ),
//           borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//               bottomLeft: Radius.circular(50),
//               bottomRight: Radius.circular(50)),
//           color: Colors.white,
//         ),
//         child: Column(
//           children: [
//             const SizedBox(
//               height: 50,
//             ),
//             Container(
//               height: 200,
//               width: 350,
//               decoration: const BoxDecoration(
//                 borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(20),
//                     topRight: Radius.circular(20),
//                     bottomLeft: Radius.circular(50),
//                     bottomRight: Radius.circular(50)),
//                 color: gridContainerColor,
//               ),
//               child: Column(
//                 children: [
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   Row(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(left: 130),
//                         child: Text(widget.surah.number.toString()),
//                       ),
//                       Text('- ${widget.surah.englishName}'),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 30,
//                   ),
//                   Text(
//                     widget.surah.name,
//                     style: const TextStyle(
//                         wordSpacing: 2,
//                         fontFamily: 'Kitab-Bold',
//                         color: Colors.white,
//                         fontSize: 46),
//                   ),
//                 ],
//               ),
//             ),
//             // Slider(
//             //   value: position.inSeconds.toDouble(),
//             //   min: 0,
//             //   max: duration.inSeconds.toDouble(),
//             //   onChanged: (value) async {
//             //     final position = Duration(seconds: value.toInt());
//             //     await audioPlayer.seek(position);
//             //     await audioPlayer.resume();
//             //   },
//             // ),
//             Slider(
//               value: position.inSeconds.toDouble(),
//               min: 0,
//               max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0, // Ensure max is at least 1.0
//               onChanged: (value) async {
//                 final newPosition = Duration(seconds: value.toInt());
//                 await audioPlayer.seek(newPosition);
//                 // Optionally, you can resume playing if it's paused
//                 if (!isPlaying) {
//                   await audioPlayer.resume();
//                 }
//               },
//             ),
//
//
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 50),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(formatTime(position)),
//                   Text(formatTime(duration - position)),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.only(left: 100),
//               child: Row(
//                 children: [
//                   Center(
//                     child: TextButton(
//                       onPressed: () {
//                         if (currentIndex > 0) {
//                           currentIndex--;
//                           stop();
//                           playSurah();
//                         }
//                       },
//                       child: const Icon(
//                         Icons.skip_previous,
//                         size: 40,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () {
//                       if (isPlaying) {
//                         audioPlayer.pause();
//                         setState(() {
//                           isPlaying = false;
//                         });
//                       } else {
//                         playSurah();
//                       }
//                     },
//                     icon: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.green,
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
//                     ),
//                     iconSize: 50,
//                   ),
//                   IconButton(
//                     onPressed: () {
//                       if (currentIndex < audioUrls.length - 1) {
//                         currentIndex++;
//                         playSurah();
//                       }
//                     },
//                     icon: const Icon(
//                       Icons.skip_next,
//                       size: 40,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
