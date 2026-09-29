/// The adhkar said after the obligatory prayers, as data rather than 1,200
/// lines of hand-placed widgets.
///
/// EVERY correction made to the old page is listed in ADHKAR_REVIEW.md.
/// Please have someone qualified check that file before you ship this.
library;

/// Where a passage's Arabic comes from.
enum ArabicSource {
  /// Written here, from the hadith collections.
  hadith,

  /// Pulled from the app's own Quran data at runtime, so it can never drift
  /// from the mushaf. [surah] and [ayah] say which.
  quran,
}

class DhikrPassage {
  final String? arabic; // null when it comes from the Quran data
  final String transliteration;
  final String translation;

  final ArabicSource source;
  final int? surah;
  final int? ayahStart;
  final int? ayahEnd;

  const DhikrPassage({
    this.arabic,
    required this.transliteration,
    required this.translation,
    this.source = ArabicSource.hadith,
    this.surah,
    this.ayahStart,
    this.ayahEnd,
  });

  const DhikrPassage.quran({
    required this.surah,
    required this.ayahStart,
    required this.ayahEnd,
    required this.transliteration,
    required this.translation,
    this.arabic, // fallback if the Quran data is not downloaded yet
  }) : source = ArabicSource.quran;
}

class Dhikr {
  final int number;
  final String title;

  /// "After every obligatory prayer", "After Fajr and Maghrib"…
  final String when;

  /// How many times, for the counter. 1 means a simple tick.
  final int count;

  /// The narration that establishes it, in the narrator's words.
  final String context;

  /// Book and number.
  final String reference;

  /// Grading, where the collection is not Bukhari or Muslim.
  final String? grading;

  final List<DhikrPassage> passages;

  /// The reward the narration mentions, where it states one.
  final String? virtue;

  const Dhikr({
    required this.number,
    required this.title,
    required this.when,
    required this.count,
    required this.context,
    required this.reference,
    required this.passages,
    this.grading,
    this.virtue,
  });
}

/// Opens the section. The old page repeated this hadith twice on the same
/// screen, word for word.
const String kSittingAfterPrayer =
    'The Prophet ﷺ said: "The angels send blessings on any one of you as long '
    'as he remains in the place where he prayed, so long as he does not break '
    'his wudoo\', saying: O Allah, forgive him; O Allah, have mercy on him."';
const String kSittingAfterPrayerRef = 'al-Bukhari 445, Muslim 649';

const List<Dhikr> afterPrayerAdhkar = [
  Dhikr(
    number: 1,
    title: 'Seeking forgiveness, then asking for peace',
    when: 'After every obligatory prayer',
    count: 3,
    context:
        'Thawban said: when the Messenger of Allah ﷺ finished his prayer he '
        'would seek forgiveness three times, and then say: "O Allah, You are '
        'as-Salam…"',
    reference: 'Muslim 591',
    passages: [
      DhikrPassage(
        arabic: 'أَسْتَغْفِرُ اللَّهَ',
        transliteration: 'Astaghfirullah  (three times)',
        translation: 'I seek the forgiveness of Allah.',
      ),
      DhikrPassage(
        arabic:
            'اللَّهُمَّ أَنْتَ السَّلَامُ، وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
        transliteration:
            'Allahumma anta as-Salam, wa minka as-salam, tabarakta ya Dhal-Jalali wal-Ikram',
        translation:
            'O Allah, You are Peace and from You comes peace. Blessed are You, '
            'Possessor of Majesty and Honour.',
      ),
    ],
  ),
  Dhikr(
    number: 2,
    title: 'The declaration of Allah\'s oneness',
    when: 'After every obligatory prayer',
    count: 1,
    context:
        'Ibn az-Zubayr used to say this at the end of every prayer after the '
        'tasleem, and he said: the Messenger of Allah ﷺ used to say these '
        'words after every prayer.',
    reference: 'Muslim 594',
    passages: [
      DhikrPassage(
        arabic:
            'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ '
            'وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ، '
            'لَا إِلَهَ إِلَّا اللَّهُ، وَلَا نَعْبُدُ إِلَّا إِيَّاهُ، لَهُ النِّعْمَةُ وَلَهُ الْفَضْلُ '
            'وَلَهُ الثَّنَاءُ الْحَسَنُ، لَا إِلَهَ إِلَّا اللَّهُ مُخْلِصِينَ لَهُ الدِّينَ وَلَوْ كَرِهَ الْكَافِرُونَ',
        transliteration:
            'La ilaha illallahu wahdahu la sharika lah, lahul-mulku wa lahul-hamdu '
            'wa huwa \'ala kulli shay\'in Qadir. La hawla wa la quwwata illa billah. '
            'La ilaha illallah, wa la na\'budu illa iyyah, lahun-ni\'matu wa lahul-fadlu '
            'wa lahuth-thana\'ul-hasan. La ilaha illallahu mukhlisina lahud-dina '
            'wa law karihal-kafirun',
        translation:
            'There is no god but Allah alone, with no partner. His is the '
            'dominion and His is the praise, and He is able to do all things. '
            'There is no power and no strength except with Allah. There is no '
            'god but Allah, and we worship none but Him. His is grace, His is '
            'bounty, and to Him belongs the finest praise. There is no god but '
            'Allah; we are sincere in devotion to Him, however much the '
            'disbelievers may dislike it.',
      ),
    ],
  ),
  Dhikr(
    number: 3,
    title: 'Asking for help to remember Him',
    when: 'After every obligatory prayer',
    count: 1,
    context:
        'The Messenger of Allah ﷺ took Mu\'adh ibn Jabal by the hand and said: '
        '"Mu\'adh, by Allah I love you." Then he said: "I advise you, Mu\'adh, '
        'never to leave saying after every prayer…"',
    reference: 'Abu Dawud 1522, an-Nasa\'i 1303',
    grading: 'Sahih (al-Albani)',
    passages: [
      DhikrPassage(
        arabic: 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
        transliteration:
            'Allahumma a\'inni \'ala dhikrika wa shukrika wa husni \'ibadatik',
        translation:
            'O Allah, help me to remember You, to thank You, and to worship '
            'You well.',
      ),
    ],
  ),
  Dhikr(
    number: 4,
    title: 'Tasbih, tahmid and takbir',
    when: 'After every obligatory prayer',
    count: 33,
    context:
        'Abu Hurayrah reported that the Messenger of Allah ﷺ said: whoever '
        'glorifies Allah thirty-three times, praises Allah thirty-three times '
        'and magnifies Allah thirty-three times after every prayer — that is '
        'ninety-nine — and then completes the hundred by saying the '
        'declaration below…',
    reference: 'Muslim 597',
    virtue:
        'His sins are forgiven, even if they are like the foam of the sea.',
    passages: [
      DhikrPassage(
        arabic: 'سُبْحَانَ اللَّهِ',
        transliteration: 'Subhan Allah  (thirty-three times)',
        translation: 'Glory be to Allah.',
      ),
      DhikrPassage(
        arabic: 'الْحَمْدُ لِلَّهِ',
        transliteration: 'Alhamdu lillah  (thirty-three times)',
        translation: 'All praise is due to Allah.',
      ),
      DhikrPassage(
        arabic: 'اللَّهُ أَكْبَرُ',
        transliteration: 'Allahu Akbar  (thirty-three times)',
        translation: 'Allah is the Greatest.',
      ),
      DhikrPassage(
        arabic:
            'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ '
            'وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        transliteration:
            'La ilaha illallahu wahdahu la sharika lah, lahul-mulku wa lahul-hamdu '
            'wa huwa \'ala kulli shay\'in Qadir  (once, completing the hundred)',
        translation:
            'There is no god but Allah alone, with no partner. His is the '
            'dominion and His is the praise, and He is able to do all things.',
      ),
    ],
  ),
  Dhikr(
    number: 5,
    title: 'Ayat al-Kursi',
    when: 'After every obligatory prayer',
    count: 1,
    context:
        'Abu Umamah reported that the Messenger of Allah ﷺ said: whoever '
        'recites Ayat al-Kursi after every obligatory prayer, nothing stands '
        'between him and entering Paradise except death.',
    reference: 'an-Nasa\'i, \'Amal al-Yawm wa\'l-Laylah 100; Ibn as-Sunni 121',
    grading: 'Sahih (al-Albani, Sahih al-Jami\' 6464)',
    passages: [
      DhikrPassage.quran(
        surah: 2,
        ayahStart: 255,
        ayahEnd: 255,
        arabic:
            'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ '
            'لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ '
            'يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ '
            'وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
        transliteration:
            'Allahu la ilaha illa Huwal-Hayyul-Qayyum. La ta\'khudhuhu sinatun '
            'wa la nawm. Lahu ma fis-samawati wa ma fil-ard…',
        translation:
            'Allah — there is no god but He, the Ever-Living, the Sustainer of '
            'all. Neither drowsiness nor sleep overtakes Him. To Him belongs '
            'whatever is in the heavens and whatever is on the earth. Who is it '
            'that can intercede with Him except by His permission? He knows what '
            'is before them and what is behind them, and they encompass nothing '
            'of His knowledge except what He wills. His seat extends over the '
            'heavens and the earth, and their preservation tires Him not. He is '
            'the Most High, the Most Great.',
      ),
    ],
  ),
  Dhikr(
    number: 6,
    title: 'The three protecting surahs',
    when: 'After every obligatory prayer — three times each after Fajr and Maghrib',
    count: 1,
    context:
        '\'Uqbah ibn \'Amir said: the Messenger of Allah ﷺ commanded me to '
        'recite al-Mu\'awwidhat at the end of every prayer.',
    reference: 'Abu Dawud 1523, an-Nasa\'i 1336',
    grading: 'Sahih (al-Albani)',
    passages: [
      DhikrPassage.quran(
        surah: 112,
        ayahStart: 1,
        ayahEnd: 4,
        arabic:
            'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ '
            'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
        transliteration:
            'Qul huwal-lahu ahad. Allahus-samad. Lam yalid wa lam yulad. '
            'Wa lam yakun lahu kufuwan ahad.',
        translation:
            'Say: He is Allah, the One. Allah, the Eternal Refuge. He neither '
            'begets nor is born, and there is none comparable to Him. '
            '(Surah al-Ikhlas)',
      ),
      DhikrPassage.quran(
        surah: 113,
        ayahStart: 1,
        ayahEnd: 5,
        arabic:
            'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِن شَرِّ مَا خَلَقَ ۝ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ '
            'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
        transliteration:
            'Qul a\'udhu bi Rabbil-falaq. Min sharri ma khalaq. Wa min sharri '
            'ghasiqin idha waqab. Wa min sharrin-naffathati fil-\'uqad. '
            'Wa min sharri hasidin idha hasad.',
        translation:
            'Say: I seek refuge in the Lord of daybreak, from the evil of what '
            'He created, from the evil of darkness when it settles, from the '
            'evil of those who blow on knots, and from the evil of an envier '
            'when he envies. (Surah al-Falaq)',
      ),
      DhikrPassage.quran(
        surah: 114,
        ayahStart: 1,
        ayahEnd: 6,
        arabic:
            'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ '
            'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
        transliteration:
            'Qul a\'udhu bi Rabbin-nas. Malikin-nas. Ilahin-nas. Min sharril-'
            'waswasil-khannas. Alladhi yuwaswisu fi sudurin-nas. Minal-jinnati '
            'wan-nas.',
        translation:
            'Say: I seek refuge in the Lord of mankind, the Sovereign of '
            'mankind, the God of mankind, from the evil of the retreating '
            'whisperer, who whispers in the breasts of mankind, from among the '
            'jinn and mankind. (Surah an-Nas)',
      ),
    ],
  ),
  Dhikr(
    number: 7,
    title: 'After Fajr: knowledge, provision and accepted deeds',
    when: 'After the Fajr prayer',
    count: 1,
    context:
        'Umm Salamah reported that the Messenger of Allah ﷺ used to say this '
        'after the Fajr prayer.',
    reference: 'Ibn Majah 925',
    grading: 'Sahih (al-Albani, Sahih Ibn Majah 753)',
    passages: [
      DhikrPassage(
        arabic:
            'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا',
        transliteration:
            'Allahumma inni as\'aluka \'ilman nafi\'an, wa rizqan tayyiban, '
            'wa \'amalan mutaqabbalan',
        translation:
            'O Allah, I ask You for beneficial knowledge, wholesome provision, '
            'and deeds that are accepted.',
      ),
    ],
  ),
  Dhikr(
    number: 8,
    title: 'Blessings upon the Prophet ﷺ',
    when: 'After every obligatory prayer',
    count: 1,
    context:
        'The Messenger of Allah ﷺ said: whoever sends blessings upon me once, '
        'Allah sends blessings upon him tenfold, erases ten sins from him and '
        'raises him ten degrees.',
    reference: 'an-Nasa\'i 1297 (wording); the salah itself, al-Bukhari 3370',
    grading: 'Sahih (al-Albani)',
    passages: [
      DhikrPassage(
        arabic:
            'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ '
            'وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
        transliteration:
            'Allahumma salli \'ala Muhammadin wa \'ala ali Muhammad, kama sallayta '
            '\'ala Ibrahima wa \'ala ali Ibrahim, innaka Hamidun Majid',
        translation:
            'O Allah, send blessings upon Muhammad and upon the family of '
            'Muhammad, as You sent blessings upon Ibrahim and upon the family '
            'of Ibrahim. You are indeed Praiseworthy, Most Glorious.',
      ),
      DhikrPassage(
        arabic:
            'اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ '
            'وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
        transliteration:
            'Allahumma barik \'ala Muhammadin wa \'ala ali Muhammad, kama barakta '
            '\'ala Ibrahima wa \'ala ali Ibrahim, innaka Hamidun Majid',
        translation:
            'O Allah, bless Muhammad and the family of Muhammad, as You blessed '
            'Ibrahim and the family of Ibrahim. You are indeed Praiseworthy, '
            'Most Glorious.',
      ),
    ],
  ),
];
