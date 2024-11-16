class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final int numberOfAyahs;
  final List<Ayah> ayahs;
  final bool hasBismillah;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.ayahs,
    required this.hasBismillah,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    List<Ayah> ayahsList = [];
    bool hasBismillah = true;

    if (json['ayahs'] != null && json['ayahs'] is List) {
      var ayahsData = json['ayahs'] as List;

      // Check if first ayah is Bismillah
      if (ayahsData.isNotEmpty &&
          ayahsData[0]['text'] != null &&
          ayahsData[0]['text'].contains('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ')) {
        // Skip Bismillah for Surah Al-Fatiha and At-Tawbah
        if (json['number'] != 1 && json['number'] != 9) {
          ayahsData = ayahsData.sublist(1);
        }
        hasBismillah = true;
      } else {
        hasBismillah = false;
      }

      ayahsList = ayahsData.map((ayahJson) => Ayah.fromJson(ayahJson)).toList();
    }

    return Surah(
      number: json['number'] ?? 0,
      name: json['name'] ?? '',
      englishName: json['englishName'] ?? '',
      englishNameTranslation: json['englishNameTranslation'] ?? '',
      revelationType: json['revelationType'] ?? '',
      numberOfAyahs: json['numberOfAyahs'] ?? 0,
      ayahs: ayahsList,
      hasBismillah: hasBismillah,
    );
  }
}

class Ayah {
  final int number;
  final String text;
  final int numberInSurah;
  final int juz;
  final int manzil;
  final int page;
  final int ruku;
  final int hizbQuarter;
  final bool sajda;
  final int surahNumber;

  Ayah({
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
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'] ?? 0,
      text: json['text'] ?? '',
      numberInSurah: json['numberInSurah'] ?? 0,
      juz: json['juz'] ?? 0,
      manzil: json['manzil'] ?? 0,
      page: json['page'] ?? 0,
      ruku: json['ruku'] ?? 0,
      hizbQuarter: json['hizbQuarter'] ?? 0,
      sajda: json['sajda'] == true,  // Ensures `sajda` is treated as a boolean
      surahNumber: json['surah']?['number'] ?? 0,
    );
  }
}
