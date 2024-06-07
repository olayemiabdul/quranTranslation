class Surah {
  final int number;
  final String name;
  final String englishName;
  final List<Map<String, dynamic>> ayahs;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.ayahs,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
      ayahs: List<Map<String, dynamic>>.from(json['ayahs']),
    );
  }
}