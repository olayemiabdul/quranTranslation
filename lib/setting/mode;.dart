class MetaSurah {
  final int number;
  final String englishName;
  final String englishNameTranslation;

  MetaSurah({required this.number, required this.englishName, required this.englishNameTranslation});

  factory MetaSurah.fromJson(Map<String, dynamic> json) {
    return MetaSurah(
      number: json['number'],
      englishName: json['englishName'],
      englishNameTranslation: json['englishNameTranslation'],
    );
  }
}

class Ayah {
  final int numberInSurah;
  final String text;

  Ayah({required this.numberInSurah, required this.text});

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      numberInSurah: json['numberInSurah'],
      text: json['text'],
    );
  }
}

