import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'audio_catalog.dart';
import 'audio_prefs.dart';

/// The one recitation player in the app.
///
/// Built on `just_audio` + `just_audio_background` rather than `audioplayers`,
/// for the reason that matters most in a Quran app: people listen with the
/// screen off, in the car, while they work. The old player stopped being
/// controllable the moment the app went to the background — no lock-screen
/// controls, no notification, no headphone buttons, and on many phones it
/// simply stopped.
///
/// A surah is loaded as a playlist of its ayahs, not one long file. That
/// costs nothing extra and buys three things the old player could not do:
/// the display knows which ayah is playing, a single ayah can be repeated
/// for memorisation, and playback resumes at the exact ayah it stopped on.
class QuranAudioService {
  QuranAudioService._();
  static final QuranAudioService instance = QuranAudioService._();

  final AudioPlayer _player = AudioPlayer();
  final AudioPrefs _prefs = AudioPrefs.instance;

  SurahMeta? _surah;
  String? _loadedKey; // surah + reciter + bitrate
  Timer? _sleepTimer;
  Timer? _saveTimer;
  DateTime? _sleepEndsAt;

  AudioPlayer get player => _player;
  SurahMeta? get currentSurah => _surah;

  // ------------------------------------------------------------- streams
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  bool get isPlaying => _player.playing;
  int get currentIndex => _player.currentIndex ?? 0;

  /// When a sleep timer is running, how long is left.
  Duration? get sleepRemaining {
    final end = _sleepEndsAt;
    if (end == null) return null;
    final left = end.difference(DateTime.now());
    return left.isNegative ? null : left;
  }

  // -------------------------------------------------------------- loading
  /// Loads [surah] for the current reciter and starts at [startIndex].
  /// Reloads only when the surah, reciter or bitrate actually changed, so
  /// reopening the player does not interrupt what is already playing.
  Future<void> loadSurah(
    SurahMeta surah, {
    int startIndex = 0,
    Duration startPosition = Duration.zero,
    bool autoPlay = true,
  }) async {
    await _prefs.load();
    final key = '${surah.number}|${_prefs.reciter}|${_prefs.bitrate}';

    if (_loadedKey == key) {
      if (_player.currentIndex != startIndex || startPosition > Duration.zero) {
        await _player.seek(startPosition, index: startIndex);
      }
      if (autoPlay && !_player.playing) unawaited(_player.play());
      return;
    }

    _surah = surah;
    _loadedKey = key;

    _ensureListening();
    _releaseClip();

    final urls = AudioCatalog.instance.surahUrls(
      surah: surah,
      edition: _prefs.reciter,
      dataSaver: _prefs.dataSaver,
    );

    final sources = <AudioSource>[
      for (var i = 0; i < urls.length; i++)
        AudioSource.uri(
          Uri.parse(urls[i]),
          // just_audio_background reads this to draw the notification and
          // the lock screen.
          tag: MediaItem(
            id: '${surah.number}:${i + 1}',
            album: surah.englishName,
            title: '${surah.englishName} · Ayah ${i + 1}',
            artist: _reciterLabel(_prefs.reciter),
            displayTitle: surah.name,
            displaySubtitle: 'Ayah ${i + 1} of ${surah.numberOfAyahs}',
          ),
        ),
    ];

    // preload: false matters. Al-Baqarah is 286 separate files, and
    // preloading them all stalls the first play for seconds.
    await _player.setAudioSources(
      sources,
      initialIndex: startIndex.clamp(0, sources.length - 1),
      initialPosition: startPosition,
      preload: false,
    );

    await applySettings();
    _startSavingPosition();
    if (autoPlay) unawaited(_player.play());
  }

  /// Pushes the saved speed and repeat mode onto the player.
  Future<void> applySettings() async {
    await _prefs.load();
    await _player.setSpeed(_prefs.speed);
    await _player.setLoopMode(switch (_prefs.repeat) {
      AudioRepeat.off => LoopMode.off,
      AudioRepeat.ayah => LoopMode.one,
      AudioRepeat.surah => LoopMode.all,
    });
  }

  // ------------------------------------------------------------- controls
  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();

  Future<void> togglePlay() =>
      _player.playing ? _player.pause() : _player.play();

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> nextAyah() async {
    if (_player.hasNext) await _player.seekToNext();
  }

  /// Restarts the current ayah if you are more than three seconds in,
  /// which is what a "previous" button should do in a player.
  Future<void> previousAyah() async {
    if (_player.position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
      return;
    }
    if (_player.hasPrevious) await _player.seekToPrevious();
  }

  Future<void> goToAyah(int index) async {
    await _player.seek(Duration.zero, index: index);
    if (!_player.playing) await _player.play();
  }

  Future<void> setSpeed(double speed) async {
    await _prefs.setSpeed(speed);
    await _player.setSpeed(_prefs.speed);
  }

  Future<void> setRepeat(AudioRepeat mode) async {
    await _prefs.setRepeat(mode);
    await applySettings();
  }

  /// Changing reciter or bitrate needs the playlist rebuilt, but it should
  /// resume on the same ayah rather than jumping back to the start.
  Future<void> reloadForCurrentReciter() async {
    final surah = _surah;
    if (surah == null) return;
    final index = _player.currentIndex ?? 0;
    final wasPlaying = _player.playing;
    _loadedKey = null;
    await loadSurah(surah, startIndex: index, autoPlay: wasPlaying);
  }

  // ------------------------------------------------ end of surah / clips
  StreamSubscription<ProcessingState>? _completionSub;

  void _ensureListening() {
    _completionSub ??= _player.processingStateStream
        .where((s) => s == ProcessingState.completed)
        .listen((_) => _onCompleted());
  }

  /// A playlist only completes after its last ayah (repeat modes loop
  /// instead), so this is the end of the surah: carry on into the next.
  Future<void> _onCompleted() async {
    final owner = _clipOwner;
    if (owner != null) {
      _clipDone.add(owner);
      return;
    }
    final surah = _surah;
    if (surah == null || surah.number >= 114) return;
    final next = AudioCatalog.instance.byNumber(surah.number + 1);
    if (next == null) return;
    try {
      await loadSurah(next);
    } catch (_) {
      // Offline at a surah boundary: stop quietly, the resume point is saved.
    }
  }

  // Listen-along from the readers. They play one ayah at a time and choose
  // the next themselves, but through this same player, so starting the
  // player while a reader recites replaces it rather than playing on top.
  Object? _clipOwner;
  final _clipDone = StreamController<Object>.broadcast();
  final _clipOwnerChanges = StreamController<Object?>.broadcast();

  /// Fires with the owner when a clip it started finishes.
  Stream<Object> get clipCompleted => _clipDone.stream;

  /// Fires when a different owner (or the surah player, as null) takes over.
  Stream<Object?> get clipOwnerChanges => _clipOwnerChanges.stream;

  /// Plays one ayah on behalf of [owner], replacing whatever was playing.
  Future<void> playClip({
    required Object owner,
    required String url,
    required MediaItem item,
  }) async {
    _ensureListening();
    if (_clipOwner != owner) {
      _clipOwner = owner;
      _clipOwnerChanges.add(owner);
    }
    // The surah player is no longer what is loaded.
    _saveTimer?.cancel();
    _saveTimer = null;
    if (_surah != null) saveNow();
    _surah = null;
    _loadedKey = null;

    await _player.setLoopMode(LoopMode.off);
    await _player.setAudioSource(AudioSource.uri(Uri.parse(url), tag: item));
    unawaited(_player.play());
  }

  /// Stops a clip, but only if [owner] still holds the player.
  Future<void> stopClip(Object owner) async {
    if (_clipOwner != owner) return;
    _clipOwner = null;
    _clipOwnerChanges.add(null);
    await _player.stop();
  }

  void _releaseClip() {
    if (_clipOwner == null) return;
    _clipOwner = null;
    _clipOwnerChanges.add(null);
  }

  // ---------------------------------------------------------- sleep timer
  void startSleepTimer(Duration duration) {
    cancelSleepTimer();
    _sleepEndsAt = DateTime.now().add(duration);
    _sleepTimer = Timer(duration, () async {
      await _player.pause();
      _sleepEndsAt = null;
      _sleepTimer = null;
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepEndsAt = null;
  }

  // ------------------------------------------------------- resume support
  void _startSavingPosition() {
    _saveTimer?.cancel();
    // Every five seconds, not on every position tick: writing to disk sixty
    // times a second would be absurd.
    _saveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final surah = _surah;
      if (surah == null || !_player.playing) return;
      _prefs.saveLastPlayed(
        surah.number,
        _player.currentIndex ?? 0,
        _player.position,
      );
    });
  }

  /// Call when the player screen closes: keeps playing, stops the ticker.
  void saveNow() {
    final surah = _surah;
    if (surah == null) return;
    _prefs.saveLastPlayed(
      surah.number,
      _player.currentIndex ?? 0,
      _player.position,
    );
  }

  Future<void> stop() async {
    cancelSleepTimer();
    _saveTimer?.cancel();
    _saveTimer = null;
    saveNow();
    await _player.stop();
    _loadedKey = null;
  }

  /// The app owns one player for its whole life, so this is only for tests.
  Future<void> dispose() async {
    _sleepTimer?.cancel();
    _saveTimer?.cancel();
    await _player.dispose();
  }

  static String reciterLabel(String edition) => _reciterLabel(edition);

  static String _reciterLabel(String edition) {
    final known = reciterLabels[edition];
    if (known != null) return known;
    return edition.split('.').last;
  }
}

/// Display names for the audio editions, used in the notification.
/// Keep in step with the ReciterName enum in lib/enum/reciter_list_enum.dart.
const Map<String, String> reciterLabels = {
  'ar.alafasy': 'Mishary Alafasy',
  'ar.abdulbasitmurattal': 'Abdul Basit (Murattal)',
  'ar.abdurrahmaansudais': 'Abdurrahmaan As-Sudais',
  'ar.abdullahbasfar': 'Abdullah Basfar',
  'ar.abdulsamad': 'Abdul Samad',
  'ar.shaatree': 'Abu Bakr Ash-Shaatree',
  'ar.ahmedajamy': 'Ahmed ibn Ali al-Ajamy',
  'ar.hanirifai': 'Hani Rifai',
  'ar.husary': 'Husary',
  'ar.husarymujawwad': 'Husary (Mujawwad)',
  'ar.hudhaify': 'Hudhaify',
  'ar.ibrahimakhbar': 'Ibrahim Akhdar',
  'ar.mahermuaiqly': 'Maher Al Muaiqly',
  'ar.minshawi': 'Minshawi',
  'ar.minshawimujawwad': 'Minshawy (Mujawwad)',
  'ar.muhammadayyoub': 'Muhammad Ayyoub',
  'ar.muhammadjibreel': 'Muhammad Jibreel',
  'ar.saoodshuraym': 'Saood Ash-Shuraym',
  'ar.parhizgar': 'Parhizgar',
  'ar.aymanswoaid': 'Ayman Sowaid',
  'en.walk': 'Ibrahim Walk (English)',
  'fa.hedayatfarfooladvand': 'Fooladvand (Persian)',
  'zh.chinese': 'Chinese',
  'fr.leclerc': 'Youssouf Leclerc (French)',
  'ru.kuliev-audio': 'Elmir Kuliev (Russian)',
};
