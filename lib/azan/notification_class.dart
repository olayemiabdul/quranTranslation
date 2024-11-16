

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart'; // Updated import
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onSelectNotifications = BehaviorSubject<String?>();

  static Future init({bool initScheduled = false}) async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (payload) async {
        onSelectNotifications.add(payload.payload);
      },
    );

    if (initScheduled) {
      tz.initializeTimeZones();
      final locationName = await FlutterTimezone.getLocalTimezone(); // Updated method
      tz.setLocalLocation(tz.getLocation(locationName));
    }

    // Create notification channel for Android
    const androidNotificationChannel = AndroidNotificationChannel(
      'channel id',
      'channelName',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  static Future notificationDetails() async {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id',
        'channelName',
        importance: Importance.max,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifications.show(
        id,
        title,
        body,
        await notificationDetails(),
        payload: payload,
      );

  Future<bool> requestExactAlarmPermission() async {
    if (Platform.isAndroid && (await Permission.scheduleExactAlarm.isDenied)) {
      if (await Permission.scheduleExactAlarm.request().isGranted) {
        return true;
      } else {
        await openAppSettings();
        return false;
      }
    }
    return true;
  }
  Future showScheduledNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
  }) async {
    // Print current local timezone
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    print('Current device timezone: $localTimezone');

    // Ensure timezone is set
    tz.setLocalLocation(tz.getLocation(localTimezone));
    print('Scheduled notification timezone: ${tz.local.name}');

    // Log the exact scheduled date and time with timezone
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
    print('Scheduled notification for: $tzScheduledDate');

    // Schedule the notification
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      await notificationDetails(),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      PermissionStatus status = await Permission.notification.status;
      if (!status.isGranted) {
        status = await Permission.notification.request();
      }
      return status.isGranted;
    }
    return true;
  }

  static tz.TZDateTime scheduleDailyNotification(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return scheduleDate.isBefore(now)
        ? scheduleDate.add(const Duration(days: 1))
        : scheduleDate;
  }
}