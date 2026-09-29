import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How the player repeats.
enum AudioRepeat {
  off,

  /// Stay on one ayah. The memorisation setting.
  ayah,

  /// Loop the whole surah.
  surah,
}

/// Where the reader stopped, so the player can offer to carry on.
class LastPlayed {
  final int surahNumber;
  final int ayahIndex; // zero-based within the surah
  final Duration position;

  const LastPlayed({
    required this.surahNumber,
    required this.ayahIndex,
    required this.position,
  });
}

/// Settings for the recitation player. The old player remembered nothing at
/// all: not the reciter, not the speed, not where you stopped.
class AudioPrefs extends ChangeNotifier {
  AudioPrefs._();
  static final AudioPrefs instance = AudioPrefs._();

  static const defaultReciter = 'ar.alafasy';

  static const _kReciter = 'audio_reciter';
  static const _kBitrate = 'audio_bitrate';
  static const _kSpeed = 'audio_speed';
  static const _kRepeat = 'audio_repeat';
  static const _kLastSurah = 'audio_last_surah';
  static const _kLastIndex = 'audio_last_index';
  static const _kLastPosition = 'audio_last_position_ms';

  String reciter = defaultReciter;

  /// 128 kbps by default; 64 for people watching their data.
  int bitrate = 128;

  /// Each edition is fetched at the nearest bitrate it actually has; see
  /// [AudioCatalog.bitrateFor].
  bool get dataSaver => bitrate < 128;

  double speed = 1.0;
  AudioRepeat repeat = AudioRepeat.off;

  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final p = await SharedPreferences.getInstance();
    reciter = p.getString(_kReciter) ?? defaultReciter;
    bitrate = p.getInt(_kBitrate) ?? 128;
    speed = p.getDouble(_kSpeed) ?? 1.0;
    repeat = AudioRepeat.values.firstWhere(
      (e) => e.name == p.getString(_kRepeat),
      orElse: () => AudioRepeat.off,
    );
    _loaded = true;
    notifyListeners();
  }

  Future<void> setReciter(String v) async {
    reciter = v;
    notifyListeners();
    (await SharedPreferences.getInstance()).setString(_kReciter, v);
  }

  Future<void> setBitrate(int v) async {
    bitrate = v;
    notifyListeners();
    (await SharedPreferences.getInstance()).setInt(_kBitrate, v);
  }

  Future<void> setSpeed(double v) async {
    speed = v.clamp(0.5, 2.0);
    notifyListeners();
    (await SharedPreferences.getInstance()).setDouble(_kSpeed, speed);
  }

  Future<void> setRepeat(AudioRepeat v) async {
    repeat = v;
    notifyListeners();
    (await SharedPreferences.getInstance()).setString(_kRepeat, v.name);
  }

  /// Called as playback moves. Deliberately silent — it fires often.
  Future<void> saveLastPlayed(int surah, int index, Duration position) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kLastSurah, surah);
    await p.setInt(_kLastIndex, index);
    await p.setInt(_kLastPosition, position.inMilliseconds);
  }

  Future<LastPlayed?> lastPlayed() async {
    final p = await SharedPreferences.getInstance();
    final surah = p.getInt(_kLastSurah);
    if (surah == null) return null;
    return LastPlayed(
      surahNumber: surah,
      ayahIndex: p.getInt(_kLastIndex) ?? 0,
      position: Duration(milliseconds: p.getInt(_kLastPosition) ?? 0),
    );
  }

  Future<void> clearLastPlayed() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kLastSurah);
    await p.remove(_kLastIndex);
    await p.remove(_kLastPosition);
  }
}
