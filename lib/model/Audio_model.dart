



class Surah {
  final int number;
  final String name;
  final String englishName;
  final List<Ayah> ayahs;

  Surah({required this.number, required this.name, required this.ayahs, required this.englishName});

  factory Surah.fromJson(Map<String, dynamic> json) {
    var ayahsList = json['ayahs'] as List;
    List<Ayah> ayahs = ayahsList.map((i) => Ayah.fromJson(i)).toList();

    return Surah(
      number: json['number'],
      name: json['name'],
      ayahs: ayahs, englishName:json['englishName'],
    );
  }
}
class Ayah {
  Ayah({
    required this.number,
    required this.audio,
    required this.audioSecondary,
    required this.text,
    required this.numberInSurah,
    required this.juz,
    required this.manzil,
    required this.page,
    required this.ruku,
    required this.hizbQuarter,
    required this.sajda,
  });

  final int? number;
  final String? audio;
  final List<String> audioSecondary;
  final String? text;
  final int? numberInSurah;
  final int? juz;
  final int? manzil;
  final int? page;
  final int? ruku;
  final int? hizbQuarter;
  final dynamic? sajda;

  factory Ayah.fromJson(Map<String, dynamic> json){
    return Ayah(
      number: json["number"],
      audio: json["audio"],
      audioSecondary: json["audioSecondary"] == null ? [] : List<String>.from(json["audioSecondary"]!.map((x) => x)),
      text: json["text"],
      numberInSurah: json["numberInSurah"],
      juz: json["juz"],
      manzil: json["manzil"],
      page: json["page"],
      ruku: json["ruku"],
      hizbQuarter: json["hizbQuarter"],
      sajda: json["sajda"],
    );
  }



}