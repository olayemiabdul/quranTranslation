// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class NotificationClass{
//   static Future<void> initialized (FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async{
//   var andriodInitialize=const AndroidInitializationSettings('app_icon');
//   //var iOSInitialize=new IOSInitializationSettings();
//     var initializationSettings=InitializationSettings(
//       android: andriodInitialize,
//
//     );
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//
//   }
//   static Future scheduleAzanNotification({var id =0, required String title, required String textBody,
//   var payload,required FlutterLocalNotificationsPlugin fln}) async {
//     // bool soundEnabled = await getSoundPreference();
//
//     AndroidNotificationDetails andriod =  AndroidNotificationDetails(
//       'azan_channel_id',
//       'Azan Notifications',
//       channelDescription: 'Notification channel for Azan timings',
//       importance: Importance.max,
//       priority: Priority.high,
//       sound: RawResourceAndroidNotificationSound('azan'),
//       playSound: true,
//     );
//     var notificatClass=NotificationDetails(android:andriod, );
//
//     //NotificationDetails not = NotificationDetails(android: androidNotificationDetails);
//
//     await fln.show(0,title,textBody,notificatClass
//       // 0,
//       // '$prayerName Time',
//       // 'It is time for $prayerName prayer',
//       // tz.TZDateTime.from(prayerTime, tz.local),
//       // notificationDetails,
//       // androidAllowWhileIdle: true,
//       // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
//       // matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }
//
//
// }
//
//
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService() {
    // Initialize the timezone package
    tz.initializeTimeZones();

    final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleNotification(String title, String body, DateTime scheduledTime, String notificationType) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'azan_channel_id', // channel ID
      'Azan Notifications', // channel name
      channelDescription: 'Notification channel for Azan timings',// Change this to your channel description
      importance: Importance.max,
      priority: Priority.high,
      sound: notificationType == 'sound' ? RawResourceAndroidNotificationSound('azan') : null,
      playSound: notificationType == 'sound',
      enableVibration: notificationType == 'vibrate',
    );

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    // Schedule the notification using zonedSchedule
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
