import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/theme_provider.dart';
import '../quran_ayah/reader_theme.dart';
import 'quran_translation_ayahText.dart';
import 'quran_translation_content.dart';
import 'translation_ayah_sheet.dart';
import 'translation_data.dart';
import 'translation_prefs.dart';
import 'translation_search.dart';
import 'translations_model_class.dart';

/// The Translation reader: the meaning, page by page, in any of the
/// available languages.
///
/// Rebuilt from the old screen, which had no reading controls, no search, no
/// bookmarks, forgot your place the moment you left, and called `setState`
/// from `initState`.
class OrganizedTranslationAyahViewScreen extends StatefulWidget {
  final List<TranslationSurahClass> surahs;

  /// 1-based Mushaf page (1..604). Null or 0 resumes where you stopped.
  final int? initialPage;

  /// Global ayah number to flash on arrival, e.g. from a search result.
  final int? focusAyahNumber;

  const OrganizedTranslationAyahViewScreen({
    super.key,
    required this.surahs,
    this.initialPage,
    this.focusAyahNumber,
  });

  @override
  State<OrganizedTranslationAyahViewScreen> createState() =>
      _OrganizedTranslationAyahViewScreenState();
}

class _OrganizedTranslationAyahViewScreenState
    extends State<OrganizedTranslationAyahViewScreen> {
  static const int totalPages = TranslationData.totalPages;

  final _prefs = TranslationPrefs.instance;
  late final PageController _controller;

  List<QuranPageTranslation> _pages = const [];
  int _page = 1;
  int? _focus;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _focus = widget.focusAyahNumber;
    _boot();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    await _prefs.load();
    final pages = buildTranslationPages(widget.surahs, totalPages: totalPages);
    final start = (widget.initialPage != null && widget.initialPage! > 0)
        ? widget.initialPage!.clamp(1, totalPages)
        : _prefs.lastPage.clamp(1, totalPages);

    if (!mounted) return;
    setState(() {
      _pages = pages;
      _page = start;
      _ready = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) _controller.jumpToPage(start - 1);
    });
  }

  void _onPageChanged(int index) {
    final page = index + 1;
    setState(() {
      _page = page;
      _focus = null; // the flash is for arrival only
    });
    _prefs.setLastPage(page);
  }

  void _goToPage(int page, {int? focusAyah}) {
    final target = page.clamp(1, totalPages);
    setState(() => _focus = focusAyah);
    if (_controller.hasClients) {
      _controller.jumpToPage(target - 1);
    } else {
      setState(() => _page = target);
    }
  }

  bool get _rtl => TranslationData.isRtl(_prefs.edition);

  QuranPageTranslation get _current => _pages.isEmpty
      ? const QuranPageTranslation(pageNumber: 1, contents: [])
      : _pages[_page - 1];

  TranslationSurahClass? _surahByNumber(int n) {
    for (final s in widget.surahs) {
      if (s.number == n) return s;
    }
    return null;
  }

  AyahTranslation? _findAyah(int surah, int ayahInSurah) {
    final s = _surahByNumber(surah);
    if (s == null) return null;
    for (final a in s.ayahsEA) {
      if (a.numberInSurah == ayahInSurah) return a;
    }
    return null;
  }

  Future<void> _onAyahTap(
      AyahTranslation ayah, PageContentTranslation content) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ReaderTheme.read(context).paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TranslationAyahSheet(
        ayah: ayah,
        surahEnglishName: content.englishName,
      ),
    );
    if (mounted) setState(() {}); // a bookmark may have changed
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
            ? const Center(
                child: CircularProgressIndicator(color: ReaderTheme.green))
            : Column(
                children: [
                  _runningHead(t),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      // Right-to-left editions turn pages the other way,
                      // like a printed Urdu or Arabic book.
                      reverse: _rtl,
                      itemCount: totalPages,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) => AllTranslationTextPage(
                        key: ValueKey('translation_page_${index + 1}'),
                        page: _pages[index],
                        rtl: _rtl,
                        focusAyahNumber: _focus,
                        onAyahTap: _onAyahTap,
                      ),
                    ),
                  ),
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
      title: Text('Translation  ·  Page $_page',
          style: const TextStyle(fontSize: 17)),
      actions: [
        IconButton(
          tooltip: 'Search the translation',
          icon: const Icon(Icons.search),
          onPressed: _openSearch,
        ),
        IconButton(
          tooltip: t.dark ? 'Day mode' : 'Night mode',
          icon: Icon(t.dark ? Icons.light_mode : Icons.dark_mode),
          onPressed: themeNotifier.toggleTheme,
        ),
      ],
    );
  }

  Widget _runningHead(ReaderTheme t) {
    final c = _current.primary;
    return Container(
      width: double.infinity,
      color: t.headerBand,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              c == null ? '' : '${c.surahNumber}. ${c.englishName}',
              style: TextStyle(color: t.ink, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('Juz ${_current.juz}',
              style: TextStyle(color: t.inkSoft, fontSize: 13)),
        ],
      ),
    );
  }

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
              _barButton(Icons.numbers, 'Go to', _askPage),
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

  // ------------------------------------------------------------ navigation
  Future<void> _openSearch() async {
    final result = await Navigator.push<AyahTranslation>(
      context,
      MaterialPageRoute(
        builder: (_) => TranslationSearchPage(surahs: widget.surahs),
      ),
    );
    if (result != null) _goToPage(result.page, focusAyah: result.number);
  }

  void _openSurahIndex() => _sheet(
        title: 'Surahs',
        itemCount: widget.surahs.length,
        builder: (i) {
          final s = widget.surahs[i];
          final page = s.ayahsEA.isEmpty ? 1 : s.ayahsEA.first.page;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: ReaderTheme.green,
              child: Text('${s.number}',
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
            title: Text(s.englishName),
            subtitle: Text(
                '${s.englishNameTranslation} · ${s.numberOfAyahs} verses · page $page'),
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
        content: Text('Tap a verse, then the bookmark icon, to save it here.'),
      ));
      return;
    }

    _sheet(
      title: 'Saved verses',
      itemCount: keys.length,
      builder: (i) {
        final parts = keys[i].split(':').map(int.parse).toList();
        final surah = _surahByNumber(parts[0]);
        final ayah = _findAyah(parts[0], parts[1]);
        return ListTile(
          leading: const Icon(Icons.bookmark, color: ReaderTheme.gold),
          title: Text('${surah?.englishName ?? "Surah ${parts[0]}"} ${keys[i]}'),
          subtitle: ayah == null
              ? null
              : Text(ayah.text.trim(),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
          onTap: () {
            Navigator.pop(context);
            if (ayah != null) _goToPage(ayah.page, focusAyah: ayah.number);
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
                Text('Reading',
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
                      min: 13,
                      max: 34,
                      divisions: 21,
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
                      min: 1.3,
                      max: 2.4,
                      divisions: 11,
                      activeColor: ReaderTheme.green,
                      label: _prefs.lineHeight.toStringAsFixed(1),
                      onChanged: _prefs.setLineHeight,
                    ),
                  ),
                  const Icon(Icons.format_line_spacing, size: 28),
                ]),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Serif type'),
                  subtitle: const Text('Easier on the eye over long passages'),
                  value: _prefs.serif,
                  activeThumbColor: ReaderTheme.green,
                  onChanged: _prefs.setSerif,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Verse numbers'),
                  value: _prefs.showVerseNumbers,
                  activeThumbColor: ReaderTheme.green,
                  onChanged: _prefs.setShowVerseNumbers,
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
              child: Text(title, style: TextStyle(fontSize: 19, color: t.ink)),
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
