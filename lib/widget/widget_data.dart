import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocode/geocode.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:pray_times/pray_times.dart';
import 'package:share_plus/share_plus.dart';

import '../constant.dart';
import '../hajj_adkar/hajj_screen.dart';
import '../hajj_adkar/hajj_widget.dart';
import '../location_logic/location_class.dart';
import '../model/cover_page_model.dart';

import '../quranText_UrduTranslation/quran_text_urdu_list.dart';
import '../quranText_englishTranslation/qurantext_engTrans_list.dart';

import '../quran_audio/surahPlaylist.dart';
import '../quran_byPage/quran_pages.dart';

import '../quran_text_package/quran_surahList.dart';

import '../quran_translation_package/quran_translationList.dart';

import '../hajj_adkar/adhkar.dart';


import '../setting/newQuran.dart';
import '../azan/prayerTime.dart';

import '../setting/settings_screen.dart';
import 'custom_container.dart';

class CoverPageDetail extends StatefulWidget {
  const CoverPageDetail({super.key});

  @override
  State<CoverPageDetail> createState() => _CoverPageDetailState();
}

class _CoverPageDetailState extends State<CoverPageDetail> {
  void quranPageNavigation(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const QuranTranslationListPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QuranTextPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const UrduArabicTextSurahListPage()),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QuranByPages()),
      );
    } else if (index == 5) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const EngArabicTextSurahListPage()),
      );
    } else if (index == 6) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RemembrancePage()),
      );
    } else if (index == 7) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PrayerTimePage()),
      );
    } else if (index == 8) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>  const HajjPage ()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AudioSurahList()),
      );
    }
    // navigate to two
  }

  var today = HijriCalendar.now(); // for hijri date
  DateTime selectedDate = DateTime.now(); //flutter date

  shareApp(BuildContext context) {
    Share.share('Check out this amazing app: https://play.google.com/store/apps/details?id=com.example.yourapp', // Replace with your app's Play Store URL
        subject: 'Share Our App');
  }



  @override
  Widget build(BuildContext context) {


    // //PrayerTimes prayers = PrayerTimes();
    // prayers.setTimeFormat(prayers.Time24);
    // prayers.setCalcMethod(prayers.MWL);
    // prayers.setAsrJuristic(prayers.Shafii);
    // prayers.setAdjustHighLats(prayers.AngleBased);
    // var offsets = [0, 0, 0, 0, 0, 0, 0];
    // int width = 10;
    // int height = 15;
    // prayers.tune(offsets);
    QuranCover reading = QuranCover();
    var overlayController=OverlayPortalController();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Al-Quran'),
        actions: [

          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                // row with 2 children
                child: ElevatedButton(
                  onPressed: overlayController.toggle,
                  child: OverlayPortal(
                    controller: overlayController, overlayChildBuilder: (BuildContext context) {
                    return Positioned(
                      top: 250,
                      right: 40,
                      child: Container
                        (
                        decoration: const BoxDecoration(
                            color: Colors.cyan,
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                        //color: Colors.green,
                        height: 330,
                        width: 300,
                        child:  const Column(
                          children: [
                            // const SizedBox(height: 140,),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Welcome Tuned Jobs\nGrab your next desired dream Job here',
                                style: TextStyle(color: Colors.white),),
                            ),
                            Image(image: AssetImage('assets/images/overlay.png', ), height: 180,width: 260,),
                            SizedBox(height: 2,),
                            Text('Version 1.0.1\nDeveloper:olayemi.abdullahi@gmail.com\n07407208778')
                          ],
                        ),
                      ),
                    );
                  },
                    child: const Text('App Info'),
                  ),
                ),
              ),
              PopupMenuItem(
                  child: ElevatedButton(onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const  SettingsPageScreen(),
                      ),
                    );
                  }, child: const Text('Settings'),)
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        shareApp(context);
                      },
                      icon: const Icon(Icons.share),
                    ),
                    const Text('share'),
                  ],
                ),
              ),
            ],
          ),
        ],

      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(
              'assets/images/mosque4.jpg',
            ),
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.7), BlendMode.dstATop),
          ),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50)),
          //color:gridContainerColor,
        ),
        child: Column(
          children: [
            const SizedBox.square(
              dimension: 80,
            ),

            // Expanded(child: PrayerTimePage()),
            Center(
              child: Text(
                "${selectedDate.hour} : ${selectedDate.minute} ",
                style: GoogleFonts.allura(
                  textStyle: TextStyle(
                      color: Colors.blue.shade100,
                      fontSize: 60,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            Center(
              child: Text(
                today.fullDate().toString(),
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                      color: Colors.amber,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 140),
              child: Row(
                children: [
                  Text(
                    DateFormat.LLLL().format(DateTime.now()),
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                          color: Colors.amber,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    " ${selectedDate.year}   ${selectedDate.day}",
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(33.0),
                child: GridView.builder(
                    itemCount: reading.readingActivity.length,
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 6),
                    itemBuilder: (context, index) => InkWell(
                          onTap: () => quranPageNavigation(index),
                          child: CustomCard(
                            color: backGroundColor,
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  reading.readingActivity[index].icon,
                                  height: 60,
                                  width: 60,
                                ),

                                // Padding(
                                //   padding: const EdgeInsets.only(bottom: 4, top: 15),
                                //   child: Text(reading.readingActivity[index].value, style: const TextStyle(
                                //     fontSize: 18,
                                //     color: Colors.white,
                                //     fontWeight: FontWeight.w600,
                                //   ),),
                                // ),
                                Text(
                                  reading.readingActivity[index].title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.amber,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
