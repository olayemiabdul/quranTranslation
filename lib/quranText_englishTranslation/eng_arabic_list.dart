import 'package:flutter/material.dart';

import '../enum/translator_list_enum.dart';
import '../quran_ayah/reader_theme.dart';
import 'eng_arabic_data.dart';
import 'eng_arabic_model_class.dart';
import 'eng_arabic_prefs.dart';
import 'organized_ayah_engArabic.dart';

/// The front door of the Study reader.
///
/// The old screen downloaded two full copies of the Quran — the Uthmani
/// Arabic and `en.ahmedali` — about ten megabytes, into their own cache
/// keys, duplicating data the app already held for its other readers. And
/// the translation was hard-coded, so this reader offered exactly one and no
/// way to change it. Both halves now come from the caches the app already
/// keeps, so on a phone that has opened any other reader this costs nothing.
class EngArabicTextSurahListPageNew extends StatefulWidget {
  const EngArabicTextSurahListPageNew({super.key});

  @override
  State<EngArabicTextSurahListPageNew> createState() =>
      _EngArabicTextSurahListPageNewState();
}

class _EngArabicTextSurahListPageNewState
    extends State<EngArabicTextSurahListPageNew> {
  final _prefs = EngArabicPrefs.instance;
  final _searchController = TextEditingController();

  List<SurahEngArabic> _all = const [];
  List<SurahEngArabic> _shown = const [];
  bool _loading = true;
  double _progress = 0;
  String? _error;
  int _missing = 0;

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
      _progress = 0;
    });
    try {
      final surahs = await EngArabicData.instance.load(
        _prefs.edition,
        forceRefresh: refresh,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (!mounted) return;
      setState(() {
        _all = surahs;
        _shown = surahs;
        _missing = EngArabicData.instance.missingTranslations(surahs);
        _loading = false;
      });
      _filter(_searchController.text);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _all.isEmpty
            ? 'Could not load the Quran. Check your connection and try again.'
            : 'Could not switch translation. Showing the previous one.';
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

  String get _editionLabel {
    for (final t in TranslatorName.values) {
      if (t.text == _prefs.edition) return t.label.trim();
    }
    return _prefs.edition;
  }

  void _open(int page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrganizedEngArabicAyahViewScreen(
          surahEA: _all,
          initialPage: page,
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
          title: const Text('Study'),
          centerTitle: true,
        ),
        body: _loading && _all.isEmpty
            ? _loadingState(t)
            : Column(
                children: [
                  _editionBar(t),
                  if (_error != null) _errorBar(t),
                  if (_missing > 0) _missingBar(t),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _load(refresh: true),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: _shown.length + 2,
                        itemBuilder: (context, i) {
                          if (i == 0) return _searchField(t);
                          if (i == 1) return _continueCard(t);
                          return _surahTile(_shown[i - 2], t);
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _loadingState(ReaderTheme t) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Preparing $_editionLabel',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, color: t.ink)),
              const SizedBox(height: 6),
              Text('Saved on your phone, so this happens once.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: t.inkSoft)),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: _progress == 0 ? null : _progress,
                color: ReaderTheme.green,
                backgroundColor: t.divider,
              ),
            ],
          ),
        ),
      );

  Widget _editionBar(ReaderTheme t) => Material(
        color: t.headerBand,
        child: InkWell(
          onTap: _pickTranslation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.translate, color: ReaderTheme.green, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Translation',
                          style: TextStyle(fontSize: 11, color: t.inkSoft)),
                      Text(_editionLabel,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: t.ink)),
                    ],
                  ),
                ),
                if (_loading)
                  const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: ReaderTheme.green))
                else
                  const Text('Change',
                      style: TextStyle(
                          color: ReaderTheme.green,
                          fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );

  Widget _errorBar(ReaderTheme t) => Container(
        width: double.infinity,
        color: const Color(0xFFFFF1CC),
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFF8A6100)),
          const SizedBox(width: 10),
          Expanded(child: Text(_error!)),
          TextButton(
              onPressed: () => _load(refresh: true), child: const Text('Retry')),
        ]),
      );

  /// Surfaced rather than hidden: it means the Arabic and the chosen
  /// translation disagree about where an ayah begins.
  Widget _missingBar(ReaderTheme t) => Container(
        width: double.infinity,
        color: t.headerBand,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          '$_missing verses have no translation in this edition.',
          style: TextStyle(fontSize: 12, color: t.inkSoft),
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
    if (_prefs.lastPage <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Material(
        color: ReaderTheme.green,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _open(_prefs.lastPage),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.menu_book, color: ReaderTheme.goldSoft),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Continue studying',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      Text('Page ${_prefs.lastPage}',
                          style: const TextStyle(color: ReaderTheme.goldSoft)),
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

  Widget _surahTile(SurahEngArabic s, ReaderTheme t) {
    final page = s.ayahsEA.isEmpty ? 1 : s.ayahsEA.first.page;
    return Card(
      color: t.card,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: t.divider),
      ),
      child: ListTile(
        onTap: () => _open(page),
        leading: CircleAvatar(
          backgroundColor: ReaderTheme.green,
          child: Text('${s.number}',
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
        title: Text(s.englishName,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: t.ink)),
        subtitle: Text(
          '${s.englishNameTranslation} · ${s.isMakki ? "Makki" : "Madani"} · ${s.numberOfAyahs} verses · page $page',
          style: TextStyle(fontSize: 12, color: t.inkSoft),
        ),
        trailing: Text(s.name,
            style: TextStyle(
                fontFamily: 'Kitab-Bold', fontSize: 19, color: t.ink)),
      ),
    );
  }

  Future<void> _pickTranslation() async {
    final t = ReaderTheme.read(context);
    final controller = TextEditingController();
    var query = '';

    List<TranslatorName> visible() => TranslatorName.values.where((e) {
          if (query.isEmpty) return true;
          return e.label.toLowerCase().contains(query) ||
              e.text.toLowerCase().contains(query);
        }).toList();

    final picked = await showModalBottomSheet<TranslatorName>(
      context: context,
      isScrollControlled: true,
      backgroundColor: t.paper,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final shown = visible();
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.8,
            builder: (_, scroll) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Search language or translator',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (q) =>
                        setSheet(() => query = q.trim().toLowerCase()),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scroll,
                    itemCount: shown.length,
                    itemBuilder: (_, i) {
                      final e = shown[i];
                      return ListTile(
                        title: Text(e.label.trim()),
                        trailing: e.text == _prefs.edition
                            ? const Icon(Icons.check, color: ReaderTheme.green)
                            : null,
                        onTap: () => Navigator.pop(ctx, e),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (picked == null || picked.text == _prefs.edition) return;
    await _prefs.setEdition(picked.text);
    await _load();
  }
}
