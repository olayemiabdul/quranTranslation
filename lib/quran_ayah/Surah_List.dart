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
    UpdatingSurahList();
  }

  // Load Surah data from SharedPreferences if available; otherwise fetch from API
  Future<void> UpdatingSurahList() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedSurahs = prefs.getString('surahs');

    if (cachedSurahs != null) {
      // Deserialize JSON data from SharedPreferences and set state
      final List<dynamic> surahsData = json.decode(cachedSurahs);
      setState(() {
        surahs = surahsData.map((surah) => Surah.fromJson(surah)).toList();
        isLoading = false;
      });
    } else {
      // Fetch data from API if no cached data is found
      await fetchQuranData();
    }
  }

  // Fetch Quran data from the API and save it to SharedPreferences
  Future<void> fetchQuranData() async {
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

        // Save the fetched data to SharedPreferences
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: surahs.length,
        itemBuilder: (context, index) {
          final surah = surahs[index];
          return Card(
            color: isDarkTheme ? Colors.grey[850] : Colors.white,
            child: ListTile(
              title: Text(
                  'Page ${surah.ayahs.first.page}: ${surah.englishNameTranslation}',
                style: TextStyle(
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),),
              subtitle: Text(
                  '${surah.ayahs.length} Verses - ${surah.revelationType}',
                style: TextStyle(
                  color: isDarkTheme ? Colors.grey[300] : Colors.black87,
                ),),
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
                decoration:  BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkTheme ? Colors.black26 : Colors.black54,
                ),
                child: Text(
                  surah.number.toString(),
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
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
          );
        },
      ),
    );
  }
}
