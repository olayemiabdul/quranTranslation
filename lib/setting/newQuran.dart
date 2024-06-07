import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



class PageQuranApp extends StatelessWidget {
  const PageQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: QuranPage(),
    );
  }
}

class QuranPage extends StatefulWidget {
  @override
  _QuranPageState createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  late Future<Quran> quranData;

  @override
  void initState() {
    super.initState();
    quranData = fetchQuran();
  }

  Future<Quran> fetchQuran() async {
    final response = await http.get(Uri.parse('http://api.alquran.cloud/v1/quran/quran-uthmani'));

    if (response.statusCode == 200) {
      return Quran.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Quran');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quran'),
      ),
      body: FutureBuilder<Quran>(
        future: quranData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return PageView.builder(
              itemCount: snapshot.data!.data.surahs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: snapshot.data!.data.surahs[index].ayahs
                          .map((ayah) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          ayah.text,
                          style: TextStyle(fontSize: 18, fontFamily: 'Uthmani'),
                          textAlign: TextAlign.right,
                        ),
                      ))
                          .toList(),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Quran {
  final Data data;

  Quran({required this.data});

  factory Quran.fromJson(Map<String, dynamic> json) {
    return Quran(
      data: Data.fromJson(json['data']),
    );
  }
}

class Data {
  final List<Surah> surahs;

  Data({required this.surahs});

  factory Data.fromJson(Map<String, dynamic> json) {
    var list = json['surahs'] as List;
    List<Surah> surahList = list.map((i) => Surah.fromJson(i)).toList();

    return Data(
      surahs: surahList,
    );
  }
}

class Surah {
  final int number;
  final String name;
  final List<Ayah> ayahs;

  Surah({required this.number, required this.name, required this.ayahs});

  factory Surah.fromJson(Map<String, dynamic> json) {
    var list = json['ayahs'] as List;
    List<Ayah> ayahList = list.map((i) => Ayah.fromJson(i)).toList();

    return Surah(
      number: json['number'],
      name: json['name'],
      ayahs: ayahList,
    );
  }
}

class Ayah {
  final int number;
  final String text;

  Ayah({required this.number, required this.text});

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'],
      text: json['text'],
    );
  }
}