import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:universal_quran/quran_translation_package/quran_translation_content.dart';
import 'package:universal_quran/quran_translation_package/translation_data.dart';

/// Canonical verse count of each surah. The `/v1/quran/{edition}` response
/// has no `numberOfAyahs`, so the model falls back to the parsed length and
/// comparing against it would prove nothing.
const _verseCounts = [
  7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128,
  111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73,
  54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60,
  49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52, 44,
  28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30,
  20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4,
  5, 6,
];

Map<String, dynamic> _edition(List<List<String>> surahTexts) => {
      'data': {
        'surahs': [
          for (var s = 0; s < surahTexts.length; s++)
            {
              'number': s + 1,
              'englishName': 'S${s + 1}',
              'englishNameTranslation': '',
              'revelationType': 'Meccan',
              'ayahs': [
                for (var a = 0; a < surahTexts[s].length; a++)
                  {
                    'number': s * 1000 + a + 1,
                    'text': surahTexts[s][a],
                    'numberInSurah': a + 1,
                    'page': s + 1,
                    'juz': 1,
                    'sajda': false,
                  },
              ],
            },
        ],
      },
    };

void main() {
  const basmala = 'In the name of Allah, the Merciful.';

  group('Basmala', () {
    test('strips it from ayah 1 when the edition glued it on', () {
      final surahs = TranslationData.instance.parse(_edition([
        [basmala, 'Praise be to Allah.'],
        ['In  the name of ALLAH, the Merciful.   Alif Lam Mim.', 'This is the Book.'],
      ]));
      expect(surahs[1].ayahsEA.first.text, 'Alif Lam Mim.');
      expect(surahs[1].bismillah, basmala);
      expect(surahs[0].ayahsEA.first.text, basmala);
      expect(surahs[0].bismillah, isNull);
    });

    test('adds the heading but leaves the text when nothing is glued on', () {
      final surahs = TranslationData.instance.parse(_edition([
        [basmala],
        ['Alif Lam Mim.'],
      ]));
      expect(surahs[1].ayahsEA.first.text, 'Alif Lam Mim.');
      expect(surahs[1].bismillah, basmala);
    });

    test('never empties an ayah that is only the Basmala', () {
      final surahs = TranslationData.instance.parse(_edition([
        [basmala],
        [basmala],
      ]));
      expect(surahs[1].ayahsEA.first.text, basmala);
    });

    test('leaves a near-miss alone', () {
      final surahs = TranslationData.instance.parse(_edition([
        [basmala],
        ['In the name of Allah, the Merciful One, Alif Lam Mim.'],
      ]));
      expect(surahs[1].ayahsEA.first.text,
          'In the name of Allah, the Merciful One, Alif Lam Mim.');
    });
  });

  test('isRtl', () {
    for (final e in ['ur.ahmedali', 'ur.jalandhry', 'fa.ayati', 'sd.amroti', 'dv.divehi', 'ku.asan']) {
      expect(TranslationData.isRtl(e), isTrue, reason: e);
    }
    for (final e in ['en.sahih', 'fr.hamidullah', 'id.indonesian', 'hi.hindi']) {
      expect(TranslationData.isRtl(e), isFalse, reason: e);
    }
  });

  test('picker lists each edition once, Urdu included', () {
    final codes = TranslationEdition.all.map((e) => e.code).toList();
    expect(codes.toSet().length, codes.length);
    expect(codes, containsAll(['ur.ahmedali', 'ur.jalandhry', 'en.sahih']));
  });

  // Real editions from api.alquran.cloud. Download them with
  //   curl -o <dir>/en.sahih.json https://api.alquran.cloud/v1/quran/en.sahih
  // and run with TRANSLATION_FIXTURES=<dir>. Skipped otherwise.
  final dir = Platform.environment['TRANSLATION_FIXTURES'];
  final files = dir == null || !Directory(dir).existsSync()
      ? <File>[]
      : (Directory(dir).listSync().whereType<File>().where((f) => f.path.endsWith('.json')).toList()
        ..sort((a, b) => a.path.compareTo(b.path)));

  test('verse counts sum to 6236', () {
    expect(_verseCounts.length, 114);
    expect(_verseCounts.reduce((a, b) => a + b), 6236);
  });

  group('real editions', () {
    for (final file in files) {
      final name = file.uri.pathSegments.last.replaceAll('.json', '');
      test(name, () {
        final surahs = TranslationData.instance.parse(json.decode(file.readAsStringSync()));
        expect(surahs.length, 114);

        for (var i = 0; i < 114; i++) {
          final s = surahs[i];
          expect(s.ayahsEA.length, _verseCounts[i], reason: '$name surah ${i + 1}');
          expect(s.ayahsEA.every((a) => a.text.trim().isNotEmpty), isTrue,
              reason: '$name surah ${i + 1} has an empty ayah');
          expect(s.bismillah == null, s.number == 1 || s.number == 9,
              reason: '$name surah ${s.number} Basmala heading');
        }

        final fatiha = surahs[0];
        expect(fatiha.ayahsEA.length, 7);
        final baqarah1 = surahs[1].ayahsEA.first.text;
        expect(baqarah1.trim(), isNotEmpty);
        expect(baqarah1, isNot(startsWith(fatiha.ayahsEA.first.text)));
        expect(surahs[8].bismillah, isNull);

        // Every ayah lands on exactly one of the 604 pages, in order.
        final pages = buildTranslationPages(surahs);
        final placed = [
          for (final p in pages)
            for (final c in p.contents) ...c.ayahs,
        ];
        expect(placed.length, 6236);
        expect(pages.where((p) => p.isEmpty), isEmpty);
        expect(pages[0].contents.first.surahNumber, 1);
        expect(pages[603].contents.last.surahNumber, 114);

        // ignore: avoid_print
        print('$name  1:1 = ${fatiha.ayahsEA.first.text}\n'
            '$name  2:1 = $baqarah1\n'
            '$name  rtl = ${TranslationData.isRtl(name)}');
      });
    }
  }, skip: files.isEmpty ? 'set TRANSLATION_FIXTURES to run' : false);
}
