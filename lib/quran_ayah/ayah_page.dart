import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_quran/quran_ayah/quran_content.dart';
import '../provider/theme_provider.dart';



import '../responsiveness/responsive.dart';

class AyahPageView extends StatelessWidget {
  final QuranPage page;

  const AyahPageView({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    ArabicNumbers arabicNumber = ArabicNumbers();
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkTheme = themeNotifier.themeModeNotifier.value == ThemeMode.dark;

    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Dynamic sizing based on screen dimensions
    bool isMobile = screenWidth < 600;
    bool isTablet = screenWidth >= 600 && screenWidth < 1200;
    bool isDesktop = screenWidth >= 1200;

    // Calculate font sizes based on screen height
    double fontSize = screenHeight * (isMobile ? 0.025 : isTablet ? 0.028 : 0.032);
    double bismillahFontSize = fontSize * 1.2;
    double surahNameFontSize = fontSize * 1.3;

    // Adjust line height and padding based on screen size
    double lineHeight = isMobile ? 2.0 : isTablet ? 2.2 : 2.4;
    double horizontalPadding = screenWidth * (isMobile ? 0.04 : isTablet ? 0.06 : 0.08);


    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 900 : double.infinity,
        ),
        child: Container(
          color: isDarkTheme ? Colors.white : Colors.black,
          height: MediaQuery.of(context).size.height,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            children: [
              for (var content in page.contents) ...[
                if (content.isNewSurah) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isDarkTheme
                          ? Colors.grey.shade800.withOpacity(0.85)
                          : Colors.grey.shade200.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDarkTheme
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
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
                        fontSize: surahNameFontSize,
                        fontFamily: 'Kitab-Bold',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl,
                    text: TextSpan(
                      children: content.ayahs.expand((ayah) {
                        if (ayah.numberInSurah == 1 &&
                            ayah.text.contains('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ')) {
                          const bismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
                          final remainingText =
                          ayah.text.replaceFirst(bismillah, '').trim();
                          return [
                            TextSpan(
                              text: '       $bismillah\n',
                              style: TextStyle(
                                fontSize: bismillahFontSize,
                                color: isDarkTheme ? Colors.grey[850] : Colors.white,
                                fontFamily: 'Kitab-Bold',
                                height: 2.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (remainingText.isNotEmpty)
                            TextSpan(
                              text:
                              '$remainingText ﴿${arabicNumber.convert(ayah.numberInSurah)}﴾',
                              style: TextStyle(
                                fontSize: fontSize,
                                color: isDarkTheme ? Colors.grey[850] : Colors.white,
                                fontFamily: 'Kitab-Bold',
                                fontWeight: FontWeight.w700,
                                height: lineHeight,
                              ),
                            ),
                          ];
                        } else {
                          return [
                            TextSpan(
                              text:
                              '${ayah.text}﴿${arabicNumber.convert(ayah.numberInSurah)}﴾',
                              style: TextStyle(
                                fontSize: fontSize,
                                color: isDarkTheme ? Colors.grey[850] : Colors.white,
                                fontFamily: 'Kitab-Bold',
                                fontWeight: FontWeight.w700,
                                height: lineHeight,
                              ),
                            ),
                          ];
                        }
                      }).toList(),
                    ),
                  ),
                ),
              ],
              // Display Page Number Correctly
              Padding(
                padding: const EdgeInsets.only(top: 6.0, bottom: 5),
                child: Center(
                  child: Text(
                    'Page ${page.pageNumber}', // Show actual page number here
                    style: TextStyle(
                      fontSize: isMobile ? 18 : isTablet ? 20 : 22,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
