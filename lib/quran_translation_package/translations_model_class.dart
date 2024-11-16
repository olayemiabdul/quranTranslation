
class TranslationSurahClass {
  final int number;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final List<AyahTranslation> ayahsEA;

  TranslationSurahClass({
    required this.number,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.ayahsEA,
  });

  factory TranslationSurahClass.fromJson(Map<String, dynamic> englishJson) {
    List<AyahTranslation> ayahList = (englishJson['ayahs'] as List)
        .map((ayahJson) => AyahTranslation.fromJson(ayahJson))
        .toList();

    return TranslationSurahClass(
      number: englishJson['number'],
      englishName: englishJson['englishName'],
      englishNameTranslation: englishJson['englishNameTranslation'],
      numberOfAyahs: englishJson['ayahs'].length,
      ayahsEA: ayahList,
    );
  }
}

class AyahAllTranslations {
  final String translation; // English translation text of the Ayah

  AyahAllTranslations({
    required this.translation,
  });
}

class AyahTranslation {
  final int number;           // Unique Ayah number
  final String text;           // Arabic text of the Ayah
  final int numberInSurah;     // Ayah number within the Surah
  final int juz;               // Juz number
  final int manzil;            // Manzil number
  final int page;              // Page number
  final int ruku;              // Ruku number
  final int hizbQuarter;       // Hizb quarter number
  final bool sajda;            // Sajda (true if the Ayah contains a Sajda mark)
  final AyahAllTranslations translation; // English translation object

  AyahTranslation({
    required this.number,
    required this.text,
    required this.numberInSurah,
    required this.juz,
    required this.manzil,
    required this.page,
    required this.ruku,
    required this.hizbQuarter,
    required this.sajda,
    required this.translation,
  });

  factory AyahTranslation.fromJson(Map<String, dynamic> englishJson) {
    return AyahTranslation(
      number: englishJson['number'] ?? 0,
      text: englishJson['text'] ?? '',
      numberInSurah: englishJson['numberInSurah'] ?? 0,
      juz: englishJson['juz'] ?? 0,
      manzil: englishJson['manzil'] ?? 0,
      page: englishJson['page'] ?? 0,
      ruku: englishJson['ruku'] ?? 0,
      hizbQuarter: englishJson['hizbQuarter'] ?? 0,
      sajda: englishJson['sajda'] == true,
      translation: AyahAllTranslations(translation: englishJson['text']),
    );
  }
}
