import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';
import 'newQuran.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(QuranAdapter());
  Hive.registerAdapter(DataAdapter());
  Hive.registerAdapter(SurahAdapter());
  Hive.registerAdapter(AyahAdapter());
  runApp(QuranApp());
}

class QuranApp extends StatelessWidget {
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
  late Box box;

  @override
  void initState() {
    super.initState();
    initHive();
  }

  Future<void> initHive() async {
    box = await Hive.openBox('quranBox');
    if (box.isEmpty) {
      fetchAndSaveQuran();
    } else {
      setState(() {});
    }
  }

  Future<void> fetchAndSaveQuran() async {
    final response = await http.get(Uri.parse('http://api.alquran.cloud/v1/quran/quran-uthmani'));

    if (response.statusCode == 200) {
      final quran = Quran.fromJson(json.decode(response.body));
      await box.put('quran', quran);
      setState(() {});
    } else {
      throw Exception('Failed to load Quran');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (box == null || !box.containsKey('quran')) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quran'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      final quran = box.get('quran') as Quran;
      return Scaffold(
        appBar: AppBar(
          title: Text('Quran'),
        ),
        body: ListView.builder(
          itemCount: quran.data.surahs.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(quran.data.surahs[index].name),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AyahPage(surah: quran.data.surahs[index]),
                  ),
                );
              },
            );
          },
        ),
      );
    }
  }
}

class AyahPage extends StatelessWidget {
  final Surah surah;

  AyahPage({required this.surah});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(surah.name),
      ),
      body: PageView.builder(
        itemCount: surah.ayahs.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: surah.ayahs
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
      ),
    );
  }
}