import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../model/azan_new_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



class AzanTimesScreen extends StatefulWidget {
  const AzanTimesScreen({super.key});

  @override
  _AzanTimesScreenState createState() => _AzanTimesScreenState();
}

class _AzanTimesScreenState extends State<AzanTimesScreen> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    fetchAndSchedulePrayerTimes();
  }
  // api_service.dart


  Future<AzanTimes> fetchPrayerTimes() async {
    final url = Uri.parse('https://api.aladhan.com/v1/timingsByCity/21-05-2024?city=greater%20manchester&country=unitedkingdom&method=8');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return AzanTimes.fromJson(jsonResponse['data']['timings']);
    } else {
      throw Exception('Failed to load prayer times');
    }
  }

  void initializeNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: iOS);
    flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> fetchAndSchedulePrayerTimes() async {
    try {
      AzanTimes prayerTimes = await fetchPrayerTimes();
      scheduleAzan('Fajr', prayerTimes.fajr);
      scheduleAzan('Dhuhr', prayerTimes.dhuhr);
      scheduleAzan('Asr', prayerTimes.asr);
      scheduleAzan('Maghrib', prayerTimes.maghrib);
      scheduleAzan('Isha', prayerTimes.isha);
    } catch (e) {
      print('Error fetching prayer times: $e');
    }
  }

  void scheduleAzan(String prayerName, String prayerTime) {
    final timeParts = prayerTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final now = DateTime.now();
    final scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    final androidDetails = const AndroidNotificationDetails(
      'azan_channel',
      'Azan Notifications',
      channelDescription: 'Channel for Azan notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('azan'), // Custom sound for Android
    );
    final iOSDetails = const DarwinNotificationDetails(
      sound: 'azan.mp3',
    );
    final notificationDetails = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    flutterLocalNotificationsPlugin.zonedSchedule(
      prayerName.hashCode,
      'Azan',
      'It\'s time for $prayerName prayer',
      tzScheduledDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Times')),
      body: const Center(child: Text('Fetching prayer times...')),
    );
  }
}