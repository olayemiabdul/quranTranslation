// import 'package:flutter/material.dart';
// import 'package:quran_complete_ui/quranText_englishTranslation/eng_arabic_model_class.dart';
//
// class EngArabicTextPageNew extends StatelessWidget {
//   final SurahEngArabic surah;
//
//   const EngArabicTextPageNew({Key? key, required this.surah}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(surah.englishName)),
//       body: ListView.builder(
//         itemCount: surah.ayahs.length,
//         itemBuilder: (context, index) {
//           final ayah = surah.ayahs[index];
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Text(
//                   ayah.text,
//                   textAlign: TextAlign.right,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontFamily: 'Kitab-Bold',
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   ayah.translation,
//                   textAlign: TextAlign.left,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_complete_ui/quranText_englishTranslation/quran_content_engArabic.dart';
import '../provider/theme_provider.dart';
import 'eng_arabic_model_class.dart';

class EngArabicTextPageNew extends StatelessWidget {
  final QuranPageEngArabic page;

  const EngArabicTextPageNew({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    ArabicNumbers arabicNumber = ArabicNumbers();
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkTheme = themeNotifier.themeModeNotifier.value == ThemeMode.dark;

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        children: [
          for (var contentEA in page.engArabicContents) ...[
            if (contentEA.isNewSurah) ...[

              Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: isDarkTheme
                      ? Colors.grey.shade800.withOpacity(0.85)
                      : Colors.grey.shade200.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDarkTheme ? Colors.grey.shade600 : Colors.grey.shade400,
                    width: 1.2,
                  ),
                  image: const DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/qp.jpg'),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      contentEA.surahName,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Kitab-Bold',
                        fontWeight: FontWeight.bold,
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      contentEA.englishName,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        color: isDarkTheme ? Colors.grey.shade300 : Colors.grey.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],

            // Display Ayah Text (Arabic and English)
            for (var ayah in contentEA.ayahsn) ...[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: isDarkTheme ? Colors.black : const Color(0xffE2DBC0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDarkTheme ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: RichText(
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        text: TextSpan(
                          children: [
                            if (ayah.numberInSurah == 1 &&
                                ayah.text.contains('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ')) ...[
                              // Separate Bismillah
                              const TextSpan(
                                text: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ\n',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Kitab-Bold',
                                  height: 1.8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text:
                                '${ayah.text.replaceFirst("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ", "").trim()} ﴿${arabicNumber.convert(ayah.numberInSurah)}﴾',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Kitab-Bold',
                                  color: isDarkTheme ? Colors.white : Colors.black,
                                  height: 1.8,
                                ),
                              ),
                            ] else ...[
                              TextSpan(
                                text:
                                '${ayah.text} ﴿${arabicNumber.convert(ayah.numberInSurah)}﴾',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Kitab-Bold',
                                  color: isDarkTheme ? Colors.white : Colors.black,
                                  height: 1.8,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    // English Translation
                    Text(
                      (ayah).translation?.translation ?? '',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        fontStyle: FontStyle.italic,
                        color: isDarkTheme ? Colors.grey.shade300 : Colors.grey.shade800,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],

          // Display Page Number at the Bottom
          Padding(
            padding: const EdgeInsets.only(top: 6.0, bottom: 5),
            child: Center(
              child: Text(
                '${page.pageNumber}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}




