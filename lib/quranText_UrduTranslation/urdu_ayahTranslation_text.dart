import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/theme_provider.dart';

import 'Urdu_translation_content.dart';


class UrduTranslationTextPage extends StatelessWidget {
  final UrduQuranPageTranslation page;

  const UrduTranslationTextPage({super.key, required this.page});



  @override
  Widget build(BuildContext context) {

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


    // Adjust line height and padding based on screen size

    double horizontalPadding = screenWidth * (isMobile ? 0.04 : isTablet ? 0.06 : 0.08);

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 900 : double.infinity,
        ),
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            children: [
              for (var contentEA in page.contents) ...[
                if (contentEA.isNewSurah) ...[

                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isDarkTheme
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
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
                for (var ayah in contentEA.ayahs) ...[
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
                          alignment: Alignment.topLeft,
                          child: RichText(
                            textAlign: TextAlign.justify,
                            //textDirection: TextDirection.rtl,
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
                                    '${(ayah.numberInSurah)} ${(ayah ).translation.translation .replaceFirst("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ", "").trim()} ',
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontFamily: 'Kitab-Bold',
                                      color: isDarkTheme ? Colors.white : Colors.black,
                                      height: 1.8,
                                    ),
                                  ),
                                ] else ...[
                                  TextSpan(
                                    text:
                                    '${(ayah.numberInSurah)} ${(ayah ).translation.translation } ',
                                    style:TextStyle(
                                      fontSize: fontSize,
                                      fontFamily: 'Roboto',
                                      fontStyle: FontStyle.italic,
                                      color: isDarkTheme ? Colors.grey.shade300 : Colors.grey.shade800,
                                      height: 1.5,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        // English Translation
                        // Text(
                        //   (ayah ).translation?.translation ?? '',
                        //   //textAlign: TextAlign.left,
                        //   style: TextStyle(
                        //     fontSize: 15,
                        //     fontFamily: 'Roboto',
                        //     fontStyle: FontStyle.italic,
                        //     color: isDarkTheme ? Colors.grey.shade300 : Colors.grey.shade800,
                        //     height: 1.5,
                        //   ),
                        // ),
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
        ),
      ),
    );
  }
}




