/// Audio editions on api.alquran.cloud that publish one file per ayah on
/// cdn.islamic.network. `text` is the edition identifier.
///
/// Keep `reciterLabels` in quran_audio/quran_audio_service.dart and the
/// bitrate table in quran_audio/audio_catalog.dart in step with this list.
enum ReciterName {
  alafasy('Mishary Alafasy', 'ar.alafasy'),
  abdulbasitmurattal('Abdul Basit (Murattal)', 'ar.abdulbasitmurattal'),
  abdurrahmaansudais('Abdurrahmaan As-Sudais', 'ar.abdurrahmaansudais'),
  abdullahbasfar('Abdullah Basfar', 'ar.abdullahbasfar'),
  abdulsamad('Abdul Samad', 'ar.abdulsamad'),
  shaatree('Abu Bakr Ash-Shaatree', 'ar.shaatree'),
  ahmedajamy('Ahmed ibn Ali al-Ajamy', 'ar.ahmedajamy'),
  hanirifai('Hani Rifai', 'ar.hanirifai'),
  husary('Husary', 'ar.husary'),
  husarymujawwad('Husary (Mujawwad)', 'ar.husarymujawwad'),
  hudhaify('Hudhaify', 'ar.hudhaify'),
  ibrahimakhbar('Ibrahim Akhdar', 'ar.ibrahimakhbar'),
  mahermuaiqly('Maher Al Muaiqly', 'ar.mahermuaiqly'),
  minshawi('Minshawi', 'ar.minshawi'),
  minshawimujawwad('Minshawy (Mujawwad)', 'ar.minshawimujawwad'),
  muhammadayyoub('Muhammad Ayyoub', 'ar.muhammadayyoub'),
  muhammadjibreel('Muhammad Jibreel', 'ar.muhammadjibreel'),
  saoodshuraym('Saood Ash-Shuraym', 'ar.saoodshuraym'),
  parhizgar('Parhizgar', 'ar.parhizgar'),
  aymanswoaid('Ayman Sowaid', 'ar.aymanswoaid'),

  // Recited translations. (ur.khan was dropped: the CDN has no files for it.)
  walk('Ibrahim Walk (English)', 'en.walk'),
  hedayatfarfooladvand('Fooladvand (Persian)', 'fa.hedayatfarfooladvand'),
  chinese('Chinese', 'zh.chinese'),
  leclerc('Youssouf Leclerc (French)', 'fr.leclerc'),
  kuliev('Elmir Kuliev (Russian)', 'ru.kuliev-audio');

  const ReciterName(this.label, this.text);
  final String label;
  final String text;
}
