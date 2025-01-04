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
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkTheme = themeNotifier.themeModeNotifier.value == ThemeMode.dark;

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: CupertinoScrollbar(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12.0 : isTablet ? 20.0 : 30.0,
            vertical: isMobile ? 8.0 : 12.0,
          ),
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
                          fontSize: isMobile ? 14 : isTablet ? 16 : 18,
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
                                  fontSize: isMobile ? 15 : isTablet ? 17 : 19,
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
    );
  }
}
