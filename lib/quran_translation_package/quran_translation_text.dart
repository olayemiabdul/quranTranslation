import 'package:flutter/material.dart';

import '../responsiveness/responsive.dart'; // Import the Responsive class

class QuranTranslationTextPage extends StatefulWidget {
  final List<dynamic> translatedAyahs;
  final String surahEnglishName;
  final List<dynamic> numberInSurah;

  const QuranTranslationTextPage({
    super.key,
    required this.translatedAyahs,
    required this.surahEnglishName,
    required this.numberInSurah,
  });

  @override
  State<QuranTranslationTextPage> createState() =>
      _QuranTranslationTextPageState();
}

class _QuranTranslationTextPageState extends State<QuranTranslationTextPage> {
  final int ayahsPerPage = 8;

  @override
  Widget build(BuildContext context) {
    int totalPages = (widget.translatedAyahs.length / ayahsPerPage).ceil();
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          widget.surahEnglishName,
          style: TextStyle(
            fontSize: isMobile ? 16 : isTablet ? 20 : 24,
          ),
        ),
      ),
      body: PageView.builder(
        itemCount: totalPages,
        reverse: true,
        itemBuilder: (context, index) {
          int startIndex = index * ayahsPerPage;
          int endIndex = startIndex + ayahsPerPage;
          if (endIndex > widget.translatedAyahs.length) {
            endIndex = widget.translatedAyahs.length;
          }
          List<dynamic> ayahsOnPage =
          widget.translatedAyahs.sublist(startIndex, endIndex);

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile
                    ? 8.0
                    : isTablet
                    ? 16.0
                    : 32.0, // Extra padding for desktop
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ayahsOnPage.map((ayah) {
                  return Card(
                    child: ListTile(
                      title: Text(
                        ayah['text'].toString(),
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: isMobile
                              ? 14
                              : isTablet
                              ? 18
                              : 20, // Larger font for desktop
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Text(
                          ayah['numberInSurah'].toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 12 : isTablet ? 14 : 16,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
