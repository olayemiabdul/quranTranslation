import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../quran_ayah/reader_theme.dart';
import 'audio_catalog.dart';
import 'audio_prefs.dart';
import 'quran_audio_service.dart';
import 'reciter_picker.dart';

/// The recitation player.
///
/// Rewritten from the old page, whose most visible fault was a progress
/// slider hard-coded to `max: 3600` — one hour — while the audio it played
/// was a single ayah of a minute or two. The handle barely moved, the
/// position meant nothing, and any recitation longer than an hour threw.
/// It also had no buffering state, so tapping play looked like nothing
/// happening, and an empty `catch` swallowed every error in silence.
class SurahAudioPage extends StatefulWidget {
  final SurahMeta surah;

  /// Ayah to open on, zero-based. Used by "continue listening".
  final int startIndex;
  final Duration startPosition;

  const SurahAudioPage({
    super.key,
    required this.surah,
    this.startIndex = 0,
    this.startPosition = Duration.zero,
  });

  @override
  State<SurahAudioPage> createState() => _SurahAudioPageState();
}

class _SurahAudioPageState extends State<SurahAudioPage> {
  final _audio = QuranAudioService.instance;
  final _prefs = AudioPrefs.instance;
  String? _error;

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void dispose() {
    // Playback deliberately continues: leaving this screen should not stop
    // the recitation. We only stop tracking it.
    _audio.saveNow();
    super.dispose();
  }

  /// What is actually loaded: the player carries on into the next surah by
  /// itself, and this page follows it.
  SurahMeta get _surah => _audio.currentSurah ?? widget.surah;

  Future<void> _open() async {
    try {
      await _audio.loadSurah(
        widget.surah,
        startIndex: widget.startIndex,
        startPosition: widget.startPosition,
        // Reopening what is already loaded (from the mini bar) should not
        // un-pause it.
        autoPlay: _audio.currentSurah?.number != widget.surah.number,
      );
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        setState(
          () => _error =
              'Could not start the recitation. Check your connection and try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ReaderTheme.of(context);

    return AnimatedBuilder(
      animation: _prefs,
      // Rebuilt on every ayah change, which is also when a new surah loads.
      builder: (context, _) => StreamBuilder<int?>(
        stream: _audio.currentIndexStream,
        builder: (context, _) => Scaffold(
          backgroundColor: t.paper,
          appBar: AppBar(
            backgroundColor: ReaderTheme.green,
            foregroundColor: Colors.white,
            title: Text(_surah.englishName),
            actions: [
              IconButton(
                tooltip: 'Jump to an ayah',
                icon: const Icon(Icons.list),
                onPressed: _openAyahList,
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                if (_error != null) _errorBar(t),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                    child: Column(
                      children: [
                        _surahCard(t),
                        const SizedBox(height: 24),
                        _nowPlaying(t),
                        const SizedBox(height: 8),
                        _progress(t),
                        const SizedBox(height: 8),
                        _transport(t),
                        const SizedBox(height: 20),
                        _options(t),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorBar(ReaderTheme t) => Container(
    width: double.infinity,
    color: const Color(0xFFFFF1CC),
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: Color(0xFF8A6100)),
        const SizedBox(width: 10),
        Expanded(child: Text(_error!)),
        TextButton(
          onPressed: () {
            setState(() => _error = null);
            _open();
          },
          child: const Text('Retry'),
        ),
      ],
    ),
  );

  /// Sized by the screen, not the fixed 200x350 box the old page used,
  /// which overflowed on small phones.
  Widget _surahCard(ReaderTheme t) {
    final width = MediaQuery.sizeOf(context).width;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: width * 0.42, maxWidth: 420),
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      decoration: BoxDecoration(
        color: ReaderTheme.green,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ReaderTheme.gold, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${_surah.number} · ${_surah.englishName}',
            style: const TextStyle(color: ReaderTheme.goldSoft, fontSize: 14),
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _surah.name,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'Kitab-Bold',
                color: Colors.white,
                fontSize: 42,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${_surah.isMakki ? "Makki" : "Madani"} · ${_surah.numberOfAyahs} ayahs',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _nowPlaying(ReaderTheme t) => StreamBuilder<int?>(
    stream: _audio.currentIndexStream,
    builder: (context, snap) {
      final index = snap.data ?? widget.startIndex;
      return Text(
        'Ayah ${index + 1} of ${_surah.numberOfAyahs}',
        style: TextStyle(color: t.inkSoft, fontSize: 14),
      );
    },
  );

  /// A real slider: bound to the actual duration of what is playing, with
  /// the buffered amount shown behind it.
  Widget _progress(ReaderTheme t) => StreamBuilder<Duration?>(
    stream: _audio.durationStream,
    builder: (context, durationSnap) {
      final duration = durationSnap.data ?? Duration.zero;
      return StreamBuilder<Duration>(
        stream: _audio.positionStream,
        builder: (context, positionSnap) {
          final position = positionSnap.data ?? Duration.zero;
          final max = duration.inMilliseconds.toDouble();
          final value = position.inMilliseconds
              .clamp(0, duration.inMilliseconds)
              .toDouble();

          return Column(
            children: [
              StreamBuilder<Duration>(
                stream: _audio.bufferedPositionStream,
                builder: (context, bufferedSnap) {
                  final buffered = bufferedSnap.data ?? Duration.zero;
                  return SizedBox(
                    height: 4,
                    child: LinearProgressIndicator(
                      value: max <= 0
                          ? 0
                          : (buffered.inMilliseconds / max).clamp(0.0, 1.0),
                      backgroundColor: t.divider,
                      color: ReaderTheme.goldSoft,
                    ),
                  );
                },
              ),
              Slider(
                value: max <= 0 ? 0 : value,
                min: 0,
                // The real length of this ayah, not a guess.
                max: max <= 0 ? 1 : max,
                activeColor: ReaderTheme.green,
                // Seeking should not force playback to start, which the
                // old slider did by calling resume() on every drag.
                onChanged: max <= 0
                    ? null
                    : (v) => _audio.seek(Duration(milliseconds: v.round())),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _format(position),
                      style: TextStyle(color: t.inkSoft, fontSize: 12),
                    ),
                    Text(
                      _format(duration - position),
                      style: TextStyle(color: t.inkSoft, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    },
  );

  Widget _transport(ReaderTheme t) => StreamBuilder<PlayerState>(
    stream: _audio.playerStateStream,
    builder: (context, snap) {
      final state = snap.data;
      final processing = state?.processingState;
      final playing = state?.playing ?? false;
      final busy =
          processing == ProcessingState.loading ||
          processing == ProcessingState.buffering;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: 'Previous ayah',
            iconSize: 38,
            color: t.ink,
            icon: const Icon(Icons.skip_previous),
            onPressed: _audio.previousAyah,
          ),
          const SizedBox(width: 12),
          // Buffering is shown, not hidden. Tapping play on a slow
          // connection used to look like nothing had happened.
          SizedBox(
            width: 72,
            height: 72,
            child: busy
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: CircularProgressIndicator(
                      color: ReaderTheme.green,
                      strokeWidth: 3,
                    ),
                  )
                : Material(
                    color: ReaderTheme.green,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _audio.togglePlay,
                      child: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Next ayah',
            iconSize: 38,
            color: t.ink,
            icon: const Icon(Icons.skip_next),
            onPressed: _audio.nextAyah,
          ),
        ],
      );
    },
  );

  Widget _options(ReaderTheme t) => Column(
    children: [
      _optionTile(
        t,
        icon: Icons.record_voice_over,
        label: 'Reciter',
        value: reciterLabels[_prefs.reciter] ?? _prefs.reciter,
        onTap: () async {
          final picked = await showReciterPicker(context, _prefs.reciter);
          if (picked == null || picked == _prefs.reciter) return;
          await _prefs.setReciter(picked);
          // Keeps your place instead of restarting the surah.
          await _audio.reloadForCurrentReciter();
        },
      ),
      _optionTile(
        t,
        icon: Icons.repeat,
        label: 'Repeat',
        value: switch (_prefs.repeat) {
          AudioRepeat.off => 'Off',
          AudioRepeat.ayah => 'This ayah',
          AudioRepeat.surah => 'Whole surah',
        },
        onTap: () async {
          const order = [AudioRepeat.off, AudioRepeat.ayah, AudioRepeat.surah];
          final next = order[(order.indexOf(_prefs.repeat) + 1) % order.length];
          await _audio.setRepeat(next);
        },
      ),
      _optionTile(
        t,
        icon: Icons.speed,
        label: 'Speed',
        value: '${_prefs.speed.toStringAsFixed(2)}x',
        onTap: () async {
          const speeds = [0.75, 1.0, 1.25, 1.5];
          final i = speeds.indexWhere((s) => (s - _prefs.speed).abs() < 0.01);
          await _audio.setSpeed(speeds[(i + 1) % speeds.length]);
        },
      ),
      _optionTile(
        t,
        icon: Icons.bedtime_outlined,
        label: 'Sleep timer',
        value: _sleepLabel(),
        onTap: _openSleepTimer,
      ),
      _optionTile(
        t,
        icon: Icons.network_cell,
        label: 'Audio quality',
        value:
            '${_prefs.dataSaver ? 'Data saver' : 'High'} (${AudioCatalog.bitrateFor(_prefs.reciter, dataSaver: _prefs.dataSaver)} kbps)',
        onTap: () async {
          await _prefs.setBitrate(_prefs.bitrate == 128 ? 64 : 128);
          await _audio.reloadForCurrentReciter();
        },
      ),
    ],
  );

  Widget _optionTile(
    ReaderTheme t, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: ReaderTheme.green, size: 20),
    title: Text(label, style: TextStyle(fontSize: 14, color: t.ink)),
    trailing: Text(value, style: TextStyle(fontSize: 13, color: t.inkSoft)),
    onTap: onTap,
  );

  String _sleepLabel() {
    final left = _audio.sleepRemaining;
    if (left == null) return 'Off';
    final minutes = left.inMinutes + 1;
    return '$minutes min left';
  }

  Future<void> _openSleepTimer() async {
    final t = ReaderTheme.read(context);
    final minutes = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: t.paper,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Stop playing after',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
            for (final m in [10, 15, 30, 45, 60])
              ListTile(
                title: Text('$m minutes'),
                onTap: () => Navigator.pop(ctx, m),
              ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Turn off'),
              onTap: () => Navigator.pop(ctx, 0),
            ),
          ],
        ),
      ),
    );

    if (minutes == null) return;
    if (minutes == 0) {
      _audio.cancelSleepTimer();
    } else {
      _audio.startSleepTimer(Duration(minutes: minutes));
    }
    if (mounted) setState(() {});
  }

  void _openAyahList() {
    final t = ReaderTheme.read(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: t.paper,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        builder: (_, scroll) => StreamBuilder<int?>(
          stream: _audio.currentIndexStream,
          builder: (context, snap) {
            final current = snap.data ?? 0;
            return ListView.builder(
              controller: scroll,
              itemCount: _surah.numberOfAyahs,
              itemBuilder: (context, i) => ListTile(
                selected: i == current,
                selectedTileColor: t.highlight,
                leading: CircleAvatar(
                  radius: 15,
                  backgroundColor: i == current
                      ? ReaderTheme.gold
                      : ReaderTheme.green,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                title: Text('Ayah ${i + 1}'),
                onTap: () {
                  Navigator.pop(context);
                  _audio.goToAyah(i);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  static String _format(Duration d) {
    if (d.isNegative) d = Duration.zero;
    String two(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return hours > 0
        ? '$hours:${two(minutes)}:${two(seconds)}'
        : '${two(minutes)}:${two(seconds)}';
  }
}
