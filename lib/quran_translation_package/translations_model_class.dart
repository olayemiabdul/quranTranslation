/// Models for the Translation reader (meaning only, no Arabic on the page).
///
/// Fixes carried over from the old version:
///  * `AyahTranslation.text` and `translation.translation` held the SAME
///    string, so every ayah stored its text twice. `translation` is kept as a
///    deprecated passthrough so old call sites still compile.
///  * `sajda` was `json['sajda'] == true`, but the API sends an OBJECT for a
///    sajda ayah, so it was always false.
///  * `TranslationSurahClass.fromJson` would throw on any missing field.
///  * There was no `surahNumber` on an ayah, so nothing could tell which
///    surah an ayah belonged to once it was on a page.
library;

class TranslationSurahClass {
  final int number;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final int numberOfAyahs;
  final List<AyahTranslation> ayahsEA;

  /// The edition's own rendering of "In the name of Allah…", when this surah
  /// opens with it. Null for Al-Fatiha (where it is ayah 1) and At-Tawbah.
  final String? bismillah;

  TranslationSurahClass({
    required this.number,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.ayahsEA,
    this.bismillah,
  });

  factory TranslationSurahClass.fromJson(Map<String, dynamic> json) {
    final number = (json['number'] as num?)?.toInt() ?? 0;
    final rawAyahs = json['ayahs'] is List ? json['ayahs'] as List : const [];

    final ayahs = rawAyahs
        .map((e) => AyahTranslation.fromJson(
              Map<String, dynamic>.from(e as Map),
              surahFallback: number,
            ))
        .toList();

    return TranslationSurahClass(
      number: number,
      englishName: (json['englishName'] ?? '').toString(),
      englishNameTranslation: (json['englishNameTranslation'] ?? '').toString(),
      revelationType: (json['revelationType'] ?? '').toString(),
      // Trust the API's own count; fall back to what we actually parsed.
      numberOfAyahs: (json['numberOfAyahs'] as num?)?.toInt() ?? ayahs.length,
      ayahsEA: ayahs,
    );
  }

  TranslationSurahClass copyWith({
    List<AyahTranslation>? ayahsEA,
    String? bismillah,
  }) =>
      TranslationSurahClass(
        number: number,
        englishName: englishName,
        englishNameTranslation: englishNameTranslation,
        revelationType: revelationType,
        numberOfAyahs: numberOfAyahs,
        ayahsEA: ayahsEA ?? this.ayahsEA,
        bismillah: bismillah ?? this.bismillah,
      );

  bool get isMakki => revelationType.toLowerCase().startsWith('mecc');
}

class AyahTranslation {
  /// Global ayah number, 1..6236. Stable identity, and the key for audio.
  final int number;

  /// The translated text of this ayah.
  final String text;

  final int numberInSurah;
  final int surahNumber;
  final int juz;
  final int manzil;
  final int page;
  final int ruku;
  final int hizbQuarter;
  final bool sajda;

  const AyahTranslation({
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
  });

  factory AyahTranslation.fromJson(
    Map<String, dynamic> json, {
    String? text,
    int surahFallback = 0,
  }) {
    final sajda = json['sajda'];
    return AyahTranslation(
      number: (json['number'] as num?)?.toInt() ?? 0,
      text: (text ?? json['text'] ?? '').toString(),
      numberInSurah: (json['numberInSurah'] as num?)?.toInt() ?? 0,
      surahNumber: (json['surah']?['number'] as num?)?.toInt() ?? surahFallback,
      juz: (json['juz'] as num?)?.toInt() ?? 0,
      manzil: (json['manzil'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 0,
      ruku: (json['ruku'] as num?)?.toInt() ?? 0,
      hizbQuarter: (json['hizbQuarter'] as num?)?.toInt() ?? 0,
      // The API sends `false`, or an object describing the sajda.
      sajda: sajda == true || sajda is Map,
    );
  }

  AyahTranslation copyWith({String? text}) => AyahTranslation(
        number: number,
        text: text ?? this.text,
        numberInSurah: numberInSurah,
        surahNumber: surahNumber,
        juz: juz,
        manzil: manzil,
        page: page,
        ruku: ruku,
        hizbQuarter: hizbQuarter,
        sajda: sajda,
      );

  /// "2:255" — used for bookmarks, sharing and lookups.
  String get key => '$surahNumber:$numberInSurah';

  /// Kept so existing code reading `ayah.translation.translation` still
  /// compiles. Use `ayah.text`.
  @Deprecated('Use AyahTranslation.text')
  AyahAllTranslations get translation => AyahAllTranslations(translation: text);

  @override
  bool operator ==(Object other) =>
      other is AyahTranslation && other.number == number;

  @override
  int get hashCode => number.hashCode;
}

/// Deprecated wrapper. It only ever held a copy of [AyahTranslation.text].
@Deprecated('Use AyahTranslation.text')
class AyahAllTranslations {
  final String translation;
  const AyahAllTranslations({required this.translation});
}
