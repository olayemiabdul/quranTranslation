import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:pray_times/pray_times.dart';
import 'package:quran_complete_ui/constant.dart';


import '../azan/notification_class.dart';
import '../quran_ayah/Surah_List.dart';

import '../quran_translation_package/quran_translationList.dart';


class WelcomeScreenPage extends StatefulWidget {
   const WelcomeScreenPage({super.key});

  @override
  State<WelcomeScreenPage> createState() => _WelcomeScreenPageState();
}

class _WelcomeScreenPageState extends State<WelcomeScreenPage> {
  var today = HijriCalendar.now();// for hijri date
  DateTime selectedDate = DateTime.now(); //flutter date
  //CurrentLocations currentLocations=CurrentLocations(12.023844, 8.5474425);




  //Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);


  // void getCurrentLocation() async {
  // Position currentPosition = await currentLocations.determinePosition();
  // setState(() {
  // currentLocations.position =currentPosition;
  // });
  // }
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   //getCurrentLocation(); when implemting geolocation
  //   currentLocations.getCurrentLocation();
  // }
  @override
  Widget build(BuildContext context) {
    PrayerTimes prayers = PrayerTimes();
    prayers.setTimeFormat(prayers.Time24);
    prayers.setCalcMethod(prayers.MWL);
    prayers.setAsrJuristic(prayers.Shafii);
    prayers.setAdjustHighLats(prayers.AngleBased);
    var offsets = [0, 0, 0, 0, 0, 0, 0];
    prayers.tune(offsets);




    return  Scaffold(
      appBar: AppBar(title: Text('gtt'),
      backgroundColor: gridContainerColor,),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/mosque4.jpg'),fit: BoxFit.fill),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50)),
          color: Color(0xff4E51BF),
        ),
        child:  Column(
          children:  [
            const SizedBox(
              height: 70,
            ),
            Center(
              child: Text(
                "${selectedDate.hour} : ${selectedDate.minute} ",
                style: GoogleFonts.allura(
                  textStyle: TextStyle(color: Colors.blue.shade100, fontSize: 60,fontWeight: FontWeight.bold),
                ),
              ),

            ),
            Center(child: Text(today.fullDate().toString(),
              style: GoogleFonts.roboto(
                textStyle: const TextStyle(color: Colors.amber, fontSize: 20,fontWeight: FontWeight.bold),
              ),),),

            Padding(
              padding: const EdgeInsets.only(left: 140),
              child: Row(
                children: [
                  Text(DateFormat.LLLL().format(DateTime.now()), style: GoogleFonts.roboto(
                    textStyle: const TextStyle(color: Colors.amber, fontSize: 20,fontWeight: FontWeight.bold),
                  ),),
                  Text(
                    " ${selectedDate.year}   ${selectedDate.day}",
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(color: Colors.amber, fontSize: 20,fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
         const SizedBox(height: 50,),
         Padding(
           padding: const EdgeInsets.only(left: 38),
           child: Row(
             children: [
               InkWell(
                 onTap: (){},
                 child: Container(
                   height: 110,
                   width: 100,
                   decoration: const BoxDecoration(
                     color: gridContainerColor,
                     borderRadius: BorderRadius.only(
                         topLeft: Radius.circular(10),
                         topRight: Radius.circular(10),
                         bottomLeft: Radius.circular(10),
                         bottomRight: Radius.circular(10)),
                   ),
                   child: const Padding(
                     padding: EdgeInsets.only(bottom: 8,top: 16,left: 8,right: 8),
                     child: Column(

                       children: [
                         Image(image: AssetImage('assets/images/audio.png'),width: 60,height: 60,),
                         Text('Audio-Quran')
                       ],
                     ),
                   ),
                 ),
               ) ,
               const SizedBox(width: 5,),
               InkWell(

                 child: Container(
                   height: 110,
                   width: 100,
                   decoration: const BoxDecoration(
                     color: gridContainerColor,
                     borderRadius: BorderRadius.only(
                         topLeft: Radius.circular(10),
                         topRight: Radius.circular(10),
                         bottomLeft: Radius.circular(10),
                         bottomRight: Radius.circular(10)),
                   ),
                   child: const Padding(
                     padding: EdgeInsets.only(bottom: 8,top: 16,left: 8,right: 8),
                     child: Column(

                       children: [
                         Image(image: AssetImage('assets/images/quran.png'),),
                         Text('Translation')
                       ],
                     ),
                   ),
                 ),
                 onTap: (){
                   Navigator.push(context, MaterialPageRoute(builder:(context)=>const QuranTranslationListPage()));
                 },
               ) ,
               const SizedBox(width: 5,),
               InkWell(
                 onTap: (){
                   Navigator.push(context,MaterialPageRoute(builder:(context)=>const SurahListPage (),),);
                 },
                 child: Container(
                   height: 110,
                   width: 100,
                   decoration: const BoxDecoration(
                     color: gridContainerColor,
                     borderRadius: BorderRadius.only(
                         topLeft: Radius.circular(10),
                         topRight: Radius.circular(10),
                         bottomLeft: Radius.circular(10),
                         bottomRight: Radius.circular(10)),
                   ),
                   child: const Padding(
                     padding: EdgeInsets.only(bottom: 8,top: 16,left: 8,right: 8),
                     child: Column(

                       children: [
                         Image(image: AssetImage('assets/images/quran1.png'),width: 60,height: 60,),
                         Text('Al-Quran')
                       ],
                     ),
                   ),
                 ),
               ) ,
             ],
           ),
         ),
            const SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.only(left: 38),
              child: Row(
                children: [
                  InkWell(
                    onTap: (){},
                    child: Container(
                      height: 110,
                      width: 100,
                      decoration: const BoxDecoration(
                        color: gridContainerColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 8,top: 16,left: 8,right: 8),
                        child: Column(

                          children: [
                            Image(image: AssetImage('assets/images/quran4.png'),width: 50,height: 50,),
                            Text('Urdu-Quran')
                          ],
                        ),
                      ),
                    ),
                  ) ,
                  const SizedBox(width: 5,),
                  InkWell(
                    onTap: (){},
                    child: Container(
                      height: 110,
                      width: 100,
                      decoration: const BoxDecoration(
                        color: gridContainerColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 8,top: 8,left: 10,right: 8),
                        child: Column(

                          children: [
                            Image(image: AssetImage('assets/images/quran3.png'), width: 50,height: 50,),
                            Text('Quran by Pages')
                          ],
                        ),
                      ),
                    ),
                  ) ,
                  const SizedBox(width: 5,),
                  InkWell(
                    onTap: (){},
                    child: Container(
                      height: 110,
                      width: 100,
                      decoration: const BoxDecoration(
                        color: gridContainerColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 8,top: 8,left: 8,right: 8),
                        child: Column(

                          children: [
                            Image(image: AssetImage('assets/images/quran2.png'),width: 50,height: 50,),
                            Text('English & Arabic Text')
                          ],
                        ),
                      ),
                    ),
                  ) ,
                ],
              ),
            ),
            const SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.only(left: 38),
              child: Row(
                children: [
                  InkWell(
                    onTap: (){},
                    child: Container(
                      height: 110,
                      width: 100,
                      decoration: const BoxDecoration(
                        color: gridContainerColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 8,top: 16,left: 8,right: 8),
                        child: Column(

                          children: [
                            Image(image: AssetImage('assets/images/tasbir.png'),height: 60,width: 60,),
                            Text('Adzkar')
                          ],
                        ),
                      ),
                    ),
                  ) ,
                  const SizedBox(width: 5,),
                  InkWell(
                    onTap: (){},
                    child: Container(
                      height: 110,
                      width: 100,
                      decoration: const BoxDecoration(
                        color: gridContainerColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 8,top: 16,left: 8,right: 8),
                        child: Column(

                          children: [
                            Image(image: AssetImage('assets/images/quran.png'),),
                            Text('Al-Quran')
                          ],
                        ),
                      ),
                    ),
                  ) ,
                  const SizedBox(width: 5,),
                  InkWell(
                    onTap: (){},
                    child: Container(
                      height: 110,
                      width: 100,
                      decoration: const BoxDecoration(
                        color: gridContainerColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 8,top: 16,left: 8,right: 8),
                        child: Column(

                          children: [
                            Image(image: AssetImage('assets/images/kaaba.png'),height: 50,width: 50,),
                            Text('Hajj Guide')
                          ],
                        ),
                      ),
                    ),
                  ) ,
                ],
              ),
            ),



          ],
        )
    ),

    );
  }

}



class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path =Path();
    path.lineTo(0, size.height*0.75
    );
    path.quadraticBezierTo(
        size.width*0.25, size.height*0.5, size.width*0.5, size.height*0.75);

    path.quadraticBezierTo(size.width*0.75, size.height*1.1, size.width, size.height*0.75);
    path.lineTo(size.width, 0);
    //
    // final path_1 = Path();
    // path_1.moveTo(size.width*0.0862750,size.height*0.6157429);
    // path_1.quadraticBezierTo(size.width*0.0852083,size.height*0.7578000,size.width*0.4993250,size.height*0.7975000);
    // path_1.lineTo(size.width*0.4991667,size.height*0.6128571);
    // path_1.quadraticBezierTo(size.width*0.0850917,size.height*0.6193143,size.width*0.0862750,size.height*0.6157429);
    // path_1.close();
    // return path_1;
    return path;

  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return false;
    // TODO: implement shouldReclip
    throw UnimplementedError();
  }
}