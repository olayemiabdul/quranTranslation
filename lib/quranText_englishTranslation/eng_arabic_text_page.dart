
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_complete_ui/quranText_englishTranslation/quran_content_engArabic.dart';
import '../provider/theme_provider.dart';
import '../responsiveness/responsive.dart';

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
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.isMobile(context) ? 8.0 : 12.0,
          vertical: Responsive.isMobile(context) ? 6.0 : 10.0,
        ),
        children: [
          for (var contentEA in page.engArabicContents) ...[
            if (contentEA.isNewSurah) ...[
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: Responsive.isMobile(context) ? 8.0 : 12.0,
                ),
                padding: EdgeInsets.all(
                  Responsive.isMobile(context) ? 10.0 : 14.0,
                ),
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
                        fontSize: Responsive.isMobile(context) ? 18 : 24,
                        fontFamily: 'Kitab-Bold',
                        fontWeight: FontWeight.bold,
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      contentEA.englishName,
                      style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 12 : 16,
                        fontFamily: 'Roboto',
                        color: isDarkTheme ? Colors.grey.shade300 : Colors.grey.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            for (var ayah in contentEA.ayahsn) ...[
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: Responsive.isMobile(context) ? 6.0 : 8.0,
                ),
                padding: EdgeInsets.all(
                  Responsive.isMobile(context) ? 8.0 : 12.0,
                ),
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
                              TextSpan(
                                text: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                                style: TextStyle(
                                  fontSize: Responsive.isMobile(context) ? 14 : 18,
                                  fontFamily: 'Kitab-Bold',
                                  fontWeight: FontWeight.w600,
                                  color: isDarkTheme ? Colors.white : Colors.black,
                                ),
                              ),
                              TextSpan(
                                text:
                                '${ayah.text.replaceFirst("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ", "").trim()} ﴿${arabicNumber.convert(ayah.numberInSurah)}﴾',
                                style: TextStyle(
                                  fontSize: Responsive.isMobile(context) ? 14 : 18,
                                  fontFamily: 'Kitab-Bold',
                                  color: isDarkTheme ? Colors.white : Colors.black,
                                ),
                              ),
                            ] else ...[
                              TextSpan(
                                text: '${ayah.text} ﴿${arabicNumber.convert(ayah.numberInSurah)}﴾',
                                style: TextStyle(
                                  fontSize: Responsive.isMobile(context) ? 14 : 18,
                                  fontFamily: 'Kitab-Bold',
                                  color: isDarkTheme ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      ayah.translation?.translation ?? '',
                      style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 12 : 14,
                        fontFamily: 'Roboto',
                        fontStyle: FontStyle.italic,
                        color: isDarkTheme ? Colors.grey.shade300 : Colors.grey.shade800,
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
                  fontSize: Responsive.isMobile(context) ? 16 : 18,
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




