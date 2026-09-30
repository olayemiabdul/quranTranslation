import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../dropdown_class/calculation_methods.dart';
import 'azan_service.dart';

/// Drop-in replacement: same class name, so widget_data.dart needs no change.
class PrayerTimePage extends StatefulWidget {
  const PrayerTimePage({super.key});

  @override
  State<PrayerTimePage> createState() => _PrayerTimePageState();
}

class _PrayerTimePageState extends State<PrayerTimePage> with WidgetsBindingObserver {
  static const _green = Color(0xFF1F5E3B);
  static const _gold = Color(0xFFC9A227);
  static const _paper = Color(0xFFFBF7EA);

  final _svc = AzanService.instance;
  List<PrayerDay> _week = [];
  Map<String, AzanMode> _modes = {};
  AzanHealth? _health;
  String _place = '';
  int _method = 3;
  String? _error;
  bool _loading = true;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));
    _boot();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  // User comes back from the "Alarms & reminders" settings page.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshHealthAndReschedule();
  }

  Future<void> _boot() async {
    _method = await _svc.method();
    _week = await _svc.cachedWeek();
    final saved = await _svc.savedLocation();
    _place = saved?.label ?? '';
    await _loadModes();
    setState(() {});

    if (!kIsWeb) _health = await _svc.requestPermissions();
    await _locateAndLoad();
  }

  Future<void> _loadModes() async {
    _modes = {for (final p in AzanService.prayers) p: await _svc.modeFor(p)};
  }

  Future<void> _refreshHealthAndReschedule() async {
    await _svc.schedule(_week);
    final h = await _svc.health();
    if (mounted) setState(() => _health = h);
  }

  Future<void> _locateAndLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pos = await _position();
      if (pos != null) {
        String label = '';
        try {
          final marks = await Geocoding().placemarkFromCoordinates(pos.latitude, pos.longitude);
          final m = marks.first;
          label = [m.locality, m.subAdministrativeArea, m.country]
              .where((e) => e != null && e.isNotEmpty)
              .take(2)
              .join(', ');
        } catch (_) {
          // Reverse geocoding is best-effort only: prayer times still work
          // from coordinates alone, so a failure here just leaves the
          // location label blank rather than blocking anything.
        }
        await _svc.saveLocation(pos.latitude, pos.longitude, label);
        _place = label;
      }
      final loc = await _svc.savedLocation();
      if (loc == null) {
        throw Exception('Turn on location so we can work out your prayer times.');
      }
      _week = await _svc.fetchWeek(loc.lat, loc.lng);
      await _svc.schedule(_week);
      _health = await _svc.health();
    } catch (e) {
      _error = _week.isEmpty
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Showing saved times. Connect to the internet to update.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<Position?> _position() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      return null;
    }
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } catch (_) {
      return Geolocator.getLastKnownPosition();
    }
  }

 ///ui
  // A fixed light design: pin the light theme so a dark app theme cannot
  // turn its default-coloured text white on these light surfaces.
  @override
  Widget build(BuildContext context) =>
      Theme(data: ThemeData.light(), child: Builder(builder: _buildLight));

  Widget _buildLight(BuildContext context) {
    final today = _week.isNotEmpty ? _week.first : null;
    final next = _nextPrayer();

    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        title: const Text('Prayer times'),
        actions: [
          IconButton(
            tooltip: 'Update location',
            icon: const Icon(Icons.my_location),
            onPressed: _loading ? null : _locateAndLoad,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _locateAndLoad,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            if (_health != null) _healthBanner(_health!),
            _nextCard(next),
            const SizedBox(height: 16),
            if (_loading && today == null)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator(color: _green)),
              ),
            if (_error != null) _errorText(_error!),
            if (today != null) ...AzanService.displayed.map((p) => _row(p, today.times[p]!, next?.$1 == p)),
            const SizedBox(height: 20),
            _methodPicker(),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: _green),
              icon: const Icon(Icons.volume_up),
              label: const Text('Test adhan in 1 minute'),
              onPressed: () async {
                await _svc.testIn();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Lock your phone. The adhan should play in about a minute.'),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  (String, DateTime)? _nextPrayer() {
    final now = DateTime.now();
    for (final day in _week) {
      for (final p in AzanService.prayers) {
        final t = day.times[p];
        if (t != null && t.isAfter(now)) return (p, t);
      }
    }
    return null;
  }

  Widget _nextCard((String, DateTime)? next) {
    final left = next?.$2.difference(DateTime.now());
    String countdown = '';
    if (left != null) {
      final h = left.inHours, m = left.inMinutes % 60;
      countdown = h > 0 ? 'in ${h}h ${m}m' : 'in ${m}m';
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.place, color: _gold, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(_place.isEmpty ? 'Finding your location' : _place,
                  style: const TextStyle(color: Colors.white70)),
            ),
          ]),
          const SizedBox(height: 14),
          Text(next == null ? 'Loading' : 'Next: ${next.$1}',
              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w600)),
          if (next != null)
            Text('${DateFormat.jm().format(next.$2)}  $countdown',
                style: const TextStyle(color: _gold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _row(String prayer, DateTime time, bool isNext) {
    final alarmable = AzanService.prayers.contains(prayer);
    final mode = _modes[prayer] ?? AzanMode.adhan;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isNext ? const Color(0xFFEAF3EC) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isNext ? _green : const Color(0xFFE3DCC4)),
      ),
      child: ListTile(
        title: Text(prayer, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
        subtitle: Text(DateFormat.jm().format(time)),
        trailing: alarmable
            ? PopupMenuButton<AzanMode>(
                tooltip: 'Alert for $prayer',
                initialValue: mode,
                icon: Icon(_icon(mode), color: _green),
                onSelected: (m) async {
                  setState(() => _modes[prayer] = m);
                  await _svc.setMode(prayer, m);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: AzanMode.adhan, child: Text('Adhan')),
                  PopupMenuItem(value: AzanMode.vibrate, child: Text('Vibrate')),
                  PopupMenuItem(value: AzanMode.silent, child: Text('Silent notification')),
                  PopupMenuItem(value: AzanMode.off, child: Text('Off')),
                ],
              )
            : null,
      ),
    );
  }

  IconData _icon(AzanMode m) => switch (m) {
        AzanMode.adhan => Icons.volume_up,
        AzanMode.vibrate => Icons.vibration,
        AzanMode.silent => Icons.notifications_none,
        AzanMode.off => Icons.notifications_off_outlined,
      };

  Widget _healthBanner(AzanHealth h) {
    String? msg;
    if (!h.notificationsAllowed) {
      msg = 'Notifications are off, so the adhan cannot play. Tap to allow them.';
    } else if (!h.exactAlarmsAllowed) {
      msg = 'Allow "Alarms & reminders" so the adhan plays on time. Tap to open settings.';
    }
    if (msg == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFFFFF1CC),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final hh = await _svc.requestPermissions();
            setState(() => _health = hh);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFF8A6100)),
              const SizedBox(width: 10),
              Expanded(child: Text(msg)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _errorText(String e) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(e, style: const TextStyle(color: Color(0xFF9B2C2C))),
      );

  Widget _methodPicker() {
    return DropdownButtonFormField<int>(
      initialValue: calculationMethods.containsValue(_method) ? _method : null,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Calculation method',
        border: OutlineInputBorder(),
      ),
      items: calculationMethods.entries
          .map((e) => DropdownMenuItem(value: e.value, child: Text(e.key)))
          .toList(),
      onChanged: (v) async {
        if (v == null) return;
        setState(() => _method = v);
        await _svc.setMethod(v);
        await _locateAndLoad();
      },
    );
  }
}
