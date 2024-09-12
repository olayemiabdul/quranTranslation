import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:quran_complete_ui/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';


import '../dropdown_class/calculation_methods.dart';
import '../model/prayer_time_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();



class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({super.key});

  @override
  State<PrayerTimePage> createState() => _PrayerTimePageState();
}

class _PrayerTimePageState extends State<PrayerTimePage> {

  DateTime selectedDate = DateTime.now();
  bool exactAlarmEnabled = false;
  //List<Abdul> prayerList = [];
  List<PrayerDailyTimes> prayerListNew = [];
  //CurrentLocations currentLocations=CurrentLocations();
  // var overlayController=OverlayPortalController();
  // final locationController=TextEditingController();
  String? currentAddress;
  Position? currentPosition;
  String? currentCity;
  String? currentCountry;
  bool soundEnabled = true;
  String date = DateTime.now().toIso8601String().split('T')[0];
  String notificationMode = 'Beep'; // Default to 'Beep' to choose azan notification
  int selectedCalculationMethod = 3; // Default to Muslim World League









  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location services are disabled. Please enable the services')));
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

    await handleNotificationPermission();
    return true;
  }

  Future<void> handleNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;

    if (!status.isGranted) {
      status = await Permission.notification.request();
    }

    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification permissions are granted')));
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification permissions are denied')));
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Notification permissions are permanently denied. Please enable them in settings.')));
      await openAppSettings();
    }
  }

  Future<void> getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => currentPosition = position);
      getAddressFromLatLng(currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
        position.latitude, position.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        currentAddress = '${place.subLocality ?? ''}, ${place.subAdministrativeArea ?? ''}, ${place.postalCode ?? ''}';
        currentCity = place.locality;
        currentCountry = place.country;
        print(currentCity);
        getPrayerTimes();  // Fetch prayer times once city and country are obtained
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }





  Future<PrayerDailyTimes> getPrayerTimes() async {

    String date = DateTime.now().toIso8601String().split('T')[0]; // Today's date
    // int month=selectedDate.month;
    // int year=selectedDate.year;



    final response = await http.get(
        Uri.parse('https://api.aladhan.com/v1/timingsByCity/$date?city=$currentCity&country=$currentCountry&method=$selectedCalculationMethod')
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(currentCity);
      return PrayerDailyTimes.fromJson(data['data']['timings']);

    } else {
      throw Exception('Failed to load prayer times');

    }

  }






  static Future<void> initialized (FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async{
    var andriodInitialize=const AndroidInitializationSettings('mipmap/ic_launcher');
    //var iOSInitialize=new IOSInitializationSettings();
    var initializationSettings=InitializationSettings(
      android: andriodInitialize,

    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  }



  Future<void> scheduleAzanNotification(
      String prayerName,
      DateTime prayerTime,
      {required bool sound, required bool vibrate}) async {

    final int notificationId = prayerName.hashCode;

    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'azan_channel_id',
        'Azan Notifications',
        channelDescription: 'Notification channel for Azan timings',
        importance: Importance.max,
        priority: Priority.high,
        sound: sound ? RawResourceAndroidNotificationSound('azan') : null,
        enableVibration: vibrate,
        playSound: sound,
      ),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      '$prayerName',
      'It is time for $prayerName prayer',
      tz.TZDateTime.from(prayerTime, tz.local),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print('Notification scheduled for $prayerName at $prayerTime with sound: $sound, vibrate: $vibrate');
  }


  Future<void> setNotificationModePreference(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('notification_mode', mode);
  }

  Future<String> getNotificationModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('notification_mode') ?? 'Beep';
  }
  Future<void> loadNotificationModePreference() async {
    notificationMode = await getNotificationModePreference();
    setState(() {});
  }




  Widget buildPrayerTile(String prayerName, String prayerTime, BuildContext context) {
    return ListTile(
      title: Text(
        prayerName,
        style: const TextStyle(
          wordSpacing: 2,
          fontFamily: 'Kitab-Bold',
          color: Colors.amberAccent,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        prayerTime,
        style: const TextStyle(
          wordSpacing: 2,
          fontFamily: 'Kitab-Bold',
          color: Colors.amberAccent,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (String value) async {
          setState(() {
            notificationMode = value;
          });

          // Parse the prayerTime string to DateTime object
          DateTime now = DateTime.now();
          DateTime prayerDateTime = DateTime.parse(
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} $prayerTime:00',
          );

          // Schedule the notification based on the selected mode
          switch (notificationMode) {
            case 'sound':
              await scheduleAzanNotification(prayerName, prayerDateTime, sound: true, vibrate: false);
              break;
            case 'vibrate':
              await scheduleAzanNotification(prayerName, prayerDateTime, sound: false, vibrate: true);
              break;
            case 'mute':
              await scheduleAzanNotification(prayerName, prayerDateTime, sound: false, vibrate: false);
              break;
          }

          // Optional: Provide feedback to the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Notification scheduled for $prayerName at $prayerTime ($notificationMode)'),
            ),
          );
        },
        itemBuilder: (BuildContext context) {
          return {'sound', 'vibrate', 'mute'}.map((String choice) {
            return PopupMenuItem<String>(
              value: choice,
              child: Text(choice),
            );
          }).toList();
        },
      ),
    );
  }










  @override
  void initState() {
    super.initState();


    initialized(flutterLocalNotificationsPlugin);
    getCurrentPosition();
    getPrayerTimes();
    loadNotificationModePreference();
    tz.initializeTimeZones();

    }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
backgroundColor: gridContainerColor,
      appBar: AppBar(

        title: const Row(
          children: [

            Text('Daily Prayer Time'),
          ],
        ),
        automaticallyImplyLeading: true,


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
              Text(' ${currentAddress  ?? ""}', style: const TextStyle(color: Colors.white),),


            ],
          ),







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
                                  buildPrayerTile('Fajr', prayerTimes!.fajr, context),
                                  const SizedBox(height: 7,),
                                  buildPrayerTile('Sunrise', prayerTimes.sunrise, context),
                                  buildPrayerTile('Dhuhr', prayerTimes.dhuhr, context),
                                  buildPrayerTile('Asr', prayerTimes.asr, context),
                                  buildPrayerTile('Maghrib', prayerTimes.maghrib, context),
                                  buildPrayerTile('Sunset', prayerTimes.sunset, context),
                                 buildPrayerTile('Isha', prayerTimes.isha, context),
                                 buildPrayerTile('Midnight', prayerTimes.midnight, context),
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
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
                alignment: Alignment.topLeft,
                child: Text('Change Calculation Method')),
          ),
          DropdownButton<int>(
            focusColor: gridContainerColor,
            hint: const Text('calculation method'),

            value: selectedCalculationMethod,
            onChanged: (int? newValue) {
              setState(() {
                selectedCalculationMethod = newValue!;
                getPrayerTimes(); // Fetch new prayer times when method changes
              });
            },
            items: calculationMethods.entries.map((entry) {
              return DropdownMenuItem<int>(

                value: entry.value,
                child: Text(entry.key),
              );
            }).toList(),
          ),



        ],
      ),

    );
  }


}







