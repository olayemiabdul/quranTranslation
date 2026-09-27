import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/theme_provider.dart';
import '../quran_byPage/quran_pages.dart';
import 'ayah_actions_sheet.dart';
import 'ayah_page.dart';
import 'quran_content.dart';
import 'reader_prefs.dart';
import 'reader_theme.dart';
import 'surah_class.dart';

/// Easy Read — the flowing-text Quran reader.
///
/// The companion to the Madinah Mushaf: same 604 pages, but rendered with
/// the app's own font at whatever size the reader chooses, with optional
/// translation under each ayah, tap-to-act on any ayah, bookmarks, recitation
/// and a remembered place.
class OrganizedAyahViewScreen extends StatefulWidget {
  final List<Surah> surahs;

  /// 1-based Mushaf page (1..604). Pass 0 or null to resume where the
  /// reader left off.
  final int? initialPage;

  const OrganizedAyahViewScreen({
    super.key,
    required this.surahs,
    this.initialPage,
  });

  @override
  State<OrganizedAyahViewScreen> createState() => _OrganizedAyahViewScreenState();
}

class _OrganizedAyahViewScreenState extends State<OrganizedAyahViewScreen> {
  static const int totalPages = 604;

  final _prefs = ReaderPrefs.instance;
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<void>? _completeSub;

  late final PageController _controller;
  List<QuranPage> _pages = const [];
  int _page = 1;
  bool _ready = false;

  Ayah? _playing;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _completeSub = _player.onPlayerComplete.listen((_) => _playNext());
    _boot();
  }

  @override
  void dispose() {
    _completeSub?.cancel();
    _player.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    await _prefs.load();
    final pages = buildQuranPages(widget.surahs, totalPages: totalPages);
    final start = (widget.initialPage != null && widget.initialPage! > 0)
        ? widget.initialPage!.clamp(1, totalPages)
        : _prefs.lastPage.clamp(1, totalPages);

    if (!mounted) return;
    setState(() {
      _pages = pages;
      _page = start;
      _ready = true;
    });
    // The controller is attached only after the PageView is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) _controller.jumpToPage(start - 1);
    });
  }

  void _onPageChanged(int index) {
    final page = index + 1;
    setState(() => _page = page);
    _prefs.setLastPage(page);
  }

  void _goToPage(int page) {
    final target = page.clamp(1, totalPages);
    if (_controller.hasClients) {
      _controller.jumpToPage(target - 1);
    } else {
      setState(() => _page = target);
    }
  }

  QuranPage get _current => _pages.isEmpty
      ? const QuranPage(pageNumber: 1, contents: [])
      : _pages[_page - 1];

  Surah? _surahByNumber(int n) {
    for (final s in widget.surahs) {
      if (s.number == n) return s;
    }
    return null;
  }

  Ayah? _findAyah(int surahNumber, int ayahInSurah) {
    final surah = _surahByNumber(surahNumber);
    if (surah == null) return null;
    for (final a in surah.ayahs) {
      if (a.numberInSurah == ayahInSurah) return a;
    }
    return null;
  }

  // ------------------------------------------------------------ recitation
  /// Reciters the CDN does not publish at 128 kbps (it 404s there).
  static const _bitrates = <String, int>{
    'ar.abdulbasitmurattal': 192,
    'ar.abdurrahmaansudais': 192,
    'ar.abdulsamad': 64,
    'en.walk': 192,
    'fa.hedayatfarfooladvand': 40,
    'ur.khan': 64,
  };

  Future<void> _play(Ayah ayah) async {
    setState(() => _playing = ayah);
    final page = ayah.page;
    if (page != _page) _goToPage(page);

    final bitrate = _bitrates[_prefs.reciter] ?? 128;
    final url =
        'https://cdn.islamic.network/quran/audio/$bitrate/${_prefs.reciter}/${ayah.number}.mp3';
    try {
      await _player.stop();
      await _player.play(UrlSource(url));
    } catch (_) {
      if (!mounted) return;
      setState(() => _playing = null);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Recitation needs an internet connection.'),
      ));
    }
  }

  void _playNext() {
    final cur = _playing;
    if (cur == null) return;
    final surah = _surahByNumber(cur.surahNumber);
    if (surah == null) return _stop();

    final idx = surah.ayahs.indexWhere((a) => a.number == cur.number);
    if (idx >= 0 && idx + 1 < surah.ayahs.length) {
      _play(surah.ayahs[idx + 1]);
      return;
    }
    final next = _surahByNumber(cur.surahNumber + 1);
    if (next != null && next.ayahs.isNotEmpty) {
      _play(next.ayahs.first);
    } else {
      _stop();
    }
  }

  void _stop() {
    _player.stop();
    if (mounted) setState(() => _playing = null);
  }

  // ------------------------------------------------------------- ayah tap
  Future<void> _onAyahTap(Ayah ayah, PageContent content) async {
    final action = await showModalBottomSheet<AyahAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ReaderTheme.read(context).paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AyahActionsSheet(
        ayah: ayah,
        surahNameArabic: content.surahName,
        surahNameEnglish: content.englishName,
      ),
    );
    if (!mounted) return;
    setState(() {}); // a bookmark may have changed
    if (action == AyahAction.playFromHere) _play(ayah);
  }

  // ----------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final t = ReaderTheme.of(context);

    return AnimatedBuilder(
      animation: _prefs,
      builder: (context, _) => Scaffold(
        backgroundColor: t.paper,
        appBar: _appBar(t),
        body: !_ready
            ? const Center(child: CircularProgressIndicator(color: ReaderTheme.green))
            : Column(
                children: [
                  _runningHead(t),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      reverse: true, // right to left, like the printed Mushaf
                      itemCount: totalPages,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) => AyahPageView(
                        key: ValueKey('easy_read_page_${index + 1}'),
                        page: _pages[index],
                        playingAyahNumber: _playing?.number,
                        onAyahTap: _onAyahTap,
                      ),
                    ),
                  ),
                  if (_playing != null) _playerBar(t),
                  _bottomBar(t),
                ],
              ),
      ),
    );
  }

  PreferredSizeWidget _appBar(ReaderTheme t) {
    final themeNotifier = context.read<ThemeNotifier>();
    return AppBar(
      backgroundColor: ReaderTheme.green,
      foregroundColor: Colors.white,
      title: Text('Easy Read  ·  Page $_page',
          style: const TextStyle(fontSize: 17)),
      actions: [
        IconButton(
          tooltip: 'Go to page',
          icon: const Icon(Icons.search),
          onPressed: _askPage,
        ),
        IconButton(
          tooltip: 'See this page in the Mushaf',
          icon: const Icon(Icons.auto_stories_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => QuranByPages(initialPage: _page)),
          ),
        ),
        IconButton(
          tooltip: t.dark ? 'Day mode' : 'Night mode',
          icon: Icon(t.dark ? Icons.light_mode : Icons.dark_mode),
          onPressed: themeNotifier.toggleTheme,
        ),
      ],
    );
  }

  /// Surah, hizb and juz, the way the printed page carries them.
  Widget _runningHead(ReaderTheme t) {
    final c = _current.primary;
    return Container(
      width: double.infinity,
      color: t.headerBand,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(c?.englishName ?? '',
              style: TextStyle(color: t.inkSoft, fontSize: 13)),
          Text(c?.surahName ?? '',
              style: TextStyle(
                  fontFamily: 'Kitab-Bold', fontSize: 17, color: t.ink)),
          Text('Juz ${_current.juz}',
              style: TextStyle(color: t.inkSoft, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _playerBar(ReaderTheme t) => Container(
        color: ReaderTheme.green,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.graphic_eq, color: ReaderTheme.goldSoft),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Reciting ${_playing!.surahNumber}:${_playing!.numberInSurah}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              tooltip: 'Stop',
              icon: const Icon(Icons.stop_circle_outlined, color: Colors.white),
              onPressed: _stop,
            ),
          ],
        ),
      );

  Widget _bottomBar(ReaderTheme t) => Container(
        color: ReaderTheme.green,
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _barButton(Icons.menu_book, 'Surahs', _openSurahIndex),
              _barButton(Icons.grid_view, 'Juz', _openJuzIndex),
              _barButton(Icons.bookmarks_outlined, 'Saved', _openBookmarks),
              _barButton(Icons.play_circle_outline, 'Listen', () {
                final first = _current.primary?.ayahs.first;
                if (first != null) _play(first);
              }),
              _barButton(Icons.text_fields, 'Display', _openDisplay),
            ],
          ),
        ),
      );

  Widget _barButton(IconData icon, String label, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 11)),
          ]),
        ),
      );

  // ------------------------------------------------------------- navigation
  void _openSurahIndex() => _sheet(
        title: 'Surahs',
        itemCount: widget.surahs.length,
        builder: (i) {
          final s = widget.surahs[i];
          final page = s.ayahs.isEmpty ? 1 : s.ayahs.first.page;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: ReaderTheme.green,
              child: Text('${s.number}',
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
            title: Text(s.englishName),
            subtitle: Text(
                '${s.isMakki ? "Makki" : "Madani"} · ${s.ayahs.length} ayahs · page $page'),
            trailing: Text(s.name,
                style: const TextStyle(fontFamily: 'Kitab-Bold', fontSize: 19)),
            onTap: () {
              Navigator.pop(context);
              _goToPage(page);
            },
          );
        },
      );

  static const _juzStart = [
    1, 22, 42, 62, 82, 102, 121, 142, 162, 182, 201, 222, 242, 262, 282,
    302, 322, 342, 362, 382, 402, 422, 442, 462, 482, 502, 522, 542, 562, 582,
  ];

  void _openJuzIndex() => _sheet(
        title: 'Juz',
        itemCount: 30,
        builder: (i) => ListTile(
          leading: CircleAvatar(
            backgroundColor: ReaderTheme.green,
            child: Text('${i + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
          title: Text('Juz ${i + 1}'),
          subtitle: Text('Starts on page ${_juzStart[i]}'),
          onTap: () {
            Navigator.pop(context);
            _goToPage(_juzStart[i]);
          },
        ),
      );

  void _openBookmarks() {
    final keys = _prefs.bookmarks.toList()
      ..sort((a, b) {
        final pa = a.split(':').map(int.parse).toList();
        final pb = b.split(':').map(int.parse).toList();
        return pa[0] == pb[0] ? pa[1].compareTo(pb[1]) : pa[0].compareTo(pb[0]);
      });

    if (keys.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Tap any ayah, then the bookmark icon, to save it here.'),
      ));
      return;
    }

    _sheet(
      title: 'Saved ayahs',
      itemCount: keys.length,
      builder: (i) {
        final parts = keys[i].split(':').map(int.parse).toList();
        final surah = _surahByNumber(parts[0]);
        // final, so it still promotes to non-null inside the callbacks below
        final ayah = _findAyah(parts[0], parts[1]);
        return ListTile(
          leading: const Icon(Icons.bookmark, color: ReaderTheme.gold),
          title: Text('${surah?.englishName ?? "Surah ${parts[0]}"} ${keys[i]}'),
          subtitle: ayah == null ? null : Text('Page ${ayah.page}'),
          trailing: IconButton(
            tooltip: 'Remove',
            icon: const Icon(Icons.close),
            onPressed: () async {
              await _prefs.toggleBookmark(keys[i]);
              if (mounted) Navigator.pop(context);
            },
          ),
          onTap: () {
            Navigator.pop(context);
            if (ayah != null) _goToPage(ayah.page);
          },
        );
      },
    );
  }

  void _openDisplay() {
    final t = ReaderTheme.read(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: t.paper,
      isScrollControlled: true,
      builder: (ctx) => AnimatedBuilder(
        animation: _prefs,
        builder: (ctx, _) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Display',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: t.ink)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.text_fields, size: 18),
                  Expanded(
                    child: Slider(
                      value: _prefs.fontSize,
                      min: 16,
                      max: 44,
                      divisions: 14,
                      activeColor: ReaderTheme.green,
                      label: _prefs.fontSize.round().toString(),
                      onChanged: _prefs.setFontSize,
                    ),
                  ),
                  const Icon(Icons.text_fields, size: 28),
                ]),
                Row(children: [
                  const Icon(Icons.format_line_spacing, size: 18),
                  Expanded(
                    child: Slider(
                      value: _prefs.lineHeight,
                      min: 1.6,
                      max: 3.0,
                      divisions: 7,
                      activeColor: ReaderTheme.green,
                      label: _prefs.lineHeight.toStringAsFixed(1),
                      onChanged: _prefs.setLineHeight,
                    ),
                  ),
                  const Icon(Icons.format_line_spacing, size: 28),
                ]),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Show translation'),
                  subtitle: const Text('One ayah at a time, with meaning below'),
                  value: _prefs.showTranslation,
                  activeThumbColor: ReaderTheme.green,
                  onChanged: _prefs.setShowTranslation,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Go to page'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(ctx);
                    _askPage();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _askPage() async {
    final controller = TextEditingController();
    final n = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Go to page'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '1 to 604'),
          onSubmitted: (v) {
            final p = int.tryParse(v);
            if (p != null && p >= 1 && p <= totalPages) Navigator.pop(ctx, p);
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final p = int.tryParse(controller.text);
              if (p != null && p >= 1 && p <= totalPages) Navigator.pop(ctx, p);
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
    if (n != null) _goToPage(n);
  }

  void _sheet({
    required String title,
    required int itemCount,
    required Widget Function(int) builder,
  }) {
    final t = ReaderTheme.read(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: t.paper,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        builder: (_, scroll) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title,
                  style: TextStyle(fontSize: 19, color: t.ink)),
            ),
            Expanded(
              child: ListView.builder(
                controller: scroll,
                itemCount: itemCount,
                itemBuilder: (_, i) => builder(i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
