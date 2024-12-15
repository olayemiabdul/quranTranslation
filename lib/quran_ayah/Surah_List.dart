import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/theme_provider.dart';
import 'surah_class.dart';
import 'organizedAyah.dart';

class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  _SurahListPageState createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  List<Surah> surahs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    updatingSurahList();
  }

  Future<void> updatingSurahList() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedSurahs = prefs.getString('surahs');

    if (cachedSurahs != null) {
      final List<dynamic> surahsData = json.decode(cachedSurahs);
      setState(() {
        surahs = surahsData.map((surah) => Surah.fromJson(surah)).toList();
        isLoading = false;
      });
    } else {
      await getAllSurah();
    }
  }

  Future<void> getAllSurah() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/quran/quran-uthmani'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> surahsData = data['data']['surahs'];
        final fetchedSurahs = surahsData.map((surah) => Surah.fromJson(surah)).toList();

        setState(() {
          surahs = fetchedSurahs;
          isLoading = false;
        });

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('surahs', json.encode(surahsData));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching Quran data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkTheme = themeNotifier.themeModeNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),

        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isTabletOrDesktop = constraints.maxWidth >= 600;
          double fontSize = isTabletOrDesktop ? 20 : 16;
          double padding = isTabletOrDesktop ? 20 : 10;

          return isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: surahs.length,
            itemBuilder: (context, index) {
              final surah = surahs[index];
              return Padding(
                padding: EdgeInsets.symmetric(
                    vertical: padding / 2, horizontal: padding),
                child: Card(
                  color: isDarkTheme ? Colors.white : Colors.grey[850],
                  child: ListTile(
                    title: Text(
                      'Page ${surah.ayahs.first.page}: ${surah.englishNameTranslation}',
                      style: TextStyle(
                        fontSize: fontSize,
                        color: isDarkTheme ? Colors.black : Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      '${surah.ayahs.length} Verses - ${surah.revelationType}',
                      style: TextStyle(
                        fontSize: fontSize * 0.9,
                        color: isDarkTheme
                            ? Colors.grey[300]
                            : Colors.black87,
                      ),
                    ),
                    trailing: Text(
                      '${surah.name}\n${surah.englishName}',
                      style: TextStyle(
                        fontFamily: 'Kitab-Bold',
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: isDarkTheme
                            ? Colors.cyanAccent
                            : Colors.teal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    leading: CircleAvatar(
                      backgroundColor:
                      isDarkTheme ? Colors.black26 : Colors.black54,
                      child: Text(
                        surah.number.toString(),
                        style: TextStyle(
                          fontSize: fontSize * 0.9,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrganizedAyahViewScreen(
                            surahs: surahs,
                            initialPage: surah.ayahs.first.page - 1,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
