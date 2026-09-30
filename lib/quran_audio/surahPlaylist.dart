import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../quran_ayah/reader_theme.dart';
import 'audio_catalog.dart';
import 'audio_player.dart';
import 'audio_prefs.dart';
import 'quran_audio_service.dart';
import 'reciter_picker.dart';

/// The recitation index.
///
/// The old version downloaded the entire Quran for the chosen reciter —
/// every ayah, its text and its audio link, several megabytes — every time
/// this screen opened, with no cache, purely to list 114 surah names. And it
/// did it again on every reciter change. This fetches about 15 KB once.
class AudioSurahList extends StatefulWidget {
  const AudioSurahList({super.key});

  @override
  State<AudioSurahList> createState() => _AudioSurahListState();
}

class _AudioSurahListState extends State<AudioSurahList> {
  final _prefs = AudioPrefs.instance;
  final _audio = QuranAudioService.instance;
  final _searchController = TextEditingController();

  List<SurahMeta> _all = const [];
  List<SurahMeta> _shown = const [];
  LastPlayed? _lastPlayed;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    await _prefs.load();
    await _load();
  }

  Future<void> _load({bool refresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final surahs = await AudioCatalog.instance.load(forceRefresh: refresh);
      final last = await _prefs.lastPlayed();
      if (!mounted) return;
      setState(() {
        _all = surahs;
        _shown = surahs;
        _lastPlayed = last;
        _loading = false;
      });
      _filter(_searchController.text);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error =
            'Could not load the surah list. Check your connection and try again.';
      });
    }
  }

  void _filter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _shown = q.isEmpty
          ? _all
          : _all.where((s) {
              return s.englishName.toLowerCase().contains(q) ||
                  s.englishNameTranslation.toLowerCase().contains(q) ||
                  s.name.contains(query.trim()) ||
                  s.number.toString() == q;
            }).toList();
    });
  }

  void _open(
    SurahMeta surah, {
    int index = 0,
    Duration position = Duration.zero,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurahAudioPage(
          surah: surah,
          startIndex: index,
          startPosition: position,
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ReaderTheme.of(context);

    return AnimatedBuilder(
      animation: _prefs,
      builder: (context, _) => Scaffold(
        backgroundColor: t.paper,
        appBar: AppBar(
          backgroundColor: ReaderTheme.green,
          foregroundColor: Colors.white,
          title: const Text('Listen'),
        ),
        body: _loading && _all.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: ReaderTheme.green),
              )
            : Column(
                children: [
                  _reciterBar(t),
                  if (_error != null) _errorBar(t),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _load(refresh: true),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: _shown.length + 2,
                        itemBuilder: (context, i) {
                          if (i == 0) return _searchField(t);
                          if (i == 1) return _continueCard(t);
                          return _surahTile(_shown[i - 2], t);
                        },
                      ),
                    ),
                  ),
                  _miniPlayer(t),
                ],
              ),
      ),
    );
  }

  Widget _reciterBar(ReaderTheme t) => Material(
    color: t.headerBand,
    child: InkWell(
      onTap: () async {
        final picked = await showReciterPicker(context, _prefs.reciter);
        if (picked == null || picked == _prefs.reciter) return;
        await _prefs.setReciter(picked);
        // Nothing to re-download: URLs are built from the edition name.
        await _audio.reloadForCurrentReciter();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.record_voice_over,
              color: ReaderTheme.green,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reciter',
                    style: TextStyle(fontSize: 11, color: t.inkSoft),
                  ),
                  Text(
                    reciterLabels[_prefs.reciter] ?? _prefs.reciter,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: t.ink,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Change',
              style: TextStyle(
                color: ReaderTheme.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );

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
          onPressed: () => _load(refresh: true),
          child: const Text('Retry'),
        ),
      ],
    ),
  );

  Widget _searchField(ReaderTheme t) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
    child: TextField(
      controller: _searchController,
      onChanged: _filter,
      style: TextStyle(color: t.ink),
      decoration: InputDecoration(
        hintText: 'Find a surah',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: t.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: t.divider),
        ),
      ),
    ),
  );

  Widget _continueCard(ReaderTheme t) {
    final last = _lastPlayed;
    if (last == null) return const SizedBox.shrink();
    final surah = AudioCatalog.instance.byNumber(last.surahNumber);
    if (surah == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Material(
        color: ReaderTheme.green,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () =>
              _open(surah, index: last.ayahIndex, position: last.position),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.play_circle_outline,
                  color: ReaderTheme.goldSoft,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Continue listening',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${surah.englishName} · ayah ${last.ayahIndex + 1}',
                        style: const TextStyle(color: ReaderTheme.goldSoft),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _surahTile(SurahMeta s, ReaderTheme t) => Card(
    color: t.card,
    elevation: 0,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: t.divider),
    ),
    child: ListTile(
      onTap: () => _open(s),
      leading: CircleAvatar(
        backgroundColor: ReaderTheme.green,
        child: Text(
          '${s.number}',
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
      title: Text(
        s.englishName,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: t.ink,
        ),
      ),
      subtitle: Text(
        '${s.englishNameTranslation} · ${s.isMakki ? "Makki" : "Madani"} · ${s.numberOfAyahs} ayahs',
        style: TextStyle(fontSize: 12, color: t.inkSoft),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            s.name,
            style: TextStyle(
              fontFamily: 'Kitab-Bold',
              fontSize: 18,
              color: t.ink,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.play_circle_outline, color: ReaderTheme.gold),
        ],
      ),
    ),
  );

  /// A bar showing what is playing, so leaving the player does not mean
  /// losing track of it.
  Widget _miniPlayer(ReaderTheme t) => StreamBuilder<PlayerState>(
    stream: _audio.playerStateStream,
    builder: (context, snap) {
      final surah = _audio.currentSurah;
      final state = snap.data;
      if (surah == null || state == null) return const SizedBox.shrink();
      if (state.processingState == ProcessingState.idle) {
        return const SizedBox.shrink();
      }

      return Material(
        color: ReaderTheme.greenDeep,
        child: InkWell(
          onTap: () => _open(surah, index: _audio.currentIndex),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.graphic_eq, color: ReaderTheme.goldSoft),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StreamBuilder<int?>(
                      stream: _audio.currentIndexStream,
                      builder: (context, indexSnap) => Text(
                        '${surah.englishName} · ayah ${(indexSnap.data ?? 0) + 1}',
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      state.playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: _audio.togglePlay,
                  ),
                  IconButton(
                    tooltip: 'Stop',
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () async {
                      await _audio.stop();
                      if (mounted) setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
