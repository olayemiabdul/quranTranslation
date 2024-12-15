import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/theme_provider.dart';
import '../responsiveness/responsive.dart';
import 'eng_arabic_model_class.dart';
import 'organized_ayah_engArabic.dart';


class EngArabicTextSurahListPageNew extends StatefulWidget {
  const EngArabicTextSurahListPageNew({super.key});

  @override
  _EngArabicTextSurahListPageNewState createState() => _EngArabicTextSurahListPageNewState();
}

class _EngArabicTextSurahListPageNewState extends State<EngArabicTextSurahListPageNew> {
  List<SurahEngArabic> surahs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSurahData();
  }

  Future<void> loadSurahData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedArabic = prefs.getString('quranArabicData');
    final cachedEnglish = prefs.getString('quranEnglishData');

    if (cachedArabic != null && cachedEnglish != null) {
      setState(() {
        surahs = parseSurahData(cachedArabic, cachedEnglish);
        isLoading = false;
      });
    } else {
      final arabicResponse = await http.get(Uri.parse("https://api.alquran.cloud/v1/quran/quran-uthmani"));
      final englishResponse = await http.get(Uri.parse("https://api.alquran.cloud/v1/quran/en.ahmedali"));

      if (arabicResponse.statusCode == 200 && englishResponse.statusCode == 200) {
        prefs.setString('quranArabicData', arabicResponse.body);
        prefs.setString('quranEnglishData', englishResponse.body);

        setState(() {
          surahs = parseSurahData(arabicResponse.body, englishResponse.body);
          isLoading = false;
        });
      }
    }
  }

  List<SurahEngArabic> parseSurahData(String arabicData, String englishData) {
    final arabicJson = json.decode(arabicData)['data']['surahs'];
    final englishJson = json.decode(englishData)['data']['surahs'];
    List<SurahEngArabic> surahsList = [];
    for (int i = 0; i < arabicJson.length; i++) {
      final arabicSurah = arabicJson[i];
      final englishSurah = englishJson[i];

      final List<AyahEngArabic> ayahList = arabicSurah['ayahs']
          .asMap()
          .entries
          .map((entry) {
        final arabicAyahJson = entry.value;
        final englishTranslationText = englishSurah['ayahs'][entry.key]['text'];

        return AyahEngArabic.fromJson(arabicAyahJson, englishTranslationText);
      }).toList().cast<AyahEngArabic>();

      surahsList.add(SurahEngArabic(
        number: arabicSurah['number'],
        name: arabicSurah['name'],
        englishName: arabicSurah['englishName'],
        englishNameTranslation: arabicSurah['englishNameTranslation'],
        numberOfAyahs: arabicSurah['ayahs'].length,
        ayahsEA: ayahList,
      ));
    }
    return surahsList;
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkTheme = themeNotifier.themeModeNotifier.value == ThemeMode.dark;
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('English and Arabic Quran'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : isTablet ? 20 : 50,
        ),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : isTablet ? 2 : 3,
            childAspectRatio: isMobile ? 3 : 2.5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: surahs.length,
          itemBuilder: (context, index) {
            final surah = surahs[index];
            return Card(
              color: isDarkTheme ? Colors.grey[850] : Colors.white,
              child: ListTile(
                title: Text(
                  'Page ${surah.ayahsEA.first.page}: ${surah.englishNameTranslation}',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  '${surah.numberOfAyahs} Verses',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.grey[300] : Colors.black87,
                  ),
                ),
                trailing: Text(
                  '${surah.name}\n${surah.englishName}',
                  style: TextStyle(
                    fontFamily: 'Kitab-Bold',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme ? Colors.cyanAccent : Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
                leading: Container(
                  alignment: Alignment.center,
                  height: 30,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkTheme ? Colors.black26 : Colors.black54,
                  ),
                  child: Text(
                    surah.number.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrganizedEngArabicAyahViewScreen(
                        surahEA: surahs,
                        initialPage: surah.ayahsEA.first.page - 1,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
