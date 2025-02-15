import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';


import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../constant.dart';
import '../dropdown_class/calculation_methods.dart';
import '../model/prayer_time_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'notification_class.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();



class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({super.key});

  @override
  State<PrayerTimePage> createState() => _PrayerTimePageState();
}

class _PrayerTimePageState extends State<PrayerTimePage> {

  DateTime selectedDate = DateTime.now();
  bool exactAlarmEnabled = false;

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
  bool isNotificationInitialized = false;


  NotificationApi test = NotificationApi();







  // Future<void> requestExactAlarmPermission() async {
  //   if (await Permission.scheduleExactAlarm.isDenied) {
  //     await Permission.scheduleExactAlarm.request();
  //   }
  // }



  Future<bool> _handleLocationPermission() async {
    if (kIsWeb) {
      return true; // Location permission is not needed on the web.
    }
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

    if (!kIsWeb) {
      await handleNotificationPermission();
    }
    return true;
  }

  Future<void> handleNotificationPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
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
  }

  // Future<void> handleNotificationPermission() async {
  //   PermissionStatus status = await Permission.notification.status;
  //
  //   if (!status.isGranted) {
  //     status = await Permission.notification.request();
  //   }
  //
  //   if (status.isGranted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Notification permissions are granted')));
  //   } else if (status.isDenied) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Notification permissions are denied')));
  //   } else if (status.isPermanentlyDenied) {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         content: Text(
  //             'Notification permissions are permanently denied. Please enable them in settings.')));
  //     await openAppSettings();
  //   }
  // }

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
        currentCity = place.subAdministrativeArea;
        currentCountry = place.country;
        print(currentCity);
        print(currentCountry);
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
    print(date);



    final response = await http.get(
        Uri.parse('https://api.aladhan.com/v1/timingsByCity/$date?city=$currentCity&country=$currentCountry&method=$selectedCalculationMethod')
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(currentCity);
      print(currentCountry);
      return PrayerDailyTimes.fromJson(data['data']['timings']);

    } else {
      throw Exception('Failed to load prayer times');

    }

  }









  Future<bool> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        final status = await Permission.scheduleExactAlarm.request();
        if (!status.isGranted) {
          print('Exact Alarm permission denied. Redirecting to app settings...');
          await openAppSettings();
          return false;
        }
      }
    }
    return true;
  }

  Future<void> initializeNotifications() async {
    await NotificationApi.init(initScheduled: true);
    setState(() {
      isNotificationInitialized = true;
    });
  }
  // Future<void> scheduleAzanNotification(
  //     String prayerName,
  //     DateTime prayerTime, {
  //       required bool sound,
  //       required bool vibrate,
  //     }) async {
  //   if (!isNotificationInitialized || kIsWeb) return;
  //   // Request exact alarm permission if not already granted
  //   final exactAlarmPermissionGranted = await requestExactAlarmPermission();
  //   if (!exactAlarmPermissionGranted) {
  //     print('Cannot schedule $prayerName notification: Exact Alarm permission is not granted.');
  //     return;
  //   }
  //
  //   final int notificationId = prayerName.hashCode;
  //   tz.TZDateTime scheduledDate = tz.TZDateTime.from(prayerTime, tz.local);
  //   final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  //
  //   // Check if scheduled time is in the past, and if so, schedule it for the next day.
  //   if (scheduledDate.isBefore(now)) {
  //     scheduledDate = scheduledDate.add(const Duration(days: 1));
  //     print('Rescheduled $prayerName notification for the next day at $scheduledDate');
  //   }
  //
  //   try {
  //     await flutterLocalNotificationsPlugin.zonedSchedule(
  //       notificationId,
  //       'Prayer Time',
  //       'It is time for $prayerName prayer',
  //       scheduledDate,
  //       NotificationDetails(
  //         android: AndroidNotificationDetails(
  //           'azan_channel_id',
  //           'Prayer Times',
  //           channelDescription: 'Notifications for prayer times',
  //           importance: Importance.max,
  //           priority: Priority.high,
  //           sound: sound ? const RawResourceAndroidNotificationSound('azan') : null,
  //           playSound: sound,
  //           enableVibration: vibrate,
  //         ),
  //       ),
  //       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //
  //       uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  //       matchDateTimeComponents: DateTimeComponents.time,
  //     );
  //   } catch (e) {
  //     print('Error scheduling notification: $e');
  //   }
  // }
  Future<void> scheduleAzanNotification(
      String prayerName,
      DateTime prayerTime, {
        required bool sound,
        required bool vibrate,
      }) async {
    if (!isNotificationInitialized || kIsWeb) return;

    final int notificationId = prayerName.hashCode;
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(prayerTime, tz.local);
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Prayer Time',
        'It is time for $prayerName prayer',
        scheduledDate,
        NotificationDetails(
            android: AndroidNotificationDetails(
              'azan_channel_id',
              'Prayer Times',
              channelDescription: 'Notifications for prayer times',
              importance: Importance.max,
              priority: Priority.high,
              sound: sound ? const RawResourceAndroidNotificationSound('azan') : null,
              playSound: sound,
              enableVibration: vibrate,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: sound,
              sound: sound ? 'azan.mp3' : null,
            )
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> schedulePrayerNotifications(PrayerDailyTimes prayerTimes) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Map of prayer times
    final prayerMap = {
      'Fajr': prayerTimes.fajr,
      'Dhuhr': prayerTimes.dhuhr,
      'Asr': prayerTimes.asr,
      'Maghrib': prayerTimes.maghrib,
      'Isha': prayerTimes.isha,
    };

    // Schedule notifications for each prayer time
    prayerMap.forEach((name, timeStr) {
      try {
        final List<String> timeParts = timeStr.split(':');
        final prayerDateTime = DateTime(
          today.year,
          today.month,
          today.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );

        // Schedule notification for each prayer time
        scheduleAzanNotification(
          name,
          prayerDateTime,
          sound: notificationMode == 'sound',
          vibrate: notificationMode == 'vibrate',
        );
      } catch (e) {
        print('Error scheduling $name notification: $e');
      }
    });
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

          // Parse prayer time
          final List<String> timeParts = prayerTime.split(':');
          final now = DateTime.now();
          final prayerDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );

          // Schedule notification with selected mode
          await scheduleAzanNotification(
            prayerName,
            prayerDateTime,
            sound: value == 'sound',
            vibrate: value == 'vibrate',
          );

          // Save preference
          await setNotificationModePreference(value);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$prayerName notification set to $value mode'),
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

  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      _requestIOSPermissions();
    }

    tz.initializeTimeZones();
    initializeNotifications();
    getCurrentPosition();
    loadNotificationModePreference();

    if (Platform.isAndroid) {
      requestExactAlarmPermission();
    }
    handleNotificationPermission();
  }
  Future<void> _requestIOSPermissions() async {
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
    IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
    );
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
              future: getPrayerTimes(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final prayerTimes = snapshot.data!;
                  // Schedule notifications when prayer times are loaded
                  schedulePrayerNotifications(prayerTimes);

                  return ListView(
                    children: [
                      Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildPrayerTile('Fajr', prayerTimes.fajr, context),
                            const SizedBox(height: 7),
                            buildPrayerTile('Sunrise', prayerTimes.sunrise, context),
                            buildPrayerTile('Dhuhr', prayerTimes.dhuhr, context),
                            buildPrayerTile('Asr', prayerTimes.asr, context),
                            buildPrayerTile('Maghrib', prayerTimes.maghrib, context),
                            buildPrayerTile('Sunset', prayerTimes.sunset, context),
                            buildPrayerTile('Isha', prayerTimes.isha, context),
                            buildPrayerTile('Midnight', prayerTimes.midnight, context),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: Text(
                      'Check your Connection',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Change Calculation Method',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          DropdownButton<int>(
            focusColor: gridContainerColor,
            dropdownColor: gridContainerColor,
            value: selectedCalculationMethod,
            onChanged: (int? newValue) {
              setState(() {
                selectedCalculationMethod = newValue!;
                getPrayerTimes();
              });
            },
            items: calculationMethods.entries.map((entry) {
              return DropdownMenuItem<int>(
                value: entry.value,
                child: Text(
                  entry.key,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),



        ],
      ),

    );
  }


}







