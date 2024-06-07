// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// enum NotificationSoundType { Sound, Vibrate, Mute }
//
// Future<void> saveSoundPreference(NotificationSoundType soundType) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   await prefs.setInt('soundType', soundType.index);
// }
//
// Future<NotificationSoundType> getSoundPreference() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   int index = prefs.getInt('soundType') ?? NotificationSoundType.Sound.index;
//   return NotificationSoundType.values[index];
// }
//
//
// Future<void> scheduleAzanNotification(DateTime dateTime, String prayerName, NotificationSoundType soundType) async {
//   String? soundSource;
//   List<int>? vibrationPattern;
//
//   switch (soundType) {
//     case NotificationSoundType.Sound:
//       soundSource = 'resource://raw/azan';
//       break;
//     case NotificationSoundType.Vibrate:
//       vibrationPattern = highVibrationPattern;
//       break;
//     case NotificationSoundType.Mute:
//     default:
//       soundSource = null;
//       vibrationPattern = null;
//       break;
//   }
//
//   await AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: dateTime.hashCode,
//       channelKey: 'azan_channel',
//       title: 'Azan Notification',
//       body: 'It is time for $prayerName prayer',
//       notificationLayout: NotificationLayout.Default,
//       customSound: soundSource,
//     ),
//     schedule: NotificationCalendar.fromDate(date: dateTime),
//     actionButtons: [
//       NotificationActionButton(
//         key: 'DISABLE_SOUND',
//         label: 'Mute Azan',
//         autoDismissible: true,
//       ),
//     ],
//   );
// }
//
// const List<int> highVibrationPattern = [0, 1000, 500, 2000];
//
//
// Future<void> fetchAndSchedulePrayerTimes(NotificationSoundType soundType) async {
//   final url = Uri.parse('https://api.aladhan.com/v1/timingsByCity?city=Manchester&country=United+Kingdom&method=8&date=18-05-2024');
//   final response = await http.get(url);
//
//   if (response.statusCode == 200) {
//     final Map<String, dynamic> data = jsonDecode(response.body);
//     final timings = data['data']['timings'];
//
//     final DateTime now = DateTime.now();
//     final DateTime fajrTime = DateTime.parse('${now.year}-${now.month}-${now.day} ${timings['Fajr']}:00');
//     final DateTime dhuhrTime = DateTime.parse('${now.year}-${now.month}-${now.day} ${timings['Dhuhr']}:00');
//     final DateTime asrTime = DateTime.parse('${now.year}-${now.month}-${now.day} ${timings['Asr']}:00');
//     final DateTime maghribTime = DateTime.parse('${now.year}-${now.month}-${now.day} ${timings['Maghrib']}:00');
//     final DateTime ishaTime = DateTime.parse('${now.year}-${now.month}-${now.day} ${timings['Isha']}:00');
//
//     scheduleAzanNotification(fajrTime, 'Fajr', soundType);
//     scheduleAzanNotification(dhuhrTime, 'Dhuhr', soundType);
//     scheduleAzanNotification(asrTime, 'Asr', soundType);
//     scheduleAzanNotification(maghribTime, 'Maghrib', soundType);
//     scheduleAzanNotification(ishaTime, 'Isha', soundType);
//   } else {
//     throw Exception('Failed to load prayer times');
//   }
// }
//
