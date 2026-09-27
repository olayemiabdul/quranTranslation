import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_quran/provider/theme_provider.dart';
import 'package:universal_quran/quran_translation_package/organized_translationAyah.dart';
import 'package:universal_quran/quran_translation_package/translation_data.dart';
import 'package:universal_quran/quran_translation_package/translation_prefs.dart';
import 'package:universal_quran/quran_translation_package/translations_model_class.dart';

/// Two surahs on pages 1 and 2, in Urdu.
List<TranslationSurahClass> _urdu() => TranslationData.instance.parse({
      'data': {
        'surahs': [
          for (final (n, text) in [(1, 'شروع الله کا نام لے کر'), (2, 'الم')])
            {
              'number': n,
              'englishName': 'S$n',
              'englishNameTranslation': '',
              'revelationType': 'Meccan',
              'ayahs': [
                {'number': n, 'text': text, 'numberInSurah': 1, 'page': n, 'juz': 1, 'sajda': false},
              ],
            },
        ],
      },
    });

Future<void> _pump(WidgetTester tester, String edition) async {
  SharedPreferences.setMockInitialValues({'tr_edition': edition, 'isDarkMode': false});
  await TranslationPrefs.instance.load();
  await TranslationPrefs.instance.setEdition(edition);
  await tester.pumpWidget(ChangeNotifierProvider(
    create: (_) => ThemeNotifier(),
    child: MaterialApp(
      home: OrganizedTranslationAyahViewScreen(surahs: _urdu(), initialPage: 1),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('an Urdu edition sets right-to-left text and turns pages leftward',
      (tester) async {
    await _pump(tester, 'ur.jalandhry');

    expect(tester.widget<PageView>(find.byType(PageView)).reverse, isTrue);
    final prose = tester
        .widgetList<RichText>(find.byType(RichText))
        .where((r) => r.text.toPlainText().contains('شروع'));
    expect(prose, isNotEmpty);
    expect(prose.first.textDirection, TextDirection.rtl);
    expect(prose.first.textAlign, TextAlign.right);

    // Next page is reached by dragging to the right, as in a printed Urdu book.
    expect(find.text('Translation  ·  Page 1'), findsOneWidget);
    await tester.fling(find.byType(PageView), const Offset(400, 0), 1500);
    await tester.pumpAndSettle();
    expect(find.text('Translation  ·  Page 2'), findsOneWidget);
  });

  testWidgets('an English edition stays left-to-right', (tester) async {
    await _pump(tester, 'en.sahih');

    expect(tester.widget<PageView>(find.byType(PageView)).reverse, isFalse);
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1500);
    await tester.pumpAndSettle();
    expect(find.text('Translation  ·  Page 2'), findsOneWidget);
  });
}
