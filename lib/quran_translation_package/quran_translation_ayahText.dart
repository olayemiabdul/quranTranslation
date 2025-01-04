import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_complete_ui/quran_translation_package/quran_translation_content.dart';

import '../provider/theme_provider.dart';
import '../responsiveness/responsive.dart';

class AllTranslationTextPage extends StatelessWidget {
  final QuranPageTranslation page;

  const AllTranslationTextPage({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
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

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkTheme = themeNotifier.themeModeNotifier.value == ThemeMode.dark;

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 900 : double.infinity,
        ),
        child: Container(
          color: Colors.white ,
          height: MediaQuery.of(context).size.height,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            children: [
              for (var contentEA in page.contents) ...[
                if (contentEA.isNewSurah) ...[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: isMobile ? 10.0 : 16.0),
                    padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
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
                    ),
                    child: Column(
                      children: [
                        Text(
                          contentEA.englishName,
                          style: TextStyle(
                            fontSize: surahNameFontSize,
                            fontFamily: 'Roboto',
                            color: isDarkTheme ? Colors.grey.shade300 : Colors.grey.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],

                for (var ayah in contentEA.ayahs) ...[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: isMobile ? 6.0 : 10.0),
                    padding: EdgeInsets.all(isMobile ? 10.0 : 14.0),
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
                          alignment: Alignment.topLeft,
                          child: RichText(
                            textAlign: TextAlign.justify,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                  '${ayah.numberInSurah} ${(ayah.translation?.translation ?? '').trim()} ',
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontFamily: 'Roboto',
                                    fontStyle: FontStyle.italic,
                                    color: isDarkTheme ? Colors.grey.shade300 : Colors.grey.shade800,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],

              Padding(
                padding: const EdgeInsets.only(top: 6.0, bottom: 5),
                child: Center(
                  child: Text(
                    '${page.pageNumber}',
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
