// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';
//
// import '../constant.dart';
// import '../model/Audio_model.dart';
// import 'package:intl/intl.dart';
// class SurahAudioPage extends StatefulWidget {
//   final Surah surah;
//
//   const SurahAudioPage({super.key, required this.surah});
//
//   @override
//   _SurahAudioPageState createState() => _SurahAudioPageState();
// }
//
// class _SurahAudioPageState extends State<SurahAudioPage> {
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
//
//
//
//     audioPlayer = AudioPlayer();
//     audioUrls =
//         widget.surah.ayahs.map((ayah) => ayah.audio.toString()).toList();
//     audioPlayer.onPlayerStateChanged.listen((state) {
//       setState(() {
//         isPlaying = state == PlayerState.playing;
//       });
//     });
//     audioPlayer.onDurationChanged.listen((newDuration) {
//       setState(() {
//         duration=newDuration;
//       });
//     });
//     audioPlayer.onPositionChanged.listen((newPosition) {
//       setState(() {
//         position=newPosition;
//       });
//     });
//
//   }
//
//
//   Future<void> playSurah() async {
//     setState(() {
//       isPlaying = true;
//     });
//
//
//     audioPlayer.onPlayerComplete.listen((_) {
//       if (currentIndex < audioUrls.length - 1) {
//         currentIndex++;
//         playAudio();
//       } else {
//         setState(() {
//           isPlaying = false;
//           // to bring back down
//           currentIndex = 0;
//         });
//       }
//     });
//
//
//     playAudio();
//   }
//
//   Future<void> playAudio() async {
//     String url = audioUrls[currentIndex];
//     await audioPlayer.play(
//       UrlSource(url),
//     );
//   }
//   Future<void> seek(Duration position) async {
//     await audioPlayer.seek(position);
//   }
//
//   Future<void> stop() async {
//     await audioPlayer.stop();
//   }
//   @override
//   void dispose() {
//     audioPlayer.dispose();
//     super.dispose();
//   }
//
//   String formatTime(Duration duration) {
//     String twoDigits(int n)=>n.toString().padLeft(2, '0');
//     final hours=twoDigits(duration.inHours);
//     final minutes=twoDigits(duration.inMinutes.remainder(60));
//     final seconds=twoDigits(duration.inSeconds.remainder(60));
//     return [
//       if(duration.inHours>0)hours,
//       minutes, seconds,
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
//
//             // opacity: 13,
//             // colorFilter: ColorFilter.mode(
//             //     Colors.white.withOpacity(0.4), BlendMode.dstATop),
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
//
//             Slider(
//
//               value: position.inSeconds.toDouble(),
//               min: 0,
//
//               //max: duration.inSeconds.toDouble(), use 20s to avoid range error
//               max: 4600,
//
//               onChanged: (value) async {
//                 final position=Duration(seconds: value.toInt());
//                 await audioPlayer.seek(position);
//                 await audioPlayer.resume();
//               },
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 50),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(formatTime(position)),
//                   Text(formatTime(duration-position)),
//
//                 ],),
//             ),
//             const SizedBox(height: 20,),
//             Padding(
//               padding: const EdgeInsets.only(left: 100),
//               child: Row(
//                 children: [
//                   Center(
//                     child: TextButton(
//                         onPressed: () {
//                           if (currentIndex>0){
//                             currentIndex--;
//                             stop();
//                             playSurah();
//                           }
//
//
//
//
//
//                         },
//                         child: const Icon(Icons.skip_previous, size: 40,)
//                       //child: Text(isPlaying ? 'Stop/Pause' : 'Play Surah'),
//                     ),
//                   ),
//                   IconButton(onPressed:(
//
//                       ){
//                     if(isPlaying){
//                       audioPlayer.pause();
//                       setState(() {
//                         isPlaying=false;
//                       });
//                     }else {
//                       playSurah();
//                     }
//                   },  icon: Container(
//                       decoration:  BoxDecoration(
//                         color: Colors.green,
//
//                         borderRadius: BorderRadius.circular(30),
//                         //color:gridContainerColor,
//                       ),
//                       child: Icon(isPlaying ? Icons.pause : Icons.play_arrow)),iconSize: 50,),
//                   IconButton(
//                     onPressed: () {
//                       if (currentIndex < audioUrls.length - 1) {
//                         currentIndex++;
//                         //stop();
//                         playSurah();
//                       }
//                     },
//                     icon: const Icon(Icons.skip_next, size: 40,),
//                   ),
//
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
// }
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../constant.dart';
import '../model/Audio_model.dart';

class SurahAudioPage extends StatefulWidget {
  final Surah surah;

  const SurahAudioPage({super.key, required this.surah});

  @override
  _SurahAudioPageState createState() => _SurahAudioPageState();
}

class _SurahAudioPageState extends State<SurahAudioPage> {
  AudioPlayer audioPlayer = AudioPlayer();
  late List<String> audioUrls;
  int currentIndex = 0;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    audioUrls = widget.surah.ayahs.map((ayah) => ayah.audio.toString()).toList();

    audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          duration = newDuration;
        });
      }
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          position = newPosition;
        });
      }
    });

    audioPlayer.onPlayerComplete.listen((_) {
      if (currentIndex < audioUrls.length - 1) {
        currentIndex++;
        playAudio();
      } else {
        if (mounted) {
          setState(() {
            isPlaying = false;
            currentIndex = 0;
          });
        }
      }
    });
  }

  Future<void> playSurah() async {
    playAudio();
  }

  Future<void> playAudio() async {
    try {
      String url = audioUrls[currentIndex];
      await audioPlayer.play(UrlSource(url));
    } catch (e) {
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
      // Handle error gracefully
    }
  }
  Future<void> stop() async {
   await audioPlayer.stop();
  }
  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.name),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/mosque2.png',
            ),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
          color: Colors.white,
        ),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Container(
              height: 200,
              width: 350,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                color: gridContainerColor,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 130),
                        child: Text(widget.surah.number.toString()),
                      ),
                      Text('- ${widget.surah.englishName}'),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    widget.surah.name,
                    style: const TextStyle(
                      wordSpacing: 2,
                      fontFamily: 'Kitab-Bold',
                      color: Colors.white,
                      fontSize: 46,
                    ),
                  ),
                ],
              ),
            ),
            Slider(
              value: position.inSeconds.toDouble(),
              min: 0,
              max: 3600,
              onChanged: (value) async {
                final newPosition = Duration(seconds: value.toInt());
                await audioPlayer.seek(newPosition);
                await audioPlayer.resume();
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatTime(position)),
                  Text(formatTime(duration - position)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 100),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      if (currentIndex > 0) {
                        currentIndex--;
                        stop();
                        playSurah();
                      }
                    },
                    child: const Icon(Icons.skip_previous, size: 40),
                  ),
                  IconButton(
                    onPressed: () {
                      if (isPlaying) {
                        audioPlayer.pause();
                        setState(() {
                          isPlaying = false;
                        });
                      } else {
                        playSurah();
                      }
                    },
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    ),
                    iconSize: 50,
                  ),
                  IconButton(
                    onPressed: () {
                      if (currentIndex < audioUrls.length - 1) {
                        currentIndex++;
                        playSurah();
                      }
                    },
                    icon: const Icon(Icons.skip_next, size: 40),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
