import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:universal_quran/constant.dart';

/// How a single prayer should alert the user.
enum AzanMode { adhan, vibrate, silent, off }

/// One day of prayer times, already parsed into local DateTimes.
class PrayerDay {
  final DateTime date;
  final Map<String, DateTime> times; // Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha
  PrayerDay(this.date, this.times);
}

/// Health of the alarm setup, so the UI can tell the user what is wrong.
class AzanHealth {
  final bool notificationsAllowed;
  final bool exactAlarmsAllowed;
  final int pendingCount;
  const AzanHealth(this.notificationsAllowed, this.exactAlarmsAllowed, this.pendingCount);
}

class AzanService {
  AzanService._();
  static final AzanService instance = AzanService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
 static const List<String> prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  static const List<String> displayed = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
 static const int daysAhead = 7; // 35 alarms; stays under iOS's 64 limit
  static const int idBase = 7000;

  // ---------------------------------------------------------------- setup
  Future<void> init() async {
    if (_ready || kIsWeb) return;

    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Unknown zone name on some devices. We schedule by absolute UTC
      // instant below, so this fallback never shifts the alarm time.
      tz.setLocalLocation(tz.UTC);
    }

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.createNotificationChannel(const AndroidNotificationChannel(
        chAdhan,
        'Adhan',
        description: 'Plays the adhan at prayer time',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('azan'),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        enableVibration: true,
      ));
      await android.createNotificationChannel(const AndroidNotificationChannel(
        chVibrate,
        'Prayer reminder (vibrate)',
        importance: Importance.high,
        playSound: false,
        enableVibration: true,
      ));
      await android.createNotificationChannel(const AndroidNotificationChannel(
        chSilent,
        'Prayer reminder (silent)',
        importance: Importance.high,
        playSound: false,
        enableVibration: false,
      ));
    }
    _ready = true;
  }

  /// Ask for everything we need. Call from a screen, not from main().
  Future<AzanHealth> requestPermissions() async {
    await init();
    if (Platform.isAndroid) {
      final a = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!;
      await a.requestNotificationsPermission();
      final exact = await a.canScheduleExactNotifications() ?? false;
      if (!exact) {
        // Opens the "Alarms & reminders" system page (Android 12+).
        await a.requestExactAlarmsPermission();
      }
    } else if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
    return health();
  }

  Future<AzanHealth> health() async {
    await init();
    bool notif = true, exact = true;
    if (Platform.isAndroid) {
      final a = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!;
      notif = await a.areNotificationsEnabled() ?? false;
      exact = await a.canScheduleExactNotifications() ?? false;
    }
    final pending = await _plugin.pendingNotificationRequests();
    final ours = pending.where((p) => p.id >= idBase && p.id < idBase + 1000).length;
    return AzanHealth(notif, exact, ours);
  }

  // ---------------------------------------------------------------- prefs
  Future<AzanMode> modeFor(String prayer) async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString('azan_mode_$prayer');
    return AzanMode.values.firstWhere((m) => m.name == v, orElse: () => AzanMode.adhan);
  }

  Future<void> setMode(String prayer, AzanMode mode) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('azan_mode_$prayer', mode.name);
    await rescheduleFromSaved();
  }

  Future<int> method() async =>
      (await SharedPreferences.getInstance()).getInt('azan_method') ?? 3;

  Future<void> setMethod(int m) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('azan_method', m);
    await p.remove('azan_cache');
  }

  Future<void> saveLocation(double lat, double lng, String label) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble('azan_lat', lat);
    await p.setDouble('azan_lng', lng);
    await p.setString('azan_label', label);
  }

  Future<({double lat, double lng, String label})?> savedLocation() async {
    final p = await SharedPreferences.getInstance();
    final lat = p.getDouble('azan_lat');
    final lng = p.getDouble('azan_lng');
    if (lat == null || lng == null) return null;
    return (lat: lat, lng: lng, label: p.getString('azan_label') ?? '');
  }

  // ---------------------------------------------------------------- data
  /// Fetches today + the next 6 days by coordinates (city names from the
  /// geocoder are often null, which broke the old timingsByCity call).
  Future<List<PrayerDay>> fetchWeek(double lat, double lng) async {
    final m = await method();
    final today = DateTime.now();
    final days = List.generate(daysAhead,
        (i) => DateTime(today.year, today.month, today.day).add(Duration(days: i)));

    final results = await Future.wait(days.map((d) async {
      final ds = '${_two(d.day)}-${_two(d.month)}-${d.year}';
      final uri = Uri.parse(
          'https://api.aladhan.com/v1/timings/$ds?latitude=$lat&longitude=$lng&method=$m');
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        throw Exception('Prayer times request failed (${res.statusCode})');
      }
      final timings = (json.decode(res.body)['data']['timings'] as Map).cast<String, dynamic>();
      return PrayerDay(d, {
        for (final name in displayed) name: _parse(d, timings[name].toString()),
      });
    }));

    await _cache(results);
    return results;
  }

  Future<List<PrayerDay>> cachedWeek() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('azan_cache');
    if (raw == null) return [];
    final list = json.decode(raw) as List;
    return list.map((e) {
      final times = (e['t'] as Map).map((k, v) =>
          MapEntry(k.toString(), DateTime.fromMillisecondsSinceEpoch(v as int)));
      return PrayerDay(DateTime.fromMillisecondsSinceEpoch(e['d'] as int), times);
    }).toList();
  }

  Future<void> _cache(List<PrayerDay> days) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        'azan_cache',
        json.encode(days
            .map((d) => {
                  'd': d.date.millisecondsSinceEpoch,
                  't': d.times.map((k, v) => MapEntry(k, v.millisecondsSinceEpoch)),
                })
            .toList()));
  }

  // ---------------------------------------------------------------- scheduling
  /// Call on app start and whenever settings change. Refreshes the week of
  /// alarms so they never run out as long as the app is opened once a week.
  Future<void> rescheduleFromSaved() async {
    if (kIsWeb) return;
    final loc = await savedLocation();
    if (loc == null) return;
    List<PrayerDay> week;
    try {
      week = await fetchWeek(loc.lat, loc.lng);
    } catch (_) {
      week = await cachedWeek(); // offline: use last known times
    }
    await schedule(week);
  }

  Future<void> schedule(List<PrayerDay> week) async {
    await init();

    // Clear everything pending, including the old version's hashCode-id
    // alarms that repeated daily at yesterday's time.
    final pending = await _plugin.pendingNotificationRequests();
    for (final p in pending) {
      await _plugin.cancel(p.id);
    }

    final exact = Platform.isAndroid
        ? (await _plugin
                    .resolvePlatformSpecificImplementation<
                        AndroidFlutterLocalNotificationsPlugin>()
                    ?.canScheduleExactNotifications() ??
                false)
        : true;
    final scheduleMode = exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    final now = DateTime.now();
    for (var day = 0; day < week.length; day++) {
      for (var i = 0; i < prayers.length; i++) {
        final name = prayers[i];
        final at = week[day].times[name];
        if (at == null || at.isBefore(now)) continue;
        final mode = await modeFor(name);
        if (mode == AzanMode.off) continue;

        await _plugin.zonedSchedule(
          idBase + day * 10 + i,
          '$name ${_arabic[name]}',
          'It is time for $name prayer',
          // Absolute instant: correct even if the tz name lookup failed.
          tz.TZDateTime.from(at.toUtc(), tz.UTC),
          _details(mode),
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'prayer:$name',
        );
      }
    }
  }

  /// Fires a real adhan in [seconds] so you can test on a device.
  Future<void> testIn({int seconds = 60}) async {
    await init();
    await _plugin.zonedSchedule(
      idBase + 999,
      'Test adhan',
      'If you hear this, prayer alerts are working',
      tz.TZDateTime.now(tz.UTC).add(Duration(seconds: seconds)),
      _details(AzanMode.adhan),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  NotificationDetails _details(AzanMode mode) {
    final channel = switch (mode) {
      AzanMode.adhan => (chAdhan, 'Adhan'),
      AzanMode.vibrate => (chVibrate, 'Prayer reminder (vibrate)'),
      _ => (chSilent, 'Prayer reminder (silent)'),
    };
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel.$1,
        channel.$2,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        playSound: mode == AzanMode.adhan,
        sound: mode == AzanMode.adhan
            ? const RawResourceAndroidNotificationSound('azan')
            : null,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        enableVibration: mode != AzanMode.silent,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: mode == AzanMode.adhan,
        // iOS only plays .caf/.aiff/.wav under 30 seconds, bundled in Runner.
        sound: mode == AzanMode.adhan ? 'azan.caf' : null,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  // ---------------------------------------------------------------- helpers
  static const _arabic = {
    'Fajr': 'الفجر',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء',
  };

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// Handles "05:12" and "05:12 (BST)".
  static DateTime _parse(DateTime day, String raw) {
    final m = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(raw)!;
    return DateTime(day.year, day.month, day.day, int.parse(m[1]!), int.parse(m[2]!));
  }
}
