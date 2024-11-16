class UrduSurahClass {
  final int number;                    // Surah number
  final String name;                   // Surah name in Arabic
  final String englishName;            // English name of the Surah
  final String englishNameTranslation; // Translation of the Surah's English name
  final int numberOfAyahs;             // Total number of Ayahs in the Surah
  final List<UrduAyahTranslation> ayahsUA; // List of Ayah translations in Urdu

  UrduSurahClass({
    required this.number,
    required this.name,                // Added property
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.ayahsUA,
  });

  factory UrduSurahClass.fromJson(Map<String, dynamic> englishJson) {
    List<UrduAyahTranslation> ayahList = (englishJson['ayahs'] as List)
        .map((ayahJson) => UrduAyahTranslation.fromJson(ayahJson))
        .toList();

    return UrduSurahClass(
      number: englishJson['number'],
      name: englishJson['name'],  // Map the new property
      englishName: englishJson['englishName'],
      englishNameTranslation: englishJson['englishNameTranslation'],
      numberOfAyahs: englishJson['ayahs'].length,
      ayahsUA: ayahList,
    );
  }
}

class UrduAyahAllTranslations {
  final String translation; // English translation text of the Ayah

  UrduAyahAllTranslations({
    required this.translation,
  });
}

class UrduAyahTranslation {
  final int number;           // Unique Ayah number
  final String text;          // Arabic text of the Ayah
  final int numberInSurah;    // Ayah number within the Surah
  final int juz;              // Juz number
  final int manzil;           // Manzil number
  final int page;             // Page number
  final int ruku;             // Ruku number
  final int hizbQuarter;      // Hizb quarter number
  final bool sajda;           // Sajda (true if the Ayah contains a Sajda mark)
  final UrduAyahAllTranslations translation; // English translation object

  UrduAyahTranslation({
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

  factory UrduAyahTranslation.fromJson(Map<String, dynamic> englishJson) {
    return UrduAyahTranslation(
      number: englishJson['number'] ?? 0,
      text: englishJson['text'] ?? '',
      numberInSurah: englishJson['numberInSurah'] ?? 0,
      juz: englishJson['juz'] ?? 0,
      manzil: englishJson['manzil'] ?? 0,
      page: englishJson['page'] ?? 0,
      ruku: englishJson['ruku'] ?? 0,
      hizbQuarter: englishJson['hizbQuarter'] ?? 0,
      sajda: englishJson['sajda'] == true,
      translation: UrduAyahAllTranslations(translation: englishJson['text']),
    );
  }
}
