import 'package:flutter/material.dart';

import '../quran_ayah/reader_theme.dart';
import 'organized_translationAyah.dart';
import 'translation_data.dart';
import 'translation_prefs.dart';
import 'translation_search.dart';
import 'translations_model_class.dart';

/// The front door of the Translation reader: pick a language, resume where
/// you were, search, or open any surah.
class QuranTranslationListPage extends StatefulWidget {
  const QuranTranslationListPage({super.key});

  @override
  State<QuranTranslationListPage> createState() =>
      _QuranTranslationListPageState();
}

class _QuranTranslationListPageState extends State<QuranTranslationListPage> {
  final _prefs = TranslationPrefs.instance;
  final _searchController = TextEditingController();

  List<TranslationSurahClass> _all = const [];
  List<TranslationSurahClass> _shown = const [];
  Set<String> _downloaded = const {};

  bool _loading = true;
  double _progress = 0;
  String? _error;

  /// The edition being fetched. Only saved as the reader's choice once it has
  /// loaded, so a failed switch leaves the previous edition fully in charge.
  String? _pending;

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
    await _loadEdition(_prefs.edition);
  }

  Future<void> _loadEdition(String edition, {bool refresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
      _progress = 0;
      _pending = edition;
    });

    try {
      final surahs = await TranslationData.instance.load(
        edition,
        forceRefresh: refresh,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (edition != _prefs.edition) await _prefs.setEdition(edition);
      final downloaded = await TranslationData.instance.downloadedEditions();
      if (!mounted) return;
      setState(() {
        _all = surahs;
        _downloaded = downloaded;
        _loading = false;
        _pending = null;
      });
      _filter(_searchController.text);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        // Keep whatever was already on screen, so a failed switch does not
        // leave the reader staring at an empty list.
        _error = _all.isEmpty
            ? 'Could not load this translation. Check your connection and try again.'
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
                  s.number.toString() == q;
            }).toList();
    });
  }

  String _labelFor(String edition) => TranslationEdition.labelFor(edition);

  String get _editionLabel => _labelFor(_prefs.edition);

  /// Opens the reader, then refreshes on return so "Continue reading" shows
  /// the page the reader actually stopped on.
  Future<void> _open(int page, {int? focusAyahNumber}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrganizedTranslationAyahViewScreen(
          surahs: _all,
          initialPage: page,
          focusAyahNumber: focusAyahNumber,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  // ----------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final t = ReaderTheme.of(context);

    return Scaffold(
      backgroundColor: t.paper,
      appBar: AppBar(
        backgroundColor: ReaderTheme.green,
        foregroundColor: Colors.white,
        title: const Text('Translation'),
        actions: [
          IconButton(
            tooltip: 'Search the translation',
            icon: const Icon(Icons.search),
            onPressed: _all.isEmpty
                ? null
                : () async {
                    final hit = await Navigator.push<AyahTranslation>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TranslationSearchPage(surahs: _all)),
                    );
                    if (hit != null && mounted) {
                      _open(hit.page, focusAyahNumber: hit.number);
                    }
                  },
          ),
        ],
      ),
      body: _loading && _all.isEmpty
          ? _downloading(t)
          : Column(
              children: [
                _editionBar(t),
                if (_loading && _pending != null) _switchProgress(t),
                if (_error != null) _errorBar(t),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _loadEdition(_prefs.edition, refresh: true),
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
    );
  }

  /// A real progress bar. The old screen showed a bare spinner for a
  /// multi-megabyte download, which looks identical to a hang.
  Widget _downloading(ReaderTheme t) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Downloading $_editionLabel',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, color: t.ink)),
              const SizedBox(height: 6),
              Text('It is saved on your phone, so this happens once.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: t.inkSoft)),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: _progress == 0 ? null : _progress,
                color: ReaderTheme.green,
                backgroundColor: t.divider,
              ),
              if (_progress > 0) ...[
                const SizedBox(height: 8),
                Text('${(_progress * 100).round()}%',
                    style: TextStyle(color: t.inkSoft, fontSize: 12)),
              ],
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
                  Text('Change',
                      style: TextStyle(
                          color: ReaderTheme.green,
                          fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );

  /// Shown while switching edition, with the old list still readable below.
  Widget _switchProgress(ReaderTheme t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: _progress == 0 ? null : _progress,
                color: ReaderTheme.green,
                backgroundColor: t.divider,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _progress == 0
                  ? _labelFor(_pending!)
                  : '${(_progress * 100).round()}%',
              style: TextStyle(color: t.inkSoft, fontSize: 12),
            ),
          ],
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
              onPressed: () =>
                  _loadEdition(_pending ?? _prefs.edition, refresh: true),
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
                      const Text('Continue reading',
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

  Widget _surahTile(TranslationSurahClass s, ReaderTheme t) {
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
        trailing: Icon(Icons.chevron_right, color: t.inkSoft),
      ),
    );
  }

  /// A searchable list beats a 34-item dropdown, especially when the reader
  /// is hunting for one language among many.
  Future<void> _pickTranslation() async {
    final t = ReaderTheme.read(context);
    final controller = TextEditingController();
    var shown = TranslationEdition.all;

    final picked = await showModalBottomSheet<TranslationEdition>(
      context: context,
      isScrollControlled: true,
      backgroundColor: t.paper,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          builder: (_, scroll) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: controller,
                  autofocus: false,
                  decoration: const InputDecoration(
                    hintText: 'Search language or translator',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (q) {
                    final query = q.trim().toLowerCase();
                    setSheet(() {
                      shown = query.isEmpty
                          ? TranslationEdition.all
                          : TranslationEdition.all
                              .where((e) =>
                                  e.label.toLowerCase().contains(query) ||
                                  e.code.toLowerCase().contains(query))
                              .toList();
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scroll,
                  itemCount: shown.length,
                  itemBuilder: (_, i) {
                    final e = shown[i];
                    final isCurrent = e.code == _prefs.edition;
                    final offline = _downloaded.contains(e.code);
                    return ListTile(
                      title: Text(e.label),
                      subtitle: offline
                          ? Text('Saved on this phone',
                              style: TextStyle(fontSize: 11, color: t.inkSoft))
                          : null,
                      leading: Icon(
                        offline ? Icons.offline_pin : Icons.cloud_download_outlined,
                        color: offline ? ReaderTheme.green : t.inkSoft,
                        size: 20,
                      ),
                      trailing: isCurrent
                          ? const Icon(Icons.check, color: ReaderTheme.green)
                          : null,
                      onTap: () => Navigator.pop(ctx, e),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (picked == null || picked.code == _prefs.edition) return;
    await _loadEdition(picked.code);
  }
}
