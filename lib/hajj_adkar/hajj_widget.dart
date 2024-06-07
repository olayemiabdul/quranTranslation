import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HajjActivity extends StatefulWidget {
  const HajjActivity({super.key});

  @override
  State<HajjActivity> createState() => _HajjActivityState();
}

class _HajjActivityState extends State<HajjActivity> {
  @override
  Widget build(BuildContext context) {
    String basmala = 'صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ';
    return SafeArea(
      child: Scaffold(
        body: PageView(
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 60,
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
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: Text('Hajj: The Journey of a Lifetime')),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(
                    ' فِيهِ ءَايَـٰتٌۢ بَيِّنَـٰتٌۭ مَّقَامُ إِبْرَٰهِيمَ ۖ وَمَن دَخَلَهُۥ كَانَ ءَامِنًۭا ۗ وَلِلَّهِ عَلَى ٱلنَّاسِ حِجُّ ٱلْبَيْتِ مَنِ ٱسْتَطَاعَ إِلَيْهِ سَبِيلًۭا ۚ وَمَن كَفَرَ فَإِنَّ ٱللَّهَ غَنِىٌّ عَنِ ٱلْعَـٰلَمِينَ ٩٧',
                    style: TextStyle(
                        wordSpacing: 2,
                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  )),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(
                          'In it are clear signs and the standing-place of Abraham. Whoever enters it should be safe. Pilgrimage to this House is an obligation by Allah upon whoever is able among the people.1 And whoever disbelieves, then surely Allah is not in need of ˹any of His˺ creation. Q3:97')),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                        'Ibn ‘Abbaas, may Allah be pleased with him, said: "The Messenger of Allah, ${basmala}, said: Whoever wants to go for Hajj, let him hasten to do it, because he may fall ill or some other problems may arise.Reported by Abu Daawood, 1732.'),
                  ),
                ),
                const Text('kind of hajj'),
                ListTile(
                    title: const Text('Hajj Tamattu'),
                    subtitle: Text(
                        'The best of the kinds is Tamattu, which the Prophet ${basmala} himself recommends. Tamattu is when a pilgrim enters ihrām for Umrah during the months of Hajj (which are Shawwal, Dhu’l-Qa’dah and the first ten days of Dhu’l-Hijjah) and performs Umrah and exits ihrām, then he enters ihrām again for Hajj from Makkah or its environs on the day of al-Tarwiyah in the same year as his Umrah. Hajj Tamattu is also the popular form of hajj')),
              ],
            ),
            ListView(
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
                        height: 55,
                        width: 55,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: const Text(
                          'Task 1',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text('Leaving your house')
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'Making Duaa for  family by saying:\nأَسْتَوْدِعُكُمُ اللهَ الَّذِيْ لَا تَضِيْعُ وَدَائِعُهُ? ',
                    style: TextStyle(
                        wordSpacing: 2,
                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    '\nI leave you in the care of Allah, who does not allow anything entrusted to Him to be lost (Refer to Ibn Mājah, 2825).\n',
                    style: TextStyle(
                        wordSpacing: 2,
                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'Then Step out by saying:\nبِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ لاَ حَوْلَ وَلاَ قُوَّةَ إِلاَّ بِاللَّهُِ ',
                    style: TextStyle(
                        wordSpacing: 2,
                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.normal),
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'Bismillah, tawakkaltu alallah, wa la hawlawa la quwwata illa billah. \nIn the Name of Allah, I have placed my trust in Allah.There is no power (in averting evil) or strength (in attaining good)except through Allah.” — (Refer to Sunan Abu Dawud, 4/325).\n',
                    style: TextStyle(
                        wordSpacing: 2,
                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                  ),
                ),
                const Text('While in the aircraft ready to takeoff, say'),
                const SizedBox(
                  height: 5,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    ' اللّٰهُ أَكْبَرُ ❁ اللّٰهُ أَكْبَرُ ❁ اللّٰهُ أَكْبَرُ ❁ سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ ❁ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ ❁ اَللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا الْبِرَّ وَالتَّقْوَى ❁ وَمِنَ الْعَمَلِ مَا تَرْضَى ❁ اَللَّهُمَّ هَوِّنْ عَلَيْنَا سَفَرَنَا هَذَا ❁ وَاطْوِ عَنَّا بُعْدَهُ ❁ اَللَّهُمَّ أَنْتَ الصَّاحِبُ فِي السَّفَرِ وَالْخَلِيفَةُ فِي الْأَهْلِ ❁ اَللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ وَعْثَاءِ السَّفَرِ وَكَآبَةِ الْمَنْظَرِ وَسُوْءِ الْمُنْقَلِبِ فِي الْمَالِ وَالْأَهْلِ ❁',
                    style: TextStyle(
                        wordSpacing: 2,
                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    'Subḥāna lladhī sakhkhara lanā hadhā wa mā kunnā lahu muqrinīn, wa innā ila rabbinā la munqalibūn. Allāhumma innā nas’aluka fī safarinā hadha l-birra wa t-taqwā, wa mina l-ʿamali mā tarḍa. Allāhumma hawwin ʿalaynā safaranā hādhā, wa-ṭwi ʿannā buʿdah. Allāhumma anta ṣ-ṣāḥibu fi s-safari wa l-khalīfatu fi l-ahl. Allāhumma innī aʿūdhu bikā min waʿthā’i s-safari wa ka’ābati l-manẓari wa sū’i l-munqalibi fi l-māli wa l-ahl',
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    'Allah is the Greatest. Allah is the Greatest. Allah is the Greatest. How perfect is the One who has given us control over this; we could not have done it by ourselves. Truly it is to our Lord that we are returning. O Allah, we ask You for piety, taqwā (Allahconsciousness) and deeds which You will be pleased with on this journey of ours. O Allah, make this journey easy for us and let uscover its distance swiftly. O Allah, You are our Companion on the journey and the One in whose care we leave our family. O Allah, I seek Your protection from the difficulties of the journey, from distressing scenes, and from an ill-fated outcome with my wealth and family. — (Refer to Sahih Muslim, 1342)',
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    'After making the duaa, ensure you continue to engage in dhikr throughout the flight. Do not talk except when necessary..',
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
                        height: 55,
                        width: 55,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: const Text(
                          'Task 2',
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
                    const Text('Reaching The City of Madina ')
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child:
                      Text(' MASJID AN-NABAWI: Enter the Mosque by reciting'),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child:
                      Image(image: AssetImage('assets/images/enterMasjid.png')),
                ),
                const Text(
                  'MASJID AN-NABAWI:Leave the mosque by reciting\n\nبِسْمِ اللّهِ وَالصَّلاَةُ وَالسَّلاَمُ عَلَى رَسُولِ اللّهِ، اَللَّهُـمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْـلِكَ، اَللَّهُـمَّ اعْصِمْنِـي مِنَ الشَّيْـطَانِ الرَّجِـيمِ.',
                  style: TextStyle(
                      //wordSpacing: 2,

                      fontFamily: 'Kitab-Bold',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.left,
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      'Visit the Prophet: You can visit the Prophet by making tasleem to the direction of his grave and that of his two companions (Abubakr & Umar) who were buried beside him'),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    'Give your Salam by saying:As-salaamu alayka ya Rasool Allah Peace be upon you, O Prophet of Allah or,As-salaamu alayka ayyu’hal Nabi-yuu;Wa rahma’tullaahi wa barakaa-tuhu.',
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'FRONT OF THE TOMB OF THE ABA BAKR and Umar (RA).\nGive your Salam by saying:As-salaamu alayka ya Aba Bakr;As-salaamu alayka ya khaleefat Rasool-illaah;Fi ummatihi, radiya Allaahu anka wa jazaa-ka ‘an ummati Muhammadin khayran',
                    textAlign: TextAlign.left,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      'Visit Jannatul Baqee’Cemetery: This is the cemetery where most of the companions of the Prophet were buried, along with several other Muslims:'),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Image(image: AssetImage('assets/images/baqi.png')),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      'Make sure that you observe all your five daily salat at the prophet$basmala mosque and perform as many countless nawāfil as possible. This is because one prayer in the prophet $basmala mosque is better than one thousand prayers elsewhere'),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      'Visit the Prophet: You can visit the Prophet by making tasleem to the direction of his grave and that of his two companions (Abubakr & Umar) who were buried beside him'),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 270, top: 8),
                  child: Text(
                    'Give your Salam by saying:As-salaamu alayka ya Rasool Allah.\nPeace be upon you, O Prophet of Allah or,\nAs-salaamu alayka ayyu’hal Nabi-yuu;\nWa rahma’tullaahi wa barakaa-tuhu.',
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
                          'Umrah Guide',
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
                    const Text('Umrah consists of four essential practices')
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '1. Changed into the Ihram garments before the Miqat, perform two rak’ahs of salah and make your niyyah as the Miqat approaches, thereafter reciting the Talbiyah frequently\n'
                    '2. Perform Tawaf al-Umrah of the Kaaba followed by two rak’ahs of salah, preferably near Maqam Ibrahim.\n'
                    '3. Do Sa’i of Safa and Marwa.\n'
                    '4. Shave (Halq) or shorten (Taqsir) your hair, allowing you to leave the state of Ihram and complete your Umrah.',
                  ),
                ),
                const ListTile(
                  title: Text('Physical Purity'),
                  subtitle: Text(
                      '•Before getting changed into the Ihram garments, take care of your personal hygiene by clipping your nails and removing the hair under your armpits and beneath the navel. You should then do ghusl, a highly emphasised sunnah for those intending to enter into a state of Ihram. If you can’t perform ghusl, doing wudhu will suffice. Men may apply attar/perfume to their heads/beards, ensuring not to get any on the Ihram garments. This should all be carried out at your place of residence before your journey'),
                ),
                const ListTile(
                  title: Text('Ihram Garments'),
                  subtitle: Text(
                      'Changed into your Ihram garments which for men consist of two, normally white, clean seamless pieces of cloth.\n'
                      'Ensure you put on your Ihram attire before crossing the designated Miqat\n'
                      'If you’re travelling to Makkah via Jeddah on an aeroplane, it is advisable to get changed into your Ihram at home or at the airport before departure or during a stopover if you have one.\n'
                      'If you’re going to Madinah before Makkah, you don’t need to enter into the state of Ihram and may wear regular clothing during your stay there. Before leaving for Makkah, you should don the Ihram at your hotel in Madinah or the designated Miqat for Madinah, Masjid Dhul Hulayfah'),
                ),
                const ListTile(
                  title: Text('Salah al-Ihram'),
                  subtitle: Text(
                      'It’s sunnah to perform two rak’ahs of salah before entering into the state of Ihram. This can be performed at home, after getting changed at the airport or in-flight before crossing the Miqat, providing there are prayer facilities on board.\n'
                      'If you’re in Madinah, you can perform the prayer in your hotel, in Masjid Nabawi, at the designated Miqat point or on the train. Observe the prayer with the intention of performing two rak’ahs nafl for Ihram.\n'
                      'It is recommended to recite Surah al-Kafirun (Surah 109) in the first rak’ah and Surah al-Ikhlas (Surah 112) in the second, although other surahs may be read. Don’t forget to make du’a after this salah.'),
                ),
                const ListTile(
                  title: Text('Niyyah'),
                  subtitle: Text(
                      'It’s sunnah to perform two rak’ahs of salah before entering into the state of Ihram. This can be performed at home, after getting changed at the airport or in-flight before crossing the Miqat, providing there are prayer facilities on board.\n'
                      'If you’re in Madinah, you can perform the prayer in your hotel, in Masjid Nabawi, at the designated Miqat point or on the train. Observe the prayer with the intention of performing two rak’ahs nafl for Ihram.\n'),
                ),
                const ListTile(
                  title: Text(
                      'There are three examples of intentions that may be uttered in Arabic'),
                  subtitle: Text('Labbayka Llāhumma ʿUmrah..\n'
                      'O Allah, here I am to perform Umrah.\n'),
                  trailing: Text(
                    'لَبَّيْكَ اَللَّهُمَّ عُمْرَةً ❁',
                    style: TextStyle(
                        wordSpacing: 2,
                        fontFamily: 'Kitab-Bold',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const ListTile(
                    title: Text(''),
                    subtitle: Text('Allāhumma innī urīdu l-ʿUmrah\n'
                        'O Allah, I intend to perform Umrah.\n'),
                    trailing: Text(
                      'اَللَّهُمَّ إِنِّي أُرِيدُ الْعُمْرَةَ ❁',
                      style: TextStyle(
                          wordSpacing: 2,
                          fontFamily: 'Kitab-Bold',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    )),
                const ListTile(
                    title: Text(''),
                    subtitle: Text(
                        'Allāhumma innī urīdu l-ʿUmrata fa yassirhā lī wa taqabbalhā minnī\n'
                        'O Allah, I intend to perform Umrah, so make it easy for me and accept it from me.\n'),
                    trailing: Text(
                      'اَللَّهُمَّ إِنِّي أُرِيدُ الْعُمْرَةَ فَيَسِّرْهَا لِي وَتَقَبَّلْهَا مِنِّي ❁',
                      style: TextStyle(
                          wordSpacing: 2,
                          fontFamily: 'Kitab-Bold',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    )),
                const ListTile(
                    title: Text('Talbiyah'),
                    subtitle: Text(
                        'Recite the Talbiyah to validate your intention and enter into the state of Ihram\n'
                        'The sunnah method of reciting the Talbiyah is to briefly pause at four places, indicated by the dashes.\n'
                        'Labbayka Llāhumma labbayk, labbayka lā sharīka laka labbayk, inna l-ḥamda wa n-ni’mata, laka wa l-mulk, lā sharīka lak\n'
                        'At Your service, Allah, at Your service. At Your service, You have no partner, at Your service. Truly all praise, favour and sovereignty is Yours. You have no partner\n'
                        'After uttering the Talbiyah, you will now be in the state of Ihram and be known as a Muhrim. Make sure you’re well aware of the prohibitions of Ihram and ensure you don’t fall foul of its rules.'),
                    trailing: Text(
                      'لَبَّيْكَ اَللَّهُمَّ لَبَّيْكَ – لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ – إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ – لَا شَرِيكَ لَكَ – ❁',
                      style: TextStyle(
                          wordSpacing: 2,
                          fontFamily: 'Kitab-Bold',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    )),
              ],
            ),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Container(
                  width: constraints.maxWidth * 0.8,
                  height: constraints.maxHeight * 0.8,
                  //color: Colors.white,
                  child: ListView(
                    children: [
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
                          const Text('Haram of Makkah')
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                            'The Haram of Makkah is a sacred area that extends several miles around Masjid al-Haram in all directions. In this area, it is forbidden to:\m'
                            'Cut or damage grass, trees or any other type of vegetation.\n'
                            'Harm or kill wild animals. This includes scaring away pigeons and other birds.\n'
                            'Carry weapons.\n'
                            'Fight or behave in a way that will violate the sanctity of this area.',
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.white)),
                      ),
                      const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(
                                'Entering Makkah\n'
                                'As you reach the limits of the Haram, constantly recite the Talbiyah, do dhikr and send Salawat upon the Prophet ﷺ. Recital of the following du’a is recommended upon entering the Haram:',
                                style: TextStyle(color: Colors.white)),
                            subtitle: Column(
                              children: [
                                Text(
                                    'Allāhumma hādhā ḥaramuka wa amnuka fa ḥarrimnī ʿala n-nār(i), wa aminnī min ʿadhābika yawma tabʿathu ʿibādak(a), wa jʿalnī min awliyā’ika wa ahli ṭāʿatik.\n'
                                    'O Allah, this is Your sanctuary and security, so make me unlawful to the hellfire, make me safe from Your punishment on the day You resurrect Your servants, and make me one of Your friends and one of the people who obey You.'),
                                Text(
                                    'اَللَّهُمَّ هَذَا حَرَمُكَ وَأَمْنُكَ فَحَرِّمْنِي عَلَى النَّارِ ❁ وَأَمِنِّي مِنْ عَذَابِكَ يَوْمَ تَبْعَثُ عِبَادَكَ ❁ وَاجْعَلْنِي مِنْ أَوْلِيَائِكَ وَأَهْلِ طَاعَتِكَ ❁',
                                    style: TextStyle(
                                        wordSpacing: 2,
                                        fontFamily: 'Kitab-Bold',
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),

                          )),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            'Entering Masjid al-Haram\n'
                            'It is sunnah to enter Masjid al-Haram via Bab al-Salam (the Gate of Peace). This may not be possible as the authorities have designated entrances to the mosque for pilgrims performing Umrah',
                            style: TextStyle(
                                wordSpacing: 2,
                                fontFamily: 'Kitab-Bold',
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            children: [
                              Text(
                                  'Bismi Llāh. Allāhumma ṣalli ʿalā Muḥammad. Allāhumma-ghfir lī wa-ftaḥ lī abwāba raḥmatik.\n'
                                  'In the name of Allah, send prayers upon Muhammad ﷺ. O Allah, forgive me and open for me the doors of Your Mercy.'),
                              Text(
                                'بِسْمِ اللهِ ❁ اَللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ ❁ اللّٰهُمَّ اغْفِرْ لِي وَافْتَحْ لِي أَبْوَابَ رَحْمَتِكَ ❁',
                                style: TextStyle(
                                    wordSpacing: 2,
                                    fontFamily: 'Kitab-Bold',
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),

                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: ListTile(

                          subtitle: Text(
                              'Bismi Llāh. Allāhumma ṣalli ʿalā Muḥammad. Allāhumma-ghfir lī wa-ftaḥ lī abwāba raḥmatik.\n'
                              'In the name of Allah, send prayers upon Muhammad ﷺ. O Allah, forgive me and open for me the doors of Your Mercy.'),
                          title:  Text(
                            'بِسْمِ اللهِ ❁ اَللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ ❁ اللّٰهُمَّ اغْفِرْ لِي وَافْتَحْ لِي أَبْوَابَ رَحْمَتِكَ ❁',
                            style: TextStyle(
                                wordSpacing: 2,
                                fontFamily: 'Kitab-Bold',
                                color: Colors.white,
                                fontSize: 20,

                                fontWeight: FontWeight.w500),


                          ),

                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: ListTile(
                          title:  Text(
                          'أَعُوذُ بِاللهِ الْعَظِيمِ ❁ وَبِوَجْهِهِ الْكَرِيمِ ❁ وَسُلْطَانِهِ الْقَدِيمِ ❁ مِنَ الشَّيْطَانِ الرَّجِيمِ ❁',
                          style: TextStyle(
                wordSpacing: 2,
                fontFamily: 'Kitab-Bold',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500),
                ),
                          subtitle: Text(
                              'Aʿūdhu bi-Llāhi l-aẓīm(i), wa bi-wajhihi l-karīm(i), wa sulṭānihi l-qadīm(i), mina sh-shayṭāni r-rajīm.\n'
                              'I seek protection in Allah the Tremendous, His Noble Countenance, and His pre-eternal Sovereign Might from Shaytan the rejected.'),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            'First Sight of the Kaaba\n'
                            'Upon seeing the Kaaba for the first time, raise your hands and make du’a with the utmost concentration and sincerity, as this is among those places where prayers are answered.\n'
                            'Remember to recite Salawat upon the Prophet ﷺ when making du’a. ',
                            style: TextStyle(
                                wordSpacing: 2,
                                fontFamily: 'Kitab-Bold',
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            children: [
                              Text(
                                  'Allāhu akbar. Allāhu akbar. Lā ilāha illa Llāh.\n'
                                  'Allah is the Greatest. Allah is the Greatest. There is no God except Allah.'),
                              Text(
                                'اللّٰهُ أَكْبَرُ ❁ اللّٰهُ أَكْبَرُ ❁ لَآ اِلَهَ اِلَّا اللّٰهُ ❁',
                                style: TextStyle(
                                    wordSpacing: 2,
                                    fontFamily: 'Kitab-Bold',
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),

                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            'اَللَّهُمَّ زِدْ هَذَا الْبَيْتَ تَشْرِيفاً وَتَعْظِيماً وَتَكْرِيماً وَمَهَابَةً ❁ وَزِدْ مَنْ شَرَّفَهُ وَكَرَّمَهُ مِمَّنْ حَجَّهُ أَوْ اعْتَمَرَهُ تَشْرِيفاً وَتَكْرِيماً وَتَعْظِيماً وَبِرّاً ❁',
                            style: TextStyle(
                                wordSpacing: 2,
                                fontFamily: 'Kitab-Bold',
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                              'Allāhumma zid hādha l-bayta tashrīfan wa taʿẓīman wa takrīman wa mahābah, wa zid man sharrafahu wa karramahu mimman ḥajjahu aw iʿtamarahu tashrīfan wa takrīman wa taʿẓīman wa birrā.\n'
                              'Allah, increase this House in honour, esteem, respect and reverence. And increase those who honour and respect it—of those who perform Hajj or Umrah—in honour, respect, esteem and piety.'),

                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            'اَللَّهُمَّ أَنْتَ السَّلاَمُ ❁ وَمِنْكَ السَّلَامُ ❁ حَيِّنَا رَبَّنَا بِالسَّلاَمِ ❁',
                            style: TextStyle(
                                wordSpacing: 2,
                                fontFamily: 'Kitab-Bold',
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                              'Allāhumma anta s-salām, wa minka s-salām, ḥayyinā rabbanā bi s-salām.\n'
                              'O Allah, You are Peace and from You is peace. Make us live, Lord, in peace.'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            LayoutBuilder(

              builder: (BuildContext context, BoxConstraints constraints) {
                return  Container(
                  width: constraints.maxWidth * 0.8,
                  height: constraints.maxHeight * 0.8,

                  child: ListView(
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
                          const Text('Tawaf al-Umrah')
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                            'Ensure you’re in a state of wudhu, and if you’re a male, uncover your right shoulder by passing the top sheet of your Ihram under your right armpit, allowing the garment to hang over your left shoulder (Idtiba)',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                      const ListTile(
                        title: Text('Intention'
                            'As with any other act of worship, make the niyyah to perform Tawaf solely for Allah.\n'
                            'You may make the following intention, which is in Arabic'),
                        subtitle: Column(
                          children: [
                            Text(
                                'Allāhumma innī urīdu l-ṭawwafa baytika l-ḥarāmi fa yassirhu lī wa taqabbalhu minnī.\n'
                                    'O Allah, I intend to perform Tawaf of your Sacred House, so make it easy for me and accept it from me.'),
                            Text(
                              'اَللَّهُمَّ إِنِّي أُرِيدُ طَوَافَ بَيْتِكَ الْحَرَامِ فَيَسِّرْهُ لِي وَتَقَبَّلْهُ مِنِّي',
                              style: TextStyle(
                                  wordSpacing: 2,
                                  fontFamily: 'Kitab-Bold',
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),

                      ),
                      ListTile(
                        title: Text('Hajar al-Aswad (Istilam)\n'
                            'The following supplication, a du’a of Ali I, may be recited when coming parallel to the Hajar al-Aswad in each circuit:\n'
                            'Bismi Llāhi wa Llāhu akbar. Allāhumma īmānan bika wa taṣdīqan bi kitābika wa wafāʿan bi ʿahdika wattibāʿan li sunnati nabiyyika Muḥammad $basmala\n'
                            '\n'
                            ''
                            'In the name of Allah, Allah is the Greatest. O Allah, out of faith in You, conviction in Your book, in fulfilment of Your covenant and in emulation of Your Prophet’s sunnah $basmala'),
                        subtitle: const Text(
                          'بِسْمِ اللّٰهِ وَاللّٰهُ أَكْبَرُ ❁ اَللَّهُمَّ إِيمَاناً بِكَ وَتَصْدِيقاً بِكِتَابِكَ ❁ وَوَفَاءً بِعَهْدِكَ ❁ وَاتِّبَاعاً لِسُنَّةِ نَبِيِّكَ مُحَمَّدْ ❁',
                          style: TextStyle(
                              wordSpacing: 2,
                              fontFamily: 'Kitab-Bold',
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Start the Tawaf\n'
                              'Turn to your right and start the first circuit of your Tawaf, ensuring the Kaaba is on your left. Proceed in an anti-clockwise direction and avoid walking through the Hijr Ismail. If you happen to walk through it, the circuit won’t count, and it will have to be repeated.',
                          //textAlign: TextAlign.left,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Raml\n'
                              'In the first three circuits, men should perform Raml, which is the practice of walking briskly, lifting the legs forcefully and sticking out the chest. However, if there is congestion, which is likely to be the case if you’re closer to the Kaaba, only perform this sunnah if you’re sure you won’t harm or inconvenience others. During peak times, you’re unlikely to be able to perform this action.',
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Dhikr & Du’a'
                              ' ',
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'During your Tawaf, you may recite prayers and supplications of your choice. du’as are accepted during Tawaf, so make the most of the occasion and remember Allah with sincerity and devotion.',


                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 40, top: 8),
                        child: Text(
                          'Rukn al-Yamani: '
                              'Upon reaching the Rukn al-Yamani (the Yemeni Corner), the corner preceding the Hajar al-Aswad, if you manage to get close enough, touch it with your right hand or both hands and say “Allāhu akbar (اللّٰهُ أَكْبَرُ)”.',
                          // style: TextStyle(
                          //   //wordSpacing: 2,
                          //
                          //     fontFamily: 'Kitab-Bold',
                          //     color: Colors.white,
                          //     fontSize: 25,
                          //     fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 10, top: 8),
                        child: Text(
                          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ ❁',
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
                        padding: EdgeInsets.only(right: 10, top: 8),
                        child: Text(
                          'Rabbanā ātinā fi d-dunyā ḥasanatan wa fi l-ākhirati ḥasanatan wa qinā ʿadhāba n-nār.\n'
                              '\n'
                              'O our Lord, grant us the good of this world, the good of the Hereafter, and save us from the punishment of the fire',

                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 10, top: 8),
                        child: Text(
                          'End of Circuit at the Hajar al-Aswad',

                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 10, top: 8),
                        child: Text(
                          'Returning to Hajar al-Aswad marks the completion of one circuit. Begin the second by doing Istilam of Hajar al-Aswad as previously described and saying “Allāhu akbar (اللّٰهُ أَكْبَرُ)”. You should say Allāhu akbar while doing Istilam in all subsequent circuits. You will be performing Istilam eight times in total during the Tawaf, one before the start of the Tawaf and one at the end of each of the seven circuits.',

                        ),
                      ),
                    ],
                  ),
                );
              },

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
                    const Text('Tawaf')
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      'The Tawaf should be completed in a continuous manner with no interruptions between circuits. However, if a congregational prayer is due to start, you must join the congregation and resume your Tawaf from the position that you stopped. The circuit need not be repeated. These rules also apply if you need to repeat your wudhu.',

                      style: TextStyle(
                          fontWeight: FontWeight.w900, color: Colors.white)),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      'Complete the Tawaf\n'
                          'Proceed in the same manner until you have completed seven circuits. Performing Istilam at the start of Tawaf and at the end is a highly emphasised sunnah, and performing Istilam on the other six occasions is desirable.\n'
                          'Upon finishing the Tawaf, perform two rak’ahs of salah, preferably in a position where Maqam Ibrahim is between you and the Kaaba.\n'
                          'While moving to the place where you intend to perform the two rak’ahs, it is recommended to audibly recite the following:',
                      style: TextStyle(color: Colors.white)),
                ),
                const Center(
                  child: Text(
                    'وَاتَّخِذُوا مِنْ مَقَامِ إِبْرَاهِيمَ مُصَلًّى ❁\n'
                        'Wattakhidhū min maqāmi Ibrāhīma muṣalla.\n'
                        'And take the Maqam Ibrahim as a place of salah',
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
                    'It is sunnah to recite Surah al-Kafirun (Surah 109) in the first rak’ah and Surah al-Ikhlas (Surah 112) in the second, after Surah al-Fatiha.\n'
                        'Make sure you make plenty of du’a after completing the prayer',

                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Zamzam',
                    style: TextStyle(fontWeight: FontWeight.w900),

                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 40, top: 8),
                  child: Text(
                    'The Prophet ﷺ said: “The water of Zamzam is for whatever purpose it is drunk for.” Before drinking the Zamzam water, make an intention that its consumption will be a means of fulfilling your wishes, whether that is good health, success in this world, or protection from the tribulations of the grave.\n'
                        'You may recite the following du’a after drinking the water:',

                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    'اللّٰهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا ❁ وَرِزْقًا وَاسِعًا ❁ وَعَمَلًا مُتَقَبَّلًا ❁ وَشِفَاءً مِنْ كُلِّ دَاءٍ ❁',
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
                    'Allāhumma innī as’aluka ʿilman nāfiʿan, wa rizqan wasiʿan, wa ʿamalan mutaqabbalan, wa shifā’an min kulli dā’.\n'
                        'O Allah, I ask You for knowledge that is beneficial, provision that is abundant, accepted deeds, and a cure for every illness.\n'
                        'You may also make any other supplication of your choosing as it’s another station where du’as are accepted',

                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    'Sa’i\n'
                        'It is a sunnah to perform Sa’i immediately after Tawaf, which is one of the integral rites of Hajj and Umrah and refers to the ritual of walking back and forth seven times between the two small hills of Safa and Marwa, located adjacent to the Kaaba in Masjid al-Haram.',


                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    'Istilam\n'
                        'he act of kissing Hajar al-Aswad or gesturing towards it at the beginning and at the end of each circuit of the Kaaba during the rite of Tawaf.\n'
                        'Place your palms on Hajar al-Aswad and put your face between your two hands and say',

                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    ' بِسْمِ اللّٰهِ وَاللّٰهُ أَكْبَرُ   ❁\n'
                        'Bismi Llāhi wa Llāhu akbar.\n'
                        'Istilam from Afar\n'
                        'Face al-Hajar al-Aswad and raise your hands up to your earlobes (as you would do when starting salah) and facing it'

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
                    const Text('Safa')
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      'Proceed to the hill of Safa, which is located inside Masjid al-Haram in line with the Hajar al-Aswad.\n'
                          'As you’re approaching Safa, it is sunnah to recite the following:',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, color: Colors.white)),
                ),

                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'ِِإِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ الله ❁\n'
                        'Inna Safā wa l-Marwata min shaʿa’iri Llāh.\n'
                        'Indeed, Safa and Marwa are from the Signs of Allah.',
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
                    'أَبْدَأُ بِمَا بَدَأَ اللهُ بِهِ ❁',
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
                    'Abda’u bimā badā’ Llāhu bih.\n'
                        'I begin with that which Allah has begun with.\n'
                        'Upon reaching the hill of Safa, face the direction of the Kaaba and raise your hands in supplication',

                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'اللّٰهُ أَكْبَرُ ❁ اللّٰهُ أَكْبَرُ ❁ اللّٰهُ أَكْبَرُ ❁ وَلِلّٰهِ الْحَمْدُ ❁\n'
                        'لَآ إِلٰهَ إِلَّا اللّٰهُ وَحْدَهُ ❁ اَنْجَزَ وَعْدَهُ وَنَصَرَ عَبْدَهُ وَهَزَمَ اَلْأَحْزَابَ وَحْدَهُ ❁\n'
                        '\nلَآ إِلٰهَ إِلَّا اللّٰهُ وَحْدَهُ لاَ شَرِيكَ لَهُ ❁ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ ❁ يُحْيِي وَيُمِيتُ ❁ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ ❁',
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
                    'Allāhu akbar, Allāhu akbar, Allāhu akbar, wa li Llāhi l-ḥamd.\n'
                        'La ilāha illa Llāhu waḥdah, anjaza waʿdahu wa naṣara ʿabdahu wa hazama l-aḥzāba waḥdah.\n'
                        'La ilāha illa Llāhu waḥdahu la sharīka lah, lahu l-mulku wa lahu l-ḥamd, yuḥīī wa yumīt, wa huwa ʿalā kulli shay’in qadīr.',

                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 8),
                  child: Text(
                    'Marwa\n'
                        'it is sunnah for men to run at a medium pace while women should continue normally between Safa and Marwa,\n'
                        'Make Du’a at Marwa\n'
                        'Upon reaching the hill of Marwa, face the direction of the Kaaba, raise your hands in supplication and repeat the same supplications you recited at Safa.\n'
                        'This completes one lap of Sa’i. Returning back to Safa is considered a second lap.\n'
                        'Repeat this procedure until you have completed seven laps, at which point you should be at the hill of Marwa.\n'
                        'It is recommended to make a final du’a here and also to perform two rak’ahs of nafl salah in Masjid al-Haram following Sa’i.\n'
                        'As you leave Masjid al-Haram, step out with your left foot and recite the following du’a, as was the sunnah of the Prophet ﷺ when leaving the mosque:',

                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'بِسْمِ اللهِ وَالصَّلَاةُ وَالسَّلَّامُ عَلَى رَسُولِ اللهِ ❁ اللّٰهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ ❁',
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
                  padding: EdgeInsets.all(8.0),
                  child: Text('Bismi Llāhi wa ṣ-ṣalātu wa s-salāmu ʿalā rasūli Llāh. Allāhumma innī as’aluka min faḍlik.\n'
                      'In the name of Allah, and peace and blessings be upon the Messenger of Allah. O Allah, I ask of you from Your bounty.\n'
                      'After Sa’i, you must have your hair shaved (Halq) or trimmed by at least an inch (Taqsir) in order to leave the state of Ihram and complete your Umrah. It is more virtuous for a man to have his head shaved completely.'),
                )
              ],
            ),

          ],
        ),
      ),
    );
  }
}
