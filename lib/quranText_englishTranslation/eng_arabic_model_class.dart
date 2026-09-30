/// Models for the Study reader — Arabic and its meaning together.
///
/// Fixes carried over from the old version:
///  * `AyahEngTranslation` was a wrapper around a single String, so every
///    ayah carried its translation behind an extra nullable hop
///    (`ayah.translation?.translation`). It is kept as a deprecated getter
///    so old call sites still compile.
///  * `sajda` was `json['sajda'] == true`, but the API sends an OBJECT for a
///    sajda ayah, so it was always false.
///  * The Arabic and the translation were paired **by list index**
///    (`englishJson['ayahs'][index]['text']`), with no bounds check. If the
///    two editions ever disagreed on ayah count for a surah, every ayah
///    after that point would silently show the wrong meaning, and a short
///    edition would throw a RangeError. They are now paired by ayah number.
///  * `SurahEngArabic.fromJson` threw on any missing field.
library;

class SurahEngArabic {
  final int number;
  final String name; // Arabic
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final int numberOfAyahs;
  final List<AyahEngArabic> ayahsEA;

  /// The edition's rendering of "In the name of Allah…", when this surah
  /// opens with it. Null for Al-Fatiha and At-Tawbah.
  final String? bismillahTranslation;

  SurahEngArabic({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.ayahsEA,
    this.bismillahTranslation,
  });

  bool get isMakki => revelationType.toLowerCase().startsWith('mecc');

  /// True for every surah except Al-Fatiha, where the Basmala is ayah 1,
  /// and At-Tawbah, which has none.
  bool get hasBismillah => number != 1 && number != 9;
}

class AyahEngArabic {
  final int number; // global, 1..6236
  final String text; // Arabic
  final String? translationText;
  final int numberInSurah;
  final int surahNumber;
  final int juz;
  final int manzil;
  final int page;
  final int ruku;
  final int hizbQuarter;
  final bool sajda;

  const AyahEngArabic({
    required this.number,
    required this.text,
    required this.numberInSurah,
    required this.surahNumber,
    required this.juz,
    required this.manzil,
    required this.page,
    required this.ruku,
    required this.hizbQuarter,
    required this.sajda,
    this.translationText,
  });

  /// "2:255" — bookmarks, sharing, lookups.
  String get key => '$surahNumber:$numberInSurah';

  AyahEngArabic withTranslation(String? text) => AyahEngArabic(
        number: number,
        text: this.text,
        numberInSurah: numberInSurah,
        surahNumber: surahNumber,
        juz: juz,
        manzil: manzil,
        page: page,
        ruku: ruku,
        hizbQuarter: hizbQuarter,
        sajda: sajda,
        translationText: text,
      );

  /// Kept so code reading `ayah.translation?.translation` still compiles.
  /// Use `ayah.translationText`.
  @Deprecated('Use AyahEngArabic.translationText')
  AyahEngTranslation? get translation => translationText == null
      ? null
      : AyahEngTranslation(translation: translationText!);

  @override
  bool operator ==(Object other) =>
      other is AyahEngArabic && other.number == number;

  @override
  int get hashCode => number.hashCode;
}

/// Deprecated wrapper. It only ever held one String.
@Deprecated('Use AyahEngArabic.translationText')
class AyahEngTranslation {
  final String translation;
  const AyahEngTranslation({required this.translation});
}
