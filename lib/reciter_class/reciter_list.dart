

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
enum TranslatorName {

  AhmedAli('AhmedAli (English)', 'en.ahmedali'),
 Muhiuddin('Muhiuddin Khan (Bengali)','bn.bengali',),



   alikhan ('Alikhan Musayev (Azerbaijani)','az.musayev'),
  arekled (' Preklad I. Hrbek (Czech)','cs.hrbek'),
  abuRida ('Abu Rida Muhammad ibn Ahmad ibn Rassoul ( German) ','de.aburida'),
 bubenheimandElyas(  ' Bubenheim and Elyas (German)','de.bubenheim'),

 zaidan('Amir Zaidan (German)','de.zaidan'),
 Maldives('Maldives','dv.divehi' ),
 AhmedRazaKhan('Ahmed Raza Khan (English)','en.ahmedraza'),
 Arberry('Arberry (English)','en.arberry'),
 Asad('Muhammad Asad (English)','en.asad'),
 HilaliKhan ( 'Hilali & Khan (English)','en.hilali'),
 AbdulMajidDaryabadi ( 'Abdul Majid Daryabadi (English)','en.daryabadi'),
 pickthall ('Mohammed Marmaduke William Pickthall (English)', 'en.pickthall'),
 Hasan('Hasan al-Fatih Qaribullah and Ahmad Darwish (English)','en.qaribullah', ),
  sahih('Saheeh International (English)','en.sahih' ),
  yusuf ('Abdullah Yusuf Ali (English)','en.yusufali' ),
 sarwar( 'Muhammad Sarwar (English)', 'en.sarwar', ),
  ayati('AbdolMohammad Ayati(Persian)','fa.ayati' ),
  gummi('Abubakar Mahmoud Gumi(Hausa)','ha.gumi' ),
 Muhammad ('Muhammad Hamidullah(French)','fr.hamidullah' ),
 bahasa ('Bahasa Indonesia ( Indonesian )','id.indonesian' ),
suhel ('Suhel Farooq Khan and Saifur Rahman Nadwi ( Indi )','hi.hindi' ),
 Japanese ('Japanese','ja.japanese' ),
 hamza ('Hamza Roberto Piccardo (Italian)','it.piccardo' ),
 korean ('korean','ko.korean' ),
 kudish ('Burhan Muhammad-Amin (Kudish)','ku.asan' ),
 Abdul ('Cheriyamundam Abdul Hameed and Kunhi Mohammed Parappoor (Malayalam)','ml.abdulhameed' ),
 jozefa ('Józefa Bielawskiego (Polish)','pl.bielawskiego' ),
 samir ('Samir El-Hayek (Portuguese)','pt.elhayek' ),
 elmir ('Elmir Kuliev (Russia)','ru.kuliev' ),
 v ('V. Porokhova (Russia)','ru.porokhova' ),
 porokhova ('V. Porokhova (Russia)','ru.porokhova' ),
 Grigore ('George Grigore (Romania)','ro.grigore' ),
 taj('Taj Mehmood Amroti (Sindhi)','sd.amroti' ),
 mahmud('Mahmud Muhammad Abduh (Somali)','so.abduh' ),
 Ali('Ali Muhsin Al-Barwani (Swahili)','sw.barwani' ),
 thai('King Fahad Quran Complex(thai)','th.thai' ),


jalalayn( 'Tafsir Jalalayn', 'id.jalalayn' );




  const TranslatorName(this.label, this.text);
  final String label;
  final String text;
}
enum ReciterName {

 Abdulbasitmurattal('Abdul Basit', 'ar.abdulbasitmurattal'),
 AbdurrahmaanSudais('Abdurrahmaan As-Sudais','ar.abdurrahmaansudais'),

 alhusary('Husary (Mujawwad)', 'ar.husary'),
 //
 alminshawi('Minshawi','ar.minshawi',),
 abdulbasitmurattal('Abdul Samad"','ar.abdulsamad'),
 abdulsamad('Ahmed ibn Ali al-Ajamy','ar.ahmedajamy',),
 alafasy(  'Alafasy','ar.alafasy'),
 muhammadjibreel ('Muhammad Jibreel', 'ar.muhammadjibreel'),
 walk('Ibrahim Walk','en.walk'),
 hedayatfarfooladvand ('Fooladvand Hedayatfar (Persian)','fa.hedayatfarfooladvand' ),
 khan('Shamshad Ali Khan (Urdu )"','ur.khan'),
 chinese('Chinese','zh.chinese'),
 leclerc('Youssouf Leclerc ( French )','fr.leclerc'),
 kuliev( 'Elmir Kuliev (Russian)','ru.kuliev-audio');






 const ReciterName(this.label, this.text);
 final String label;
 final String text;
}