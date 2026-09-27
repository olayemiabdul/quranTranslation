/// Models for the Easy Read (flowing text) reader.
///
/// IMPORTANT FIX: the alquran.cloud `quran-uthmani` edition prefixes the
/// Basmala onto the TEXT of ayah 1 of every surah except Al-Fatiha (1) and
/// At-Tawbah (9). The previous version of this file deleted that whole first
/// ayah (`ayahsData.sublist(1)`), which silently removed ayah 1 from 112
/// surahs. We now keep the ayah and strip only the Basmala from its text,
/// rendering the Basmala separately as a heading.
library;

const String kBasmala = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

/// The Basmala's base letters, with no diacritics or spaces.
const String _basmalaLetters = 'بسماللهالرحمنالرحيم';

/// Harakat, shadda, superscript alef, Quranic marks and tatweel.
bool _isMark(int c) =>
    (c >= 0x0610 && c <= 0x061A) ||
    (c >= 0x064B && c <= 0x065F) ||
    c == 0x0670 ||
    c == 0x0640 ||
    (c >= 0x06D6 && c <= 0x06ED);

/// Removes a leading Basmala by comparing base letters only, so neither the
/// order of diacritics (the edition writes shadda before fatha, and one surah
/// adds a shadda on the ba) nor a small change upstream can defeat it.
/// Returns [text] unchanged when it does not start with the Basmala.
String stripLeadingBasmala(String text) {
  final t = text.codeUnits;
  var i = 0;
  var j = 0;
  while (j < _basmalaLetters.length) {
    while (i < t.length && (_isMark(t[i]) || t[i] == 0x20)) {
      i++;
    }
    if (i >= t.length) return text;
    final c = t[i] == 0x0671 ? 0x0627 : t[i]; // alef wasla -> alef
    if (c != _basmalaLetters.codeUnitAt(j)) return text;
    i++;
    j++;
  }
  while (i < t.length && _isMark(t[i])) {
    i++;
  }
  return String.fromCharCodes(t, i).trim();
}

class Surah {
  final int number;
  final String name; // Arabic
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final int numberOfAyahs;
  final List<Ayah> ayahs;

  /// True when this surah is preceded by the Basmala (every surah except
  /// Al-Fatiha, where it is ayah 1, and At-Tawbah, which has none).
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
    final int number = json['number'] ?? 0;
    final List<dynamic> raw =
        (json['ayahs'] is List) ? json['ayahs'] as List : const [];

    final bool hasBismillah = number != 1 && number != 9;

    final ayahs = <Ayah>[];
    for (var i = 0; i < raw.length; i++) {
      final map = Map<String, dynamic>.from(raw[i] as Map);
      var text = (map['text'] ?? '').toString();

      // Strip the Basmala prefix from ayah 1 only, and only where it is not
      // part of the ayah itself. Al-Fatiha keeps it: there it IS ayah 1.
      if (i == 0 && hasBismillah) {
        final stripped = stripLeadingBasmala(text);
        // Never let the strip empty an ayah (An-Naml 27:30 contains the
        // Basmala mid-surah, and some editions differ).
        if (stripped.isNotEmpty) text = stripped;
      }

      ayahs.add(Ayah.fromJson(map, text: text, surahFallback: number));
    }

    return Surah(
      number: number,
      name: json['name'] ?? '',
      englishName: json['englishName'] ?? '',
      englishNameTranslation: json['englishNameTranslation'] ?? '',
      revelationType: json['revelationType'] ?? '',
      numberOfAyahs: json['numberOfAyahs'] ?? ayahs.length,
      ayahs: ayahs,
      hasBismillah: hasBismillah,
    );
  }

  bool get isMakki => revelationType.toLowerCase().startsWith('mecc');
}

class Ayah {
  /// Global ayah number, 1..6236. Used for audio and as a stable identity.
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

  const Ayah({
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

  factory Ayah.fromJson(
    Map<String, dynamic> json, {
    String? text,
    int surahFallback = 0,
  }) {
    final sajda = json['sajda'];
    return Ayah(
      number: json['number'] ?? 0,
      text: text ?? (json['text'] ?? '').toString(),
      numberInSurah: json['numberInSurah'] ?? 0,
      juz: json['juz'] ?? 0,
      manzil: json['manzil'] ?? 0,
      page: json['page'] ?? 0,
      ruku: json['ruku'] ?? 0,
      hizbQuarter: json['hizbQuarter'] ?? 0,
      // The API sends either `false` or an object describing the sajda.
      sajda: sajda == true || sajda is Map,
      surahNumber: json['surah']?['number'] ?? surahFallback,
    );
  }

  String get key => '$surahNumber:$numberInSurah';

  @override
  bool operator ==(Object other) => other is Ayah && other.number == number;

  @override
  int get hashCode => number.hashCode;
}

/// ٠١٢٣ — used for ayah and page numbers.
String toArabicDigits(int n) {
  const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return n.toString().split('').map((c) {
    final i = int.tryParse(c);
    return i == null ? c : d[i];
  }).join();
}
