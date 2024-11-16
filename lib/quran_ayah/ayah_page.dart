
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:quran_complete_ui/quran_ayah/quran_content.dart';

import '../provider/theme_provider.dart';

class AyahPageView extends StatelessWidget {
  final QuranPage page;

  const AyahPageView({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    ArabicNumbers arabicNumber = ArabicNumbers();
    final themeNotifier = Provider.of<ThemeNotifier>(context);
  final isDarkTheme = themeNotifier.themeModeNotifier.value == ThemeMode.dark;
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
        children: [
          for (var content in page.contents) ...[
            // Display Surah Name if it's a New Surah
            if (content.isNewSurah) ...[
              Container(

                margin: const EdgeInsets.symmetric(vertical: 10.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
    color: isDarkTheme
                             ? Colors.grey.shade800.withOpacity(0.85)         : Colors.grey.shade200.withOpacity(0.85),
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
                child: Text(
                  content.surahName,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Kitab-Bold',
                    fontWeight: FontWeight.bold,
                   color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            // Display Ayah Text
            Container(
              margin: const EdgeInsets.symmetric(vertical: 1.0),
              padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
              decoration: BoxDecoration(
                color: (page.pageNumber == 1 || page.pageNumber == 2 )
                    ? isDarkTheme?Colors.black:Colors.yellow.shade100
                    :isDarkTheme? Colors.black:const Color(0xffE2DBC0),
                image: (page.pageNumber == 1 || page.pageNumber == 2)
                    ? const DecorationImage(
                  image: AssetImage('assets/images/firstPage.jpg'),
                  fit: BoxFit.cover,
                )
                    : null,
                borderRadius: BorderRadius.circular(10),
                border: Border.all( color: isDarkTheme ? Colors.grey.shade600 : Colors.grey.shade400,),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: RichText(
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  text: TextSpan(
                    children: content.ayahs.expand((ayah) {
                      // Separate Bismillah for the first Ayah
                      if (ayah.numberInSurah == 1 &&
                          ayah.text.contains('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ')) {
                        const bismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
                        final remainingText = ayah.text.replaceFirst(bismillah, '').trim();

                        return [
                           TextSpan(
                            text: '               $bismillah\n',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkTheme ? Colors.white : Colors.black,
                              fontFamily: 'Kitab-Bold',
                              height: 1.8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: '$remainingText ﴿${arabicNumber.convert(ayah.numberInSurah)}﴾',
                            style:  TextStyle(
                              fontSize: 16,
                              color: isDarkTheme ? Colors.white : Colors.black,
                              fontFamily: 'Kitab-Bold',
                              fontWeight: FontWeight.w500,
                              height: 1.8,
                            ),
                          ),
                        ];
                      } else {
                        return [
                          TextSpan(
                            text: '${ayah.text}﴿${arabicNumber.convert(ayah.numberInSurah)}﴾',
                            style: TextStyle(
                              fontSize: 17,
                              color: isDarkTheme ? Colors.white : Colors.black,
                              fontFamily: 'Kitab-Bold',
                              fontWeight: FontWeight.w500,
                              height: 1.8,
                            ),
                          ),
                        ];
                      }
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],

          // Page Number Display at the Bottom
          Padding(
            padding: const EdgeInsets.only(top: 6.0,bottom:5 ),
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
