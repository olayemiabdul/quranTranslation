import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mushaf/ayah_sheet.dart';
import '../mushaf/mushaf_frame.dart';

// ------------------------------------------------------------------ fonts
/// Start this in main() without awaiting. The first run unpacks 604 page
/// fonts to disk; later launches only load them, which is quick.
final ValueNotifier<double> qcfFontProgress = ValueNotifier(0);
Future<void>? _qcfBoot;
Future<void> bootQcfFonts() => _qcfBoot ??= QcfFontLoader.setupFontsAtStartup(
      onProgress: (p) => qcfFontProgress.value = p,
    ).then((_) => qcfFontProgress.value = 1);

// ------------------------------------------------------------------ screen
/// Same class name as before, so the home grid needs no change.
class QuranByPages extends StatefulWidget {
  final int? initialPage;
  const QuranByPages({super.key, this.initialPage});

  @override
  State<QuranByPages> createState() => _QuranByPagesState();
}

class _QuranByPagesState extends State<QuranByPages> {
  static const _kLastPage = 'mushaf_last_page';
  static const _kBookmarks = 'mushaf_bookmarks';
  static const _kReciter = 'mushaf_reciter';

  PageController? _controller;
  int _page = 1;
  bool _chrome = true; // app bars visible
  bool _dark = false;
  bool _tajweed = false;
  List<HighlightVerse> _highlights = [];
  Set<int> _bookmarks = {};

  // Listen-along recitation
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription? _doneSub;
  ({int surah, int ayah})? _playing;
  String _reciter = 'ar.alafasy';

  @override
  void initState() {
    super.initState();
    bootQcfFonts();
    _restore();
    _doneSub = _player.onPlayerComplete.listen((_) => _playNext());
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _doneSub?.cancel();
    _player.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    final p = await SharedPreferences.getInstance();
    final start = widget.initialPage ?? p.getInt(_kLastPage) ?? 1;
    setState(() {
      _page = start;
      _bookmarks = (p.getStringList(_kBookmarks) ?? []).map(int.parse).toSet();
      _reciter = p.getString(_kReciter) ?? 'ar.alafasy';
      _dark = p.getBool('mushaf_dark') ?? false;
      _tajweed = p.getBool('mushaf_tajweed') ?? false;
      _controller = PageController(initialPage: start - 1);
    });
  }

  Future<void> _onPageChanged(int page) async {
    setState(() => _page = page);
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kLastPage, page);
  }

  void _goTo(int page) {
    _controller?.jumpToPage(page.clamp(1, 604) - 1);
  }

  // ------------------------------------------------ page metadata
  int get _surahOnPage => getPageData(_page).first['surah'] as int;
  int get _juzOnPage {
    final first = getPageData(_page).first;
    return getJuzNumber(first['surah'] as int, first['start'] as int);
  }

  // ------------------------------------------------ recitation
  Future<void> _playFrom(int surah, int ayah) async {
    setState(() {
      _playing = (surah: surah, ayah: ayah);
      final page = getPageNumber(surah, ayah);
      _highlights = [
        HighlightVerse(
            surah: surah,
            verseNumber: ayah,
            page: page,
            color: MushafColors.gold.withValues(alpha: 0.35)),
      ];
      if (page != _page) {
        _controller?.animateToPage(page - 1,
            duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
      }
    });
    try {
      final res = await http
          .get(Uri.parse('https://api.alquran.cloud/v1/ayah/$surah:$ayah/$_reciter'))
          .timeout(const Duration(seconds: 15));
      final url = json.decode(res.body)['data']['audio'] as String;
      await _player.play(UrlSource(url));
    } catch (_) {
      _stop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Recitation needs an internet connection.'),
        ));
      }
    }
  }

  void _playNext() {
    final cur = _playing;
    if (cur == null) return;
    if (cur.ayah < getVerseCount(cur.surah)) {
      _playFrom(cur.surah, cur.ayah + 1);
    } else if (cur.surah < 114) {
      _playFrom(cur.surah + 1, 1);
    } else {
      _stop();
    }
  }

  void _stop() {
    _player.stop();
    setState(() {
      _playing = null;
      _highlights = [];
    });
  }

  // ------------------------------------------------ ayah actions
  Future<void> _onLongPress(int surah, int ayah, LongPressStartDetails _) async {
    HapticFeedback.selectionClick();
    setState(() => _highlights = [
          HighlightVerse(
              surah: surah,
              verseNumber: ayah,
              page: _page,
              color: MushafColors.green.withValues(alpha: 0.18)),
        ]);
    final action = await showModalBottomSheet<AyahAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MushafColors.paper,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      // Sheets sit on light paper whatever the app theme.
      builder: (_) => Theme(
          data: ThemeData.light(), child: AyahSheet(surah: surah, ayah: ayah)),
    );
    if (!mounted) return;
    _reciter = (await SharedPreferences.getInstance()).getString(_kReciter) ?? _reciter;
    if (action == AyahAction.playFromHere) {
      _playFrom(surah, ayah);
    } else if (_playing == null) {
      setState(() => _highlights = []);
    }
  }

  Future<void> _toggleBookmark() async {
    setState(() {
      _bookmarks.contains(_page) ? _bookmarks.remove(_page) : _bookmarks.add(_page);
    });
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_kBookmarks, _bookmarks.map((e) => '$e').toList());
  }

  // ------------------------------------------------ build
  @override
  Widget build(BuildContext context) {
    final bg = _dark ? const Color(0xFF0E1511) : const Color(0xFFF3EEDC);
    return Scaffold(
      backgroundColor: bg,
      body: ValueListenableBuilder<double>(
        valueListenable: qcfFontProgress,
        builder: (context, progress, _) {
          if (progress < 1 || _controller == null) return _preparing(progress);
          return SafeArea(
            child: Column(
              children: [
                _topBar(),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _chrome = !_chrome),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: MushafFrame(
                        dark: _dark,
                        child: Column(
                          children: [
                            _pageHeader(),
                            Expanded(
                              child: QuranPageView(
                                pageController: _controller!,
                                highlights: _highlights,
                                isDarkMode: _dark,
                                isTajweed: _tajweed,
                                onPageChanged: _onPageChanged,
                                onLongPress: _onLongPress,
                                ayahStyle: TextStyle(
                                    color: _dark ? const Color(0xFFEDE6D1) : MushafColors.ink),
                              ),
                            ),
                            PageMedallion(toArabicDigits(_page)),
                            const SizedBox(height: 2),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_playing != null) _playerBar(),
                _bottomBar(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _preparing(double p) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Preparing the Mushaf',
                style: TextStyle(fontSize: 20, color: MushafColors.greenDeep)),
            const SizedBox(height: 6),
            const Text('This only takes a moment the first time.',
                style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: p == 0 ? null : p,
              color: MushafColors.green,
              backgroundColor: MushafColors.goldSoft,
            ),
          ]),
        ),
      );

  Widget _pageHeader() {
    final style = TextStyle(
      fontFamily: 'UthmanTN2',
      fontSize: 15,
      color: _dark ? MushafColors.goldSoft : MushafColors.greenDeep,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 2, 6, 4),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('سورة ${getSurahNameArabic(_surahOnPage)}', style: style),
            Text(getCurrentHizbTextForPage(_page), style: style.copyWith(fontSize: 12)),
            Text('الجزء ${juzNamesArabic[_juzOnPage - 1]}', style: style),
          ],
        ),
      ),
    );
  }

  Widget _topBar() => AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: !_chrome
            ? const SizedBox(width: double.infinity)
            : Container(
                color: MushafColors.green,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(children: [
                  const BackButton(color: Colors.white),
                  Expanded(
                    child: Text(
                      '${getSurahNameEnglish(_surahOnPage)}  ·  Juz $_juzOnPage  ·  Page $_page',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: _bookmarks.contains(_page) ? 'Remove bookmark' : 'Bookmark page',
                    color: MushafColors.goldSoft,
                    icon: Icon(_bookmarks.contains(_page) ? Icons.bookmark : Icons.bookmark_border),
                    onPressed: _toggleBookmark,
                  ),
                ]),
              ),
      );

  Widget _playerBar() => Container(
        color: MushafColors.greenDeep,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(children: [
          const Icon(Icons.graphic_eq, color: MushafColors.goldSoft),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Reciting ${getSurahNameEnglish(_playing!.surah)} ${_playing!.surah}:${_playing!.ayah}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            tooltip: 'Stop recitation',
            icon: const Icon(Icons.stop_circle_outlined, color: Colors.white),
            onPressed: _stop,
          ),
        ]),
      );

  Widget _bottomBar() => AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: !_chrome
            ? const SizedBox(width: double.infinity)
            : Container(
                color: MushafColors.green,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _barButton(Icons.menu_book, 'Surahs', _openSurahIndex),
                    _barButton(Icons.grid_view, 'Juz', _openJuzIndex),
                    _barButton(Icons.bookmarks_outlined, 'Saved', _openBookmarks),
                    _barButton(Icons.play_circle_outline, 'Listen', () {
                      final first = getPageData(_page).first;
                      _playFrom(first['surah'] as int, first['start'] as int);
                    }),
                    _barButton(Icons.tune, 'Display', _openDisplay),
                  ],
                ),
              ),
      );

  Widget _barButton(IconData icon, String label, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: Colors.white),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ]),
        ),
      );

  // ------------------------------------------------ navigation sheets
  void _openSurahIndex() => _sheet(
        title: 'Surahs',
        itemCount: 114,
        builder: (i) {
          final s = i + 1;
          final page = getPageNumber(s, 1);
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: MushafColors.green,
              child: Text('$s', style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
            title: Text(getSurahNameEnglish(s)),
            subtitle: Text('${getPlaceOfRevelation(s)} · ${getVerseCount(s)} ayahs · page $page'),
            trailing: Text(getSurahNameArabic(s),
                style: const TextStyle(fontFamily: 'UthmanTN2', fontSize: 20)),
            onTap: () {
              Navigator.pop(context);
              _goTo(page);
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
          title: Text('Juz ${i + 1}'),
          subtitle: Text('Starts on page ${_juzStart[i]}'),
          trailing: Text('الجزء ${juzNamesArabic[i]}',
              style: const TextStyle(fontFamily: 'UthmanTN2', fontSize: 18)),
          onTap: () {
            Navigator.pop(context);
            _goTo(_juzStart[i]);
          },
        ),
      );

  void _openBookmarks() {
    final list = _bookmarks.toList()..sort();
    if (list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Tap the bookmark icon at the top to save a page.'),
      ));
      return;
    }
    _sheet(
      title: 'Saved pages',
      itemCount: list.length,
      builder: (i) {
        final pg = list[i];
        final s = getPageData(pg).first['surah'] as int;
        return ListTile(
          leading: const Icon(Icons.bookmark, color: MushafColors.gold),
          title: Text('Page $pg'),
          subtitle: Text(getSurahNameEnglish(s)),
          onTap: () {
            Navigator.pop(context);
            _goTo(pg);
          },
        );
      },
    );
  }

  void _openDisplay() {
    showModalBottomSheet(
      context: context,
      backgroundColor: MushafColors.paper,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          Future<void> save(String k, bool v) async =>
              (await SharedPreferences.getInstance()).setBool(k, v);
          return Theme(
            data: ThemeData.light(),
            child: SafeArea(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SwitchListTile(
                title: const Text('Night reading'),
                value: _dark,
                activeThumbColor: MushafColors.green,
                onChanged: (v) {
                  setState(() => _dark = v);
                  setSheet(() {});
                  save('mushaf_dark', v);
                },
              ),
              SwitchListTile(
                title: const Text('Tajweed colours'),
                value: _tajweed,
                activeThumbColor: MushafColors.green,
                onChanged: (v) {
                  setState(() => _tajweed = v);
                  setSheet(() {});
                  save('mushaf_tajweed', v);
                },
              ),
              ListTile(
                title: const Text('Go to page'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  Navigator.pop(ctx);
                  final n = await _askPage();
                  if (n != null) _goTo(n);
                },
              ),
            ]),
          ));
        },
      ),
    );
  }

  Future<int?> _askPage() {
    final c = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Go to page'),
        content: TextField(
          controller: c,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '1 to 604'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final n = int.tryParse(c.text);
              if (n != null && n >= 1 && n <= 604) Navigator.pop(ctx, n);
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  void _sheet({
    required String title,
    required int itemCount,
    required Widget Function(int) builder,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: MushafColors.paper,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        builder: (_, scroll) => Theme(
          data: ThemeData.light(),
          child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title,
                style: const TextStyle(fontSize: 20, color: MushafColors.greenDeep)),
          ),
          Expanded(
            child: ListView.builder(
              controller: scroll,
              itemCount: itemCount,
              itemBuilder: (_, i) => builder(i),
            ),
          ),
        ])),
      ),
    );
  }
}
