import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../location_logic/location_class.dart';
import '../model/notification_model.dart';
import '../model/prayer_time_model.dart';



class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({super.key});

  @override
  State<PrayerTimePage> createState() => _PrayerTimePageState();
}

class _PrayerTimePageState extends State<PrayerTimePage> {

  DateTime selectedDate = DateTime.now();
  //List<Abdul> prayerList = [];
  List<PrayerDailyTimes> prayerListNew = [];
  //CurrentLocations currentLocations=CurrentLocations();
  var overlayController=OverlayPortalController();
  final locationController=TextEditingController();
  String? _currentAddress;
  Position? _currentPosition;
  String? currentCity;
  String? currentCountry;

  String date = DateTime.now().toIso8601String().split('T')[0];






  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
        _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        // to get location names
        _currentAddress =
        ' ${place.subLocality??''},${place.subAdministrativeArea??''}, ${place.postalCode??''}';
        currentCity =
        ' ${place.subAdministrativeArea},}';
        currentCountry =
        ' ${place.country},}';
        print(currentCity);
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }
  Future<PrayerDailyTimes> getPrayerTimes() async {

    String date = DateTime.now().toIso8601String().split('T')[0]; // Today's date
    int month=selectedDate.month;
    int year=selectedDate.year;



    final response = await http.get(
        Uri.parse('https://api.aladhan.com/v1/timingsByCity/$date?city=$currentCity&country=$currentCountry&method=8')
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PrayerDailyTimes.fromJson(data['data']['timings']);
    } else {
      throw Exception('Failed to load prayer times');

    }
  }











  @override
  void initState() {
    // TODO: implement initState

    getPrayerTimes();
    getCurrentPosition();





  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(

      appBar: AppBar(
        title: const Row(
          children: [
            BackButton(),
            Text('Daily Prayer Time'),
          ],
        ),
        automaticallyImplyLeading: false,

      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
         Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.place, color: Colors.green,size: 22,
                ),
              ),
              const SizedBox(width: 4,),
              Text(' ${_currentAddress  ?? ""}', style: const TextStyle(color: Colors.white),),

              // Padding(
              //   padding: const EdgeInsets.only(left: 10),
              //   child: ElevatedButton(
              //     onPressed: overlayController.toggle,
              //    child: OverlayPortal(
              //      controller: overlayController, overlayChildBuilder: (BuildContext context) {
              //        return Positioned(
              //          top: 250,
              //          right: 40,
              //          child: Container
              //            (
              //            decoration: const BoxDecoration(
              //              color: Colors.cyan,
              //              borderRadius: BorderRadius.all(Radius.circular(10))
              //            ),
              //            //color: Colors.green,
              //            height: 300,
              //            width: 300,
              //            child:  Column(
              //              children: [
              //                // const SizedBox(height: 140,),
              //                const Padding(
              //                  padding: EdgeInsets.all(8.0),
              //                  child: Text('Location is needed to get Prayer Times according to the current locality',
              //                  style: TextStyle(color: Colors.white),),
              //                ),
              //                TextField(
              //
              //                  onSubmitted: (value){
              //                    Navigator.pop(context);
              //                  },
              //                  textInputAction: TextInputAction.done,
              //                  keyboardAppearance: Brightness.dark,
              //                  keyboardType: TextInputType.emailAddress,
              //                  controller: locationController,
              //                  obscureText: false,
              //                  decoration: InputDecoration(
              //                    label: const Text('Location'),
              //                      hintText: "Enter Location Manually",
              //                      border: OutlineInputBorder(
              //                        borderRadius: BorderRadius.circular(15),
              //                        borderSide: const BorderSide(
              //                          color: Color(0xFF000000),
              //                          strokeAlign: BorderSide.strokeAlignInside,
              //                        ),
              //                      ),
              //                      fillColor: Colors.purple.withOpacity(0.2),
              //                      filled: true,
              //                      suffixIcon: const Icon(
              //                        Icons.location_city,
              //                        color: Colors.purple,
              //                      )),
              //
              //                ),
              //              ],
              //            ),
              //          ),
              //        );
              //    },
              //      child: const Text('Enter city'),
              //    ),
              //   ),
              // ),


            ],
          ),

    // Center(
    // child: ElevatedButton(
    // onPressed: () async {
    // NotificationSoundType soundType = await getSoundPreference();
    // fetchAndSchedulePrayerTimes(soundType);
    // },
    // child: Text('Schedule Azan Notifications'),
    // ),
    // ),
    




          Expanded(

            child: FutureBuilder<PrayerDailyTimes>(
                future:getPrayerTimes(),
                builder: ( context,snapshot){

                  if(snapshot.hasData){
                    return ListView.builder(
                        itemCount: 1,
                        itemBuilder: (context, index){
                          final prayerTimes=snapshot.data;

                          return
                            Card(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    ListTile(
                                    title: const Text('Fajr', style: TextStyle(
                                        wordSpacing: 2,

                                        fontFamily: 'Kitab-Bold',
                                        color: Colors.amberAccent,
                                        fontSize: 20, fontWeight: FontWeight.w500),),
                                     subtitle: Text(prayerTimes!.fajr, style: const TextStyle(
                                         wordSpacing: 2,

                                         fontFamily: 'Kitab-Bold',
                                         color: Colors.amberAccent,
                                         fontSize: 20, fontWeight: FontWeight.w500),),
                                      trailing:  IconButton(onPressed: (){}, icon: const Icon(Icons.notification_add)),

                                      ),
                                    const SizedBox(height: 7,),
                                    ListTile(
                                    title: const Text('Sunrise', style: TextStyle(
                                        wordSpacing: 2,

                                        fontFamily: 'Kitab-Bold',
                                        color: Colors.amberAccent,
                                        fontSize: 20, fontWeight: FontWeight.w500),),
                                     subtitle: Text(prayerTimes!.sunrise, style: const TextStyle(
                                         wordSpacing: 2,

                                         fontFamily: 'Kitab-Bold',
                                         color: Colors.amberAccent,
                                         fontSize: 20, fontWeight: FontWeight.w500),),
                                      trailing:  IconButton(onPressed: (){}, icon: const Icon(Icons.notification_add)),

                                      ),
                                    ListTile(
                                    title: const Text('Dhuhr', style: TextStyle(
                                        wordSpacing: 2,

                                        fontFamily: 'Kitab-Bold',
                                        color: Colors.amberAccent,
                                        fontSize: 20, fontWeight: FontWeight.w500),),
                                     subtitle: Text(prayerTimes!.dhuhr, style: const TextStyle(
                                         wordSpacing: 2,

                                         fontFamily: 'Kitab-Bold',
                                         color: Colors.amberAccent,
                                         fontSize: 20, fontWeight: FontWeight.w500),),
                                      trailing:  IconButton(onPressed: (){}, icon: const Icon(Icons.notification_add)),

                                      ),
                                    ListTile(
                                    title: const Text('Asr', style: TextStyle(
                                        wordSpacing: 2,

                                        fontFamily: 'Kitab-Bold',
                                        color: Colors.amberAccent,
                                        fontSize: 20, fontWeight: FontWeight.w500),),
                                     subtitle: Text(prayerTimes!.asr, style: const TextStyle(
                                         wordSpacing: 2,

                                         fontFamily: 'Kitab-Bold',
                                         color: Colors.amberAccent,
                                         fontSize: 20, fontWeight: FontWeight.w500),),
                                      trailing:  IconButton(onPressed: (){}, icon: const Icon(Icons.notification_add)),

                                      ),
                                    ListTile(
                                    title: const Text('Maghrib', style: TextStyle(
                                        wordSpacing: 2,

                                        fontFamily: 'Kitab-Bold',
                                        color: Colors.amberAccent,
                                        fontSize: 20, fontWeight: FontWeight.w500),),
                                     subtitle: Text(prayerTimes!.maghrib, style: const TextStyle(
                                         wordSpacing: 2,

                                         fontFamily: 'Kitab-Bold',
                                         color: Colors.amberAccent,
                                         fontSize: 20, fontWeight: FontWeight.w500),),
                                      trailing:  IconButton(onPressed:(){}, icon: const Icon(Icons.notification_add)),

                                      ),
                                    ListTile(
                                    title: const Text('Sunset', style: TextStyle(
                                        wordSpacing: 2,

                                        fontFamily: 'Kitab-Bold',
                                        color: Colors.amberAccent,
                                        fontSize: 20, fontWeight: FontWeight.w500),),
                                     subtitle: Text(prayerTimes!.sunset, style: const TextStyle(
                                         wordSpacing: 2,

                                         fontFamily: 'Kitab-Bold',
                                         color: Colors.amberAccent,
                                         fontSize: 20, fontWeight: FontWeight.w500),),
                                      trailing:  IconButton(onPressed: (){}, icon: const Icon(Icons.notification_add)),

                                      ),
                                    ListTile(
                                    title: const Text('Isha', style: TextStyle(
                                        wordSpacing: 2,

                                        fontFamily: 'Kitab-Bold',
                                        color: Colors.amberAccent,
                                        fontSize: 20, fontWeight: FontWeight.w500),),
                                     subtitle: Text(prayerTimes!.isha, style: const TextStyle(
                                         wordSpacing: 2,

                                         fontFamily: 'Kitab-Bold',
                                         color: Colors.amberAccent,
                                         fontSize: 20, fontWeight: FontWeight.w500),),
                                      trailing:  IconButton(onPressed: (){}, icon: const Icon(Icons.notification_add)),

                                      ),
                                    ListTile(
                                    title: const Text('Midnight', style: TextStyle(
                                        wordSpacing: 2,

                                        fontFamily: 'Kitab-Bold',
                                        color: Colors.amberAccent,
                                        fontSize: 20, fontWeight: FontWeight.w500),),
                                     subtitle: Text(prayerTimes!.midnight, style: const TextStyle(
                                         wordSpacing: 2,

                                         fontFamily: 'Kitab-Bold',
                                         color: Colors.amberAccent,
                                         fontSize: 20, fontWeight: FontWeight.w500),),
                                      trailing:  IconButton(onPressed: (){}, icon: const Icon(Icons.notification_add)),

                                      ),





                                ],
                              ),
                            );

                        });
                  } else{
                    return const Text('Check your Connection');
                  }


                }
                ),
          ),
        ],
      ),
    );
  }
}






