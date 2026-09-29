import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enum/translator_list_enum.dart';
import '../provider/theme_provider.dart';
import '../quran_ayah/reader_theme.dart';
import 'eng_arabic_ayah_sheet.dart';
import 'eng_arabic_data.dart';
import 'eng_arabic_model_class.dart';
import 'eng_arabic_prefs.dart';
import 'eng_arabic_text_page.dart';
import 'quran_content_engArabic.dart';

/// The Study reader: Arabic and meaning together, page by page.
///
/// Rebuilt from the old screen, which had no reading controls, one
/// hard-coded translation, no search, no bookmarks, forgot your place the
/// moment you left, and called `setState` from `initState`.
class OrganizedEngArabicAyahViewScreen extends StatefulWidget {
  final List<SurahEngArabic> surahEA;

  /// 1-based Mushaf page (1..604). Null or 0 resumes where you stopped.
  final int? initialPage;
  final int? focusAyahNumber;

  const OrganizedEngArabicAyahViewScreen({
    super.key,
    required this.surahEA,
    this.initialPage,
    this.focusAyahNumber,
  });

  @override
  State<OrganizedEngArabicAyahViewScreen> createState() =>
      _OrganizedEngArabicAyahViewScreenState();
}

class _OrganizedEngArabicAyahViewScreenState
    extends State<OrganizedEngArabicAyahViewScreen> {
  static const int totalPages = 604;

  final _prefs = EngArabicPrefs.instance;
  late final PageController _controller;

  List<QuranPageEngArabic> _pages = const [];
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
    final pages = buildEngArabicPages(widget.surahEA, totalPages: totalPages);
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
      _focus = null;
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

  QuranPageEngArabic get _current => _pages.isEmpty
      ? const QuranPageEngArabic(pageNumber: 1, engArabicContents: [])
      : _pages[_page - 1];

  SurahEngArabic? _surahByNumber(int n) {
    for (final s in widget.surahEA) {
      if (s.number == n) return s;
    }
    return null;
  }

  AyahEngArabic? _findAyah(int surah, int ayahInSurah) {
    final s = _surahByNumber(surah);
    if (s == null) return null;
    for (final a in s.ayahsEA) {
      if (a.numberInSurah == ayahInSurah) return a;
    }
    return null;
  }

  Future<void> _onAyahTap(
      AyahEngArabic ayah, PageContentEngArabic content) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ReaderTheme.read(context).paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EngArabicAyahSheet(
        ayah: ayah,
        surahEnglishName: content.englishName,
        surahArabicName: content.surahName,
      ),
    );
    if (mounted) setState(() {});
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
                      // Right to left, like the printed Mushaf.
                      reverse: true,
                      itemCount: totalPages,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) => EngArabicTextPageNew(
                        key: ValueKey('study_page_${index + 1}'),
                        page: _pages[index],
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
      title: Text('Study  ·  Page $_page', style: const TextStyle(fontSize: 17)),
      actions: [
        IconButton(
          tooltip: 'Search Arabic and meaning',
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
          const SizedBox(width: 8),
          Text(c?.surahName ?? '',
              style: TextStyle(
                  fontFamily: 'Kitab-Bold', fontSize: 16, color: t.ink)),
          const SizedBox(width: 8),
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
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 11)),
          ]),
        ),
      );

  // ------------------------------------------------------------ navigation
  Future<void> _openSearch() async {
    final hit = await Navigator.push<AyahEngArabic>(
      context,
      MaterialPageRoute(
          builder: (_) => _StudySearchPage(surahs: widget.surahEA)),
    );
    if (hit != null) _goToPage(hit.page, focusAyah: hit.number);
  }

  void _openSurahIndex() => _sheet(
        title: 'Surahs',
        itemCount: widget.surahEA.length,
        builder: (i) {
          final s = widget.surahEA[i];
          final page = s.ayahsEA.isEmpty ? 1 : s.ayahsEA.first.page;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: ReaderTheme.green,
              child: Text('${s.number}',
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
            title: Text(s.englishName),
            subtitle: Text(
                '${s.englishNameTranslation} · ${s.isMakki ? "Makki" : "Madani"} · page $page'),
            trailing: Text(s.name,
                style: const TextStyle(fontFamily: 'Kitab-Bold', fontSize: 18)),
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
        content: Text('Tap a verse, then Save, to keep it here.'),
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
          subtitle: ayah?.translationText == null
              ? null
              : Text(ayah!.translationText!.trim(),
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
          child: SingleChildScrollView(
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
                  const SizedBox(height: 12),
                  // Two sliders, because Arabic and Latin do not read at the
                  // same size. The old page used one value for both.
                  Text('Arabic size', style: TextStyle(color: t.inkSoft)),
                  Slider(
                    value: _prefs.arabicSize,
                    min: 18,
                    max: 46,
                    divisions: 14,
                    activeColor: ReaderTheme.green,
                    label: _prefs.arabicSize.round().toString(),
                    onChanged: _prefs.setArabicSize,
                  ),
                  Text('Translation size', style: TextStyle(color: t.inkSoft)),
                  Slider(
                    value: _prefs.translationSize,
                    min: 12,
                    max: 30,
                    divisions: 18,
                    activeColor: ReaderTheme.green,
                    label: _prefs.translationSize.round().toString(),
                    onChanged: _prefs.setTranslationSize,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show Arabic'),
                    value: _prefs.showArabic,
                    activeThumbColor: ReaderTheme.green,
                    onChanged: _prefs.setShowArabic,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show translation'),
                    value: _prefs.showTranslation,
                    activeThumbColor: ReaderTheme.green,
                    onChanged: _prefs.setShowTranslation,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.translate,
                        color: ReaderTheme.green, size: 20),
                    title: const Text('Translation'),
                    subtitle: Text(_editionLabel(),
                        style: TextStyle(color: t.inkSoft, fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Change the translation from the surah list, so it can reload.'),
                      ));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _editionLabel() {
    for (final t in TranslatorName.values) {
      if (t.text == _prefs.edition) return t.label.trim();
    }
    return _prefs.edition;
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

/// Searches the Arabic and the meaning at once — neither of the other
/// readers can do both, because neither holds both.
class _StudySearchPage extends StatefulWidget {
  final List<SurahEngArabic> surahs;
  const _StudySearchPage({required this.surahs});

  @override
  State<_StudySearchPage> createState() => _StudySearchPageState();
}

class _StudySearchPageState extends State<_StudySearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<AyahEngArabic> _results = const [];
  String _query = '';
  bool _searched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () => _run(value));
  }

  void _run(String value) {
    final q = value.trim();
    setState(() {
      _query = q;
      _searched = q.isNotEmpty;
      _results = q.length < 2
          ? const []
          : EngArabicData.instance.search(widget.surahs, q);
    });
  }

  String _surahName(int number) {
    for (final s in widget.surahs) {
      if (s.number == number) return s.englishName;
    }
    return 'Surah $number';
  }

  @override
  Widget build(BuildContext context) {
    final t = ReaderTheme.of(context);

    return Scaffold(
      backgroundColor: t.paper,
      appBar: AppBar(
        backgroundColor: ReaderTheme.green,
        foregroundColor: Colors.white,
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          onSubmitted: _run,
          style: const TextStyle(color: Colors.white, fontSize: 17),
          cursorColor: ReaderTheme.goldSoft,
          decoration: const InputDecoration(
            hintText: 'Search Arabic or meaning',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
        ),
      ),
      body: !_searched
          ? _hint(t, 'Type in English, or in Arabic with or without harakat.')
          : _query.length < 2
              ? _hint(t, 'Type at least two letters.')
              : _results.isEmpty
                  ? _hint(t, 'Nothing matched "$_query".')
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: t.divider),
                      itemBuilder: (context, i) {
                        final a = _results[i];
                        return ListTile(
                          title: Text(
                            '${_surahName(a.surahNumber)}  ${a.surahNumber}:${a.numberInSurah}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ReaderTheme.green),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 4),
                              Text(a.text,
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.right,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: 'Kitab-Bold',
                                      fontSize: 17,
                                      height: 1.8,
                                      color: t.ink)),
                              if (a.translationText != null)
                                Text(a.translationText!.trim(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13, color: t.inkSoft)),
                            ],
                          ),
                          trailing: Text('p.${a.page}',
                              style: TextStyle(fontSize: 12, color: t.inkSoft)),
                          onTap: () => Navigator.pop(context, a),
                        );
                      },
                    ),
    );
  }

  Widget _hint(ReaderTheme t, String message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(color: t.inkSoft, fontSize: 15)),
        ),
      );
}
