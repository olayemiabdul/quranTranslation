
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../constant.dart';
class AudioQuranPage extends StatefulWidget {
  final List<dynamic> audioAyahs;

  final String surahEnglishName;// to request for the appbar title from quran_list page
  final List<dynamic> numberInSurah;// to request for the appbar title from quran_list page
  final int number;
  const AudioQuranPage({super.key, required this.audioAyahs, required this.surahEnglishName, required this.numberInSurah, required this.number});

  @override
  State<AudioQuranPage> createState() => _AudioQuranPageState();
}

class _AudioQuranPageState extends State<AudioQuranPage> {
  ArabicNumbers  arabicNumber=ArabicNumbers();
  final player=AudioPlayer();
  List<String> audioUrls = [];
  int currentIndex = 0;

  Future setAudio(String url) async{
    // audioPlayer.setReleaseMode(ReleaseMode.loop);
    setState(() {
      currentIndex=widget.number;
    });

    await player.play(UrlSource(url));
    player.onPlayerComplete.listen((event) {
      playNext();
    });
  }


  // Future<void> play() async {
  //   if (audioUrls.isNotEmpty) {
  //     await player.play(UrlSource(audioUrls[currentIndex]), );
  //     player.onPlayerComplete.listen((event) {
  //       playNext();
  //     });
  //
  //
  //   }
  // }

  void playNext() {
    if (currentIndex < audioUrls.length - 1) {
      currentIndex++;
      //setAudio(url);
    } else {
      // Reached the end of the list
      // You can implement looping or any other behavior here
      // For now, let's stop the player
      player.stop();
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     //player.dispose();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: gridContainerColor,
          title:
          Text(widget.surahEnglishName)
      ),
      body: ListView.builder(
          itemCount: widget.audioAyahs.length,
          primary: false,
          //scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final ayah = widget.audioAyahs[index];
            //final nim=widget.numberInSurah;


            return Card(
              color:gridContainerColor ,
              child: ListTile(
                title: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 250),
                      child: TextButton(onPressed: () {
                        setAudio(ayah['audio']);
                        player.onPlayerComplete.listen((event) {

                        });


                      }, child:const Icon(Icons.play_arrow),),
                    ),
              Padding(
                padding: const EdgeInsets.only(left: 100),
                child: RichText(
                    softWrap: true,
                    textAlign: TextAlign.right,
                    maxLines: 15,
                    overflow: TextOverflow.ellipsis,
                    text:  TextSpan(
                      text:  ayah['text'].toString(),
                      style: const TextStyle(

                          fontFamily: 'Kitab-Bold',
                          color: Color(0xffD5D5D5),
                          fontSize: 20),
                      children: <TextSpan>[

                      ],
                    ),
                  ),
              ),
                  ],
                ),
                // title:
                leading:   Container(
                  alignment: Alignment.center,
                  height: 35,
                  width: 35,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  child: Text(
                    arabicNumber.convert( ayah['numberInSurah'].toString()),
                    style: const TextStyle(color: Colors.white),

                  ),
                ),


              ),
            );

          }),
    );
  }
}