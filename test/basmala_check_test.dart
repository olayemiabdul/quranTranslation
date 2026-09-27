import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_quran/quran_ayah/surah_class.dart';

void main() {
  test('no ayah lost to the Basmala strip', () {
    final raw = json.decode(File('C:/Users/olaye/AppData/Local/Temp/claude/C--src-quran-universal/3bde4374-3d75-41bc-a196-c37759ece4f8/scratchpad/uthmani.json').readAsStringSync());
    final surahs = (raw['data']['surahs'] as List)
        .map((e) => Surah.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    expect(surahs.length, 114);
    for (final s in surahs) {
      expect(s.ayahs.length, s.numberOfAyahs, reason: 'surah ${s.number}');
      expect(s.ayahs.first.numberInSurah, 1, reason: 'surah ${s.number}');
      expect(s.ayahs.every((a) => a.text.trim().isNotEmpty), true);
    }
    final baqarah = surahs[1];
    expect(baqarah.ayahs.length, 286);
    expect(baqarah.ayahs.first.text, contains('الٓمٓ'));
    expect(baqarah.ayahs.first.text, isNot(contains('بِسْمِ')));
    final fatiha = surahs[0];
    expect(fatiha.ayahs.length, 7);
    expect(fatiha.ayahs.first.text, contains('بِسْمِ'));
    final tawbah = surahs[8];
    expect(tawbah.ayahs.length, 129);
    expect(tawbah.ayahs.first.text, isNot(startsWith('بِسْمِ')));
    // Every other surah: basmala actually stripped from ayah 1.
    final leftover = surahs
        .where((s) => s.hasBismillah && s.ayahs.first.text.startsWith('بِسْمِ'))
        .map((s) => s.number)
        .toList();
    print('Baqarah 2:1 = ${baqarah.ayahs.first.text}');
    print('Surahs still starting with basmala: $leftover');
    expect(leftover, isEmpty);
  });
}
