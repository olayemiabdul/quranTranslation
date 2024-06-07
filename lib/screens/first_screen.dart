
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:quran_complete_ui/constant.dart';

import '../widget/widget_data.dart';
import 'second_screen.dart';







class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
final player=AudioPlayer();
Future setAudio(String url) async{
  // audioPlayer.setReleaseMode(ReleaseMode.loop);
  //String url='https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3';
  await player.play(UrlSource(url));

}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration:  BoxDecoration(
            color: homeContainerColor,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            image: DecorationImage(image:
            const AssetImage('assets/images/bg.png'),
                fit: BoxFit.cover,
              colorFilter:  ColorFilter.mode(Colors.white.withOpacity(1), BlendMode.dstATop),)
        ),
        child:   Column(
          children: [
            const SizedBox.square(
              dimension: 50,

            ),
           ElevatedButton(onPressed:(){
             setAudio('https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3');
           }, child: Text('play')),
            Center(child: Text('The Kit-ab',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(color: Colors.blue.shade100, fontSize: 20,fontWeight: FontWeight.bold),
            ),),),
             const SizedBox(height: 90,),
             Center(
               child: Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Text('ٱلَّذِينَ ءَامَنُوا۟ وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ ٱللَّهِ ۗ أَلَا بِذِكْرِ ٱللَّهِ تَطْمَئِنُّ ٱلْقُلُوب ُ',

                  style: GoogleFonts.notoSansArabic(
                    textStyle:  TextStyle(color: Colors.blue.shade100, fontSize: 20,fontWeight: FontWeight.bold),
                  ),),
               ),
             ),
            const SizedBox(height: 50,),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('those who believe and whose hearts find comfort in the remembrance of Allah. Surely in the remembrance of Allah do hearts find comfort. ُ',

                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(color: Colors.blue.shade100, fontSize: 20,fontWeight: FontWeight.bold),
                  ),),
              ),
            ),

            Container(
              height: 36,
              width: 190,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                color: homeContainerColor,
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder:(context)=>const CoverPageDetail ()));
                  //choosing platform
                  // if (!kIsWeb && Platform.isAndroid) {QuranTextMainPage
                  //   signInWithGoogle();
                  // } else if (kIsWeb) {
                  //   signInWithGoogleWeb();
                  // }
                },
                child: Center(
                  child: Text('Get Started',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(color: Colors.blue.shade100, fontSize: 20,fontWeight: FontWeight.bold),
                      ),),
                ),
              ),
            ),

          ],

        ),
      ),
    );

  }
}
