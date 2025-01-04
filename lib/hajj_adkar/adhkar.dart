import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RemembrancePage extends StatelessWidget {
  const RemembrancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(
              'assets/images/mosque2.png',
            ),
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.7), BlendMode.dstATop),
          ),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50)),
          //color:gridContainerColor,
        ),
        child: PageView(
          children: [
            const Column(
              children: [
                SizedBox(
                  height: 60,
                ),
                Center(
                  child: Text(
                    'بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                    style: TextStyle(
                        wordSpacing: 2,
                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(
                          'Complete Authentic Adhkar/duas (REMEMBRANCES)')),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: Text(' AFTER EVERY OBLIGATORY PRAYER')),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(
                          'The Prophet, sallallaahu ‘alayhi wa sallam, said: “The angels invoke blessings on any of you who remains in his prayer place as long as he does not invalidate his ablution, saying, ‘O Allaah, forgive him; O Allaah, have mercy on him.’” [Maalik, Al-Bukhari and others]')),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(
                          'The Prophet, sallallaahu ‘alayhi wa sallam, said: “The angels invoke blessings on any of you who remains in his prayer place as long as he does not invalidate his ablution, saying, ‘O Allaah, forgive him; O Allaah, have mercy on him.’” [Maalik, Al-Bukhari and others]')),
                ),
              ],
            ),
            Column(
              children: [
                const SizedBox(
                  height: 60,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        height: 25,
                        width: 25,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: const Text(
                          '1',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text('Once- Immediately after Tesleem')
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 220),
                  child: Text(
                    'اللّٰهُ أَكْبَر ',
                    style: TextStyle(
                        wordSpacing: 2,
                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 200, top: 8),
                  child: Text(
                    'Transliteration',
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 200, top: 8),
                  child: Text(
                    ' ALLAHU AKBAR.',
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 200, top: 8),
                  child: Text(
                    ' God is the greatest.',
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        height: 25,
                        width: 25,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: const Text(
                          '2',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text('Three- After every obligatory prayers')
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      ' Thawbaan who said: “When Allaah’s Messenger (صلى الله عليه و سلم) finished his Prayer he would seek forgiveness three times,'),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'أَسْتَغْفِرُ اللَّهَ، * أَسْتَغْفِرُ اللَّهَ،* أَسْتَغْفِرُ اللَّهَ ',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 270, top: 8),
                  child: Text(
                    'Transliteration',
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 40, top: 8),
                  child: Text(
                    ' Astaghfirullaaha, Astaghfirullaaha, Astaghfirullaaha.',
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 180, top: 8),
                  child: Text(
                    ' I seek the forgiveness of Allah',
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('and say:'),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'اللَّهُمَّ أَنْتَ السَّلاَمُ، وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالإِكْرَا ',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Allaahumma ‘Antas-Salaamu wa minkas-salaamu, tabaarakta yaa Thal-Jalaali wal-‘Ikraam ',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'O Allah You are the Flawless One, and from You comes peace and security. Blessed are You, Possessor of Majesty and Honour) [Muslim 591] ',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            ListView(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        height: 25,
                        width: 25,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: const Text(
                          '3',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text('Once- After every obligatory prayers')
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      '  Ibn az-Zubayr used to say at the end of every Prayer when he had given the Salutation: and he said: “Allah’s Messenger (صلى الله عليه و سلم) used to repeat these words after every Prayer.”'),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'لاَ إلَهَ إِلاَّ اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، لَا حَوْلَ وَلاَ قُوَّةَ إِلَاَّ بِاللَّهِ، لَا إِلَهَ إِلَاَّ اللَّهُ، وَلَا نَعْبُدُ إِلَاَّ إِيَّاهُ، لَهُ النِّعْمَةُ وَلَهُ الْفَضْلُ وَلَهُ الثَّنَاءُ الْحَسَنُ، لَا إِلَهَ إِلاَّ اللَّهُ مُخْلِصِينَ لَهُ الدِّينَ وَلَوْ كَرِهَ الْكَافِرُونَ',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 270, top: 8),
                  child: Text(
                    'Transliteration',
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 40, top: 8),
                  child: Text(
                    ' Laa ‘ilaaha ‘illallaahu wahdahu laa shareeka lahu, lahul-mulku, wa lahul-hamdu wa Huwa ‘alaa kulli shay ‘in Qadeer. Laa hawla wa laa quwwata ‘illaa billaahi, laa ‘ilaaha ‘illallaahu, wa laa na’budu ‘illaa ‘iyyaahu, lahun-ni’matu wa lahul-fadhlu wa lahuth-thanaa’ul-hasanu, laa ‘ilaaha ‘illallaahu mukhliseena lahud-deena wa law karihal-kaafiroon',
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    ' (None has the right to be worshiped but Allah alone, He has no partner, His is the dominion and His is the praise and He is Able to do all things. There is no power and no might except by Allah. None has the right to be worshiped but Allah, and we do not worship any other besides Him. His is grace, and His is bounty and to Him belongs the most excellent praise. None has the right to be worshiped but Allah. (We are) sincere in making our religious devotion to Him, even though the disbelievers may dislike it) [Muslim 594]',
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            ListView(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        height: 25,
                        width: 25,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: const Text(
                          '4',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text('33*/1- After every obligatory prayers')
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      'Saying: Subhaanallaah’, ‘al-hamdu lillaah’, and ‘Allaahu Akbar’- thirty three times each after every Praye [al-Bukhari (no. 843) and Muslim (no. 595) from a hadeeth of Abu Hurairah-radiyallaahu `anhu]'),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'سبحان الله، *33 الحمد للهَ،*33 الله أكبر33 ',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 270, top: 8),
                  child: Text(
                    'Transliteration',
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 40, top: 8),
                  child: Text(
                    ' Allahu Akbar, Al-hamdu lillah, Subhan Allah.',
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 180, top: 8),
                  child: Text(
                    ' Allah is free from imperfection, \nAll praise is due to Allah,\n Allah is the Greatest',
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('and say:'),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'لا إلهَ إلاّ اللّهُ وَحْـدَهُ لا شريكَ لهُ، لهُ الملكُ ولهُ الحَمْد، وهُوَ على كُلّ شَيءٍ قَـدير ',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Laa ‘ilaaha ‘illallaahu wahdahu laa shareeka lahu, lahul-mulku wa lahul-hamdu wa Huwa a’laa kulli shay’in Qadeer ',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'there is no god worthy of worship except Allah alone, with no partner or associate. His is the Dominion and to Him be praise, and He is able to do all things ',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'whoever does so after every Prayer then his sins will be forgiven even if they are like the foam of the sea. ',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '[Reported by Muslim (no.597) from a hadeeth of Abu Hurairah-radiyallaahu `anhu]. ',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            ListView(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        height: 25,
                        width: 25,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: const Text(
                          '5',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text('Once- After every obligatory prayers')
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      'Abu Umamah reported: The Messenger of Allah, peace and blessings be upon him, said, “Whoever recites the verse of the Throne (ayat al-kursi) after every obligatory prayer, there will be nothing standing between him and his entering Paradise except death.”',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, color: Colors.white)),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      '  [An-Nasa’i, ‘Amalul-Yawm wal-Laylah (Hadith no. 100), also Ibn As-Sunni (no. 121). See also Al-Albani, Sahihul-Jami’ As-Saghir 5/339 and Silsilatul-Ahadith As-Sahihah 2/697 (no. 972)]',
                      style: TextStyle(color: Colors.white)),
                ),
                const Center(
                  child: Text(
                    'بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                    style: TextStyle(
                        wordSpacing: 2,
                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'للَّهُ لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الأَرْضِ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلاَّ بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلاَ يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلاَّ بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالأَرْضَ وَلاَ يَئُودُهُ حِفْظُهُمَاوَهُوَ الْعَلِيُّ الْعَظِيمُ',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 270, top: 8),
                  child: Text(
                    'Transliteration',
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 40, top: 8),
                  child: Text(
                    ' Allahu la ilaha illa Huwa, Al-Haiyul-Qaiyum La ta’khudhuhu sinatun wa la nawm, lahu ma fis-samawati wa ma fil-‘ard Man dhal-ladhi yashfa’u ‘indahu illa bi-idhnihi Ya’lamu ma baina aidihim wa ma khalfahum, wa la yuhituna bi shai’im-min ‘ilmihi illa bima sha’a Wasi’a kursiyuhus-samawati wal ard, wa la ya’uduhu hifdhuhuma Wa Huwal ‘Aliyul-Adheem.',
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    ' In the name of Allah, the Beneficent, the Merciful. “Allah! There is no god but He – the Living, The Self-subsisting, Eternal. No slumber can seize Him Nor Sleep. His are all things In the heavens and on earth. Who is there can intercede In His presence except As he permitteth? He knoweth What (appeareth to His creatures As) Before or After or Behind them. Nor shall they encompass Aught of his knowledge Except as He willeth. His throne doth extend Over the heavens And on earth, and He feeleth No fatigue in guarding And preserving them, For He is the Highest. The Supreme (in glory).',
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            ListView(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        height: 25,
                        width: 25,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: const Text(
                          '6',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text('Once- but thrice After Fajr & Maghrib prayers')
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      '‘Uqbah bin ‘Aamir (رضي الله عنه) said: “The Messenger of Allah (ﷺ) has commanded me to recite ‘al-Mu’awwidhaat (The 3 Quls)’ at the end of every prayer.”',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, color: Colors.white)),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      '  [Abu Dawud (1523), an-Nasa’i (1336), Musnad (4/155), Authenticated by al-Albani in Sahih Abi Dawood no. 1348].',
                      style: TextStyle(color: Colors.white)),
                ),
                const Center(
                  child: Text(
                    'بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                    style: TextStyle(
                        wordSpacing: 2,
                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'قُلۡ هُوَ ٱللَّهُ أَحَدٌ* ٱللَّهُ ٱلصَّمَدُ* لَمۡ يَلِدۡ وَلَمۡ يُولَدۡ* وَلَمۡ يَكُن لَّهُۥ كُفُوًا أَحَدُۢ',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right,
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(right: 270, top: 8),
                  child: Text(
                    'Transliteration',
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 40, top: 8),
                  child: Text(
                    ' Qul huwal laahu ahad * Allah hus-samad* Lam yalid wa lam yoolad*  Wa lam yakul-lahoo kufuwan ahad',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    ' “Say: He is Allah, who is One. Allah, the Eternal Refuge. He neither begets nor was He begotten, nor is there to Him any equivalent.” [al-Ikhlas 112:1-4]',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    ' Abu Said narrated, “The Prophet asked his companions, “Is it difficult for any of you to recite one-third of the Quran in one night?” They replied, “Who among us has the power to do so?” Allah’s Apostle said, “Allah (the) one, the self-sufficient master whom all creatures need.”',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    ' Narrated by Al-Tirmidhi, “Say Surat Al Ikhlas and al-Mu’awwidhatayn three times in the morning and the evening; they will suffice you from everything.”',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    ' Aisha RA narrated, “Whenever the Prophet went to bed every night, he cupped his hands together and blew over them after reciting Surah Al Ikhlas, Surah an-Nas and Surah al-Falaq. Then, he rubbed his hands over every part of his body he could, starting with his face, head and front. He did that three times every night.”',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            ListView(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        height: 25,
                        width: 25,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: const Text(
                          '7',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    const Text('Once- but thrice After Fajr & Maghrib prayers')
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      '‘Uqbah bin ‘Aamir (رضي الله عنه) said: “The Messenger of Allah (ﷺ) has commanded me to recite ‘al-Mu’awwidhaat (The 3 Quls)’ at the end of every prayer.”',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, color: Colors.white)),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      '  [Abu Dawud (1523), an-Nasa’i (1336), Musnad (4/155), Authenticated by al-Albani in Sahih Abi Dawood no. 1348].',
                      style: TextStyle(color: Colors.white)),
                ),
                const Center(
                  child: Text(
                    'بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                    style: TextStyle(
                        wordSpacing: 2,
                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    ' قُلْ أَعُوذُ بِرَبِّ الْفَلَقٌِ* مِنْ شَرِّ مَا خَلَقَ*وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَۡ* وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ*  مِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَُۢ',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right,
                  ),
                ),



                const Padding(
                  padding: EdgeInsets.only(right: 270, top: 8),
                  child: Text(
                    'Transliteration',
                    textAlign: TextAlign.left,
                  ),
                ),

                const Padding(

                  padding: EdgeInsets.only(right: 40, top: 8),
                  child: Text(
                    ' Qul a’oozu bi rabbil-falaq * Min sharri maa khalaq* Wa min sharri ghaasiqin izaa waqab*  Wa min sharrin-naffaa-saati fil ‘uqad * Wa min sharri haasidin izaa hasad',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    ' “Say: I seek refuge in the Lord of daybreak, from the evil of that which He created, from the evil of darkness when it settles, from the evil of the blowers in knots (those who practice magic), and from the evil of an envier when he envies.” [al-Falaq 113:1-5]',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    ' The Messenger of Allah (ﷺ) used to seek protection against the evil of jinn and the evil eyes till Surat Al-Falaq and Surat An-Nas were revealed. After they were revealed, he took to them for seeking Allah’s protection and left everything besides them. [At- Tirmidhi]\n '
                        ,
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    ' Narrated by Al-Tirmidhi, “Say Surat Al Ikhlas and al-Mu’awwidhatayn three times in the morning and the evening; they will suffice you from everything.”',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    ' Aisha RA narrated, “Whenever the Prophet went to bed every night, he cupped his hands together and blew over them after reciting Surah Al Ikhlas, Surah an-Nas and Surah al-Falaq. Then, he rubbed his hands over every part of his body he could, starting with his face, head and front. He did that three times every night.”',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            ListView(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        height: 25,
                        width: 25,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: const Text(
                          '8',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    const Text('Once- but thrice After Fajr & Maghrib prayers')
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      '‘Uqbah bin ‘Aamir (رضي الله عنه) said: “The Messenger of Allah (ﷺ) has commanded me to recite ‘al-Mu’awwidhaat (The 3 Quls)’ at the end of every prayer.”',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, color: Colors.white)),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      '  [Abu Dawud (1523), an-Nasa’i (1336), Musnad (4/155), Authenticated by al-Albani in Sahih Abi Dawood no. 1348].',
                      style: TextStyle(color: Colors.white)),
                ),
                const Center(
                  child: Text(
                    'بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                    style: TextStyle(
                        wordSpacing: 2,
                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    ' قُلْ أَعُوذُ بِرَبِّ النَّاسِ* مَلِكِ النَّاسِ* إِلَٰهِ النَّاسِ* مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ* الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ* مِنَ الْجِنَّةِ وَالنَّاسِ',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right,
                  ),
                ),




                const Padding(
                  padding: EdgeInsets.only(right: 270, top: 8),
                  child: Text(
                    'Transliteration',
                    textAlign: TextAlign.left,
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(right: 40, top: 8),
                  child: Text(
                    ' Qul a’oozu birabbin naas * Malikin naas* Ilaahin naas*  Min sharril waswaasil khannaas * Allazee yuwaswisu fee sudoorin naas* Minal jinnati wannaas',
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    ' “Say: I seek refuge in the Lord of mankind, the Sovereign of mankind, the God of mankind, from the evil of the retreating whisperer (a devil), who whispers evil into the breasts of mankind, from among the jinn and mankind.” [an-Naas: 114:1-6]',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    ' The Messenger of Allah (ﷺ) used to seek protection against the evil of jinn and the evil eyes till Surat Al-Falaq and Surat An-Nas were revealed. After they were revealed, he took to them for seeking Allah’s protection and left everything besides them. [At- Tirmidhi]\n '
                        ,
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    ' Aisha RA narrated, “Whenever the Prophet went to bed every night, he cupped his hands together and blew over them after reciting Surah Al Ikhlas, Surah an-Nas and Surah al-Falaq. Then, he rubbed his hands over every part of his body he could, starting with his face, head and front. He did that three times every night.”',
                    style: TextStyle(
                        //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        height: 25,
                        width: 25,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: const Text(
                          '9',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text('Once- After every Fajr prayers')
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      '  Ibn az-Zubayr used to say at the end of every Prayer when he had given the Salutation: and he said: “Allah’s Messenger (صلى الله عليه و سلم) used to repeat these words after every Prayer.”'),
                ), const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْماً نَافِعاً، وَرِزْقاً طَيِّباً، وَعَمَلاً مُتَقَبَّلاً',
                    style: TextStyle(
                      //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 270, top: 8),
                  child: Text(
                    'Transliteration',
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 40, top: 8),
                  child: Text(
                    ' Allaahumma ‘innee ‘as’aluka ‘ilman naafi’an, wa rizqan tayyiban, wa ‘amalan mutaqabbalan.',
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    ' (O Allah, I ask You for knowledge that is of benefit , a good provision , and deeds that will be accepted) (Recite in Arabic after the Fajr prayer)',
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    ' [Ibn Majah and others. See Al-Albani, Sahih Ibn Majah 1/152 and Majma’uz-Zawd’id 10/111]',
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        height: 25,
                        width: 25,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: const Text(
                          '10',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text('Once- After every obligatory prayers')
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      '  Ibn az-Zubayr used to say at the end of every Prayer when he had given the Salutation: and he said: “Allah’s Messenger (صلى الله عليه و سلم) used to repeat these words after every Prayer.”'),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'لاَ إلَهَ إِلاَّ اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، لَا حَوْلَ وَلاَ قُوَّةَ إِلَاَّ بِاللَّهِ، لَا إِلَهَ إِلَاَّ اللَّهُ، وَلَا نَعْبُدُ إِلَاَّ إِيَّاهُ، لَهُ النِّعْمَةُ وَلَهُ الْفَضْلُ وَلَهُ الثَّنَاءُ الْحَسَنُ، لَا إِلَهَ إِلاَّ اللَّهُ مُخْلِصِينَ لَهُ الدِّينَ وَلَوْ كَرِهَ الْكَافِرُونَ',
                    style: TextStyle(
                      //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 270, top: 8),
                  child: Text(
                    'Transliteration',
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 40, top: 8),
                  child: Text(
                    'Laa ‘ilaaha ‘illallaahu wahdahu laa shareeka lahu, lahul-mulku, wa lahul-hamdu wa Huwa ‘alaa kulli shay ‘in Qadeer. Laa hawla wa laa quwwata ‘illaa billaahi, laa ‘ilaaha ‘illallaahu, wa laa na’budu ‘illaa ‘iyyaahu, lahun-ni’matu wa lahul-fadhlu wa lahuth-thanaa’ul-hasanu, laa ‘ilaaha ‘illallaahu mukhliseena lahud-deena wa law karihal-kaafiroon.',
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    ' (None has the right to be worshiped but Allah alone, He has no partner, His is the dominion and His is the praise and He is Able to do all things. There is no power and no might except by Allah. None has the right to be worshiped but Allah, and we do not worship any other besides Him. His is grace, and His is bounty and to Him belongs the most excellent praise. None has the right to be worshiped but Allah. (We are) sincere in making our religious devotion to Him, even though the disbelievers may dislike it) [Muslim 594]',
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        height: 25,
                        width: 25,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: const Text(
                          '11',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text('Once- After every obligatory prayers')
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      '   He ﷺ said: “Whoever sends blessings upon me once, Allah will send blessings upon him tenfold and will erase from him ten misdeeds and raise him ten degrees in status.” Narrated by an-Nasaa’i (1297); classed as saheeh by al-Albaani in Saheeh Sunan an-Nasaa’i.', textAlign: TextAlign.justify,),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ، وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ،',
                    style: TextStyle(
                      //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                      textAlign: TextAlign.right,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ، وَعَلَى آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ، وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
                    style: TextStyle(
                      //wordSpacing: 2,

                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                      textAlign: TextAlign.right,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 270, top: 8),
                  child: Text(
                    'Transliteration',
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 40, top: 8),
                  child: Text(
                    '“Allaahumma salli ‘ala Muhammad wa ‘ala Aali Muhammad kama salayta ‘ala Ibrahim wa ‘ala aali Ibraaheem innaka hameedun majeed,.',
                    textAlign: TextAlign.justify,),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 40, top: 8),
                  child: Text(
                    'Allahumma baarik ‘ala Muhammad wa ‘ala Aali Muhammad kama baarakta ‘ala Ibrahim wa ála aali Ibraaheem innaka hameedun majeed.',
                    textAlign: TextAlign.justify,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    ' O Allah! Send Your Mercy on Muhammad and on the family of Muhammad, as You sent Your Mercy on Abraham and on the family of Abraham, for You are the Most Praise-worthy, the Most Glorious. \n '
                        'O Allah! Send Your Blessings on Muhammad and the family of Muhammad, as You sent your Blessings on Abraham and on the family of Abraham, for You are the Most Praise-worthy, the Most Glorious',
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
