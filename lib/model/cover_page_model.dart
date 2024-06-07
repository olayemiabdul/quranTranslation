class QuranCover{
  final readingActivity=<QuranCoverDescription>[
    QuranCoverDescription('assets/images/audio.png', '20', 'Audio-Quran'),
    QuranCoverDescription('assets/images/quran.png', '2000', 'Translation Only'),
    QuranCoverDescription('assets/images/quran1.png', '200', 'Al-Quran'),
    QuranCoverDescription('assets/images/quran4.png', '10', 'Urdu-Quran'),
    QuranCoverDescription('assets/images/quran3.png', '10', 'Quran Pages'),
    QuranCoverDescription('assets/images/quran2.png', '10', 'English & Arabic Text'),
    QuranCoverDescription('assets/images/tasbir.png', '10', 'Adzkar'),
    QuranCoverDescription('assets/images/mosque3.jpg', '10', 'Prayer Times'),
    QuranCoverDescription('assets/images/kaaba.png', '10', 'Hajj Guide'),
  ];
}

class QuranCoverDescription{
  final String icon;
  final String value;
  final String title;
  QuranCoverDescription(this.icon,this.value,this.title);

}