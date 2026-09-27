


enum ReciterName {

 Abdulbasitmurattal('AbduBasit (arabic)', 'ar.abdulbasitmurattal'),
 AbdurrahmaanSudais('As-Sudais (arabic)','ar.abdurrahmaansudais'),

 alhusary('Husary (arabic)', 'ar.husary'),
 //
 alminshawi('Minshawi (arabic)','ar.minshawi',),
 abdulbasitmurattal('AbdulSamad arabic','ar.abdulsamad'),
 abdulsamad('Ahmed al-Ajamy (arabic)','ar.ahmedajamy',),
 alafasy(  'Alafasy (arabic)','ar.alafasy'),
 muhammadjibreel ('Muhammad Jibreel (arabic)', 'ar.muhammadjibreel'),
 walk('Ibrahim Walk (english)','en.walk'),
 hedayatfarfooladvand ('Fooladvand(Persian)','fa.hedayatfarfooladvand' ),
 khan('Shamshad Ali Khan (Urdu )"','ur.khan'),
 chines('Chinese','zh.chinese'),
 leclerc('Youssouf Leclerc ( French )','fr.leclerc'),
 kuliev( 'Elmir Kuliev (Russian)','ru.kuliev-audio');






 const ReciterName(this.label, this.text);
 final String label;
 final String text;
}