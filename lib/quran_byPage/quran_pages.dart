import 'dart:convert';
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';

class QuranByPages extends StatefulWidget {
  const QuranByPages({super.key});

  @override
  _QuranByPagesState createState() => _QuranByPagesState();
}

class _QuranByPagesState extends State<QuranByPages> {
  List<dynamic> quranTranslateData = [];
  ArabicNumbers arabicNumber = ArabicNumbers();
  final PageController pageController = PageController();
  int activePage = 1;
  int totalPages = 604; // Adjusted to match Quran pages

  @override
  void initState() {
    super.initState();
    getQuranTranslationData();
  }

  Future<void> getQuranTranslationData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('quranPageData');

    if (cachedData != null) {
      setState(() {
        quranTranslateData = json.decode(cachedData)["data"]["ayahs"];
      });
    } else {
      fetchPageData(1);
    }
  }

  Future<void> fetchPageData(int pageNumber) async {
    final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/page/$pageNumber/quran-uthmani'));

    if (response.statusCode == 200) {
      setState(() {
        quranTranslateData = json.decode(response.body)['data']['ayahs'];
        activePage = pageNumber;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('quranPageData', response.body);
    } else {
      throw Exception('Failed to load Quran data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: gridContainerColor,
        title: Text('Quran - Page $activePage',
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () async {
              final result = await showDialog<int>(
                context: context,
                builder: (context) => PageJumpDialog(totalPages: totalPages),
              );
              if (result != null) {
                fetchPageData(result);
              }
            }, label:const Text('Search Quran by page', style: TextStyle(color: Colors.white),),

          ),
        ],
      ),
      body: quranTranslateData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
        controller: pageController,
        onPageChanged: (page) {
          if (page + 1 != activePage) {
            fetchPageData(page + 1);
          }
        },
        itemCount: totalPages,
        itemBuilder: (context, pageIndex) {
          return buildQuranPage(context);
        },
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Widget buildQuranPage(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: quranTranslateData.map((ayah) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: gridContainerColor,
                child: Text(
                  arabicNumber.convert(ayah['numberInSurah'].toString()),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                ayah['text'],
                style: const TextStyle(
                  fontFamily: 'Kitab-Bold',
                  fontSize: 18,
                  color: Colors.black,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: gridContainerColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (activePage > 1) {
                fetchPageData(activePage - 1);
                pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
          Text(
            'Page $activePage of $totalPages',
            style: const TextStyle(color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () {
              if (activePage < totalPages) {
                fetchPageData(activePage + 1);
                pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class PageJumpDialog extends StatelessWidget {
  final int totalPages;

  const PageJumpDialog({super.key, required this.totalPages});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return AlertDialog(
      title: const Text('Jump to Page'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Enter page number (1-$totalPages)',
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('Go'),
          onPressed: () {
            final page = int.tryParse(controller.text);
            if (page != null && page > 0 && page <= totalPages) {
              Navigator.pop(context, page);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invalid page number!')),
              );
            }
          },
        ),
      ],
    );
  }
}
