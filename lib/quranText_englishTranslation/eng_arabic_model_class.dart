class SurahEngArabic {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final List<AyahEngArabic> ayahsEA;

  SurahEngArabic({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.ayahsEA,
  });

  factory SurahEngArabic.fromJson(Map<String, dynamic> arabicJson, Map<String, dynamic> englishJson) {
    List<AyahEngArabic> ayahList = (arabicJson['ayahs'] as List).asMap().entries.map((entry) {
      final int index = entry.key;
      final ayahJsonArabic = entry.value;
      final ayahTranslationText = englishJson['ayahs'][index]['text'];
      return AyahEngArabic.fromJson(ayahJsonArabic, ayahTranslationText);
    }).toList();

    return SurahEngArabic(
      number: arabicJson['number'],
      name: arabicJson['name'],
      englishName: arabicJson['englishName'],
      englishNameTranslation: arabicJson['englishNameTranslation'],
      numberOfAyahs: arabicJson['ayahs'].length,
      ayahsEA: ayahList,
    );
  }
}

class AyahEngTranslation {
  final String translation; // English translation text of the Ayah

  AyahEngTranslation({
    required this.translation,
  });
}

class AyahEngArabic {
  final int number;           // Unique Ayah number
  final String text;           // Arabic text of the Ayah
  final int numberInSurah;     // Ayah number within the Surah
  final int juz;               // Juz number
  final int manzil;            // Manzil number
  final int page;              // Page number
  final int ruku;              // Ruku number
  final int hizbQuarter;       // Hizb quarter number
  final bool sajda;            // Sajda (true if the Ayah contains a Sajda mark)
  final int surahNumber;       // Surah number
  final AyahEngTranslation? translation; // English translation object

  AyahEngArabic({
    required this.number,
    required this.text,
    required this.numberInSurah,
    required this.juz,
    required this.manzil,
    required this.page,
    required this.ruku,
    required this.hizbQuarter,
    required this.sajda,
    required this.surahNumber,
    this.translation,
  });

  factory AyahEngArabic.fromJson(Map<String, dynamic> arabicJson, String englishTranslationText) {
    return AyahEngArabic(
      number: arabicJson['number'] ?? 0,
      text: arabicJson['text'] ?? '',
      numberInSurah: arabicJson['numberInSurah'] ?? 0,
      juz: arabicJson['juz'] ?? 0,
      manzil: arabicJson['manzil'] ?? 0,
      page: arabicJson['page'] ?? 0,
      ruku: arabicJson['ruku'] ?? 0,
      hizbQuarter: arabicJson['hizbQuarter'] ?? 0,
      sajda: arabicJson['sajda'] == true,
      surahNumber: arabicJson['surah']?['number'] ?? 0,
      translation: AyahEngTranslation(translation: englishTranslationText),
    );
  }
}

