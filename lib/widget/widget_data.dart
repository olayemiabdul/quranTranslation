import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constant.dart';
import '../hajj_adkar/hajj_screen.dart';
import '../model/cover_page_model.dart';
import '../provider/theme_provider.dart';
import '../quranText_UrduTranslation/quran_urduTranslationList.dart';
import '../quranText_englishTranslation/eng_arabic_list.dart';
import '../quran_audio/surahPlaylist.dart';
import '../quran_ayah/Surah_List.dart';
import '../quran_byPage/quran_pages.dart';
import '../quran_translation_package/quran_translationList.dart';
import '../hajj_adkar/adhkar.dart';
import '../azan/prayerTime.dart';
import '../responsiveness/responsive.dart';
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
            builder: (context) => const  QuranTranslationListPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SurahListPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const  QuranUrduTranslationListPage()),
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
            builder: (context) => const  EngArabicTextSurahListPageNew()),
      );
    } else if (index == 6) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RemembrancePage()),
      );
    } else if (index == 7) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  const PrayerTimePage()),
      );
    } else if (index == 8) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>   const HajjPage ()),
      );
    } else {

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  const AudioSurahList ()),
      );
    }

  }
  final today = HijriCalendar.now();
  late Timer _timer;
  String formattedTime = '';
  DateTime selectedDate = DateTime.now();

  void updateTime() {
    setState(() {
      formattedTime = DateFormat('kk:mm:ss').format(DateTime.now());
    });
  }

  @override
  void initState() {
    super.initState();
    updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => updateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkTheme = themeNotifier.themeModeNotifier.value == ThemeMode.dark;

    QuranCover reading = QuranCover();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(isMobile ? 'Al-Quran' : 'Quran'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: IconButton(
                  icon: Icon(
                    isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                  ),
                  onPressed: themeNotifier.toggleTheme,
                ),
              ),
              PopupMenuItem(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPageScreen()),
                    );
                  },
                  child: const Text('Settings'),
                ),
              ),
              PopupMenuItem(
                child: ElevatedButton(
                  onPressed: () {
                    Share.share(
                        'Check out this amazing Quran app: https://play.google.com/store/apps/details?id=com.tunedtech.quran_complete_ui',
                        subject: 'Share the App');
                  },
                  child: const Icon(Icons.share, size: 30),
                ),
              ),
            ],
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final crossAxisCount = orientation == Orientation.portrait
              ? (isMobile ? 3 : isTablet ? 4 : 5)
              : (isMobile ? 4 : isTablet ? 5 : 6);

          return Container(
            height: screenHeight,
            width: screenWidth,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/mosque4.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.7), BlendMode.dstATop),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.1),
                Text(
                  formattedTime,
                  style: GoogleFonts.allura(
                    textStyle: TextStyle(
                      color: Colors.blue.shade100,
                      fontSize: isMobile ? 50 : isTablet ? 60 : 70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  today.fullDate().toString(),
                  style: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                      color: Colors.amber,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
                        " ${selectedDate.year} ${selectedDate.day}",
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                              color: Colors.amber,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: GridView.builder(
                    itemCount: reading.readingActivity.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: isMobile
                          ? 0.9
                          : isTablet
                          ? 1.0
                          : 0.8,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) => InkWell(
                      onTap: () => quranPageNavigation(index),
                      child: CustomCard(
                        color: backGroundColor,
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              reading.readingActivity[index].icon,
                              height: isMobile ? 50 : isTablet ? 60 : 70,
                              width: isMobile ? 50 : isTablet ? 60 : 70,
                            ),
                            Text(
                              reading.readingActivity[index].title,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

