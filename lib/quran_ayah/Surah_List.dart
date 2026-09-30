import 'package:flutter/material.dart';

import '../quran_byPage/quran_pages.dart';
import 'organizedAyah.dart';
import 'quran_data.dart';
import 'reader_prefs.dart';
import 'reader_theme.dart';
import 'surah_class.dart';

/// The index of the Quran: search, resume where you left off, and open any
/// surah in either reader.
class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  final _prefs = ReaderPrefs.instance;
  final _searchController = TextEditingController();

  List<Surah> _all = const [];
  List<Surah> _shown = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({bool refresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _prefs.load();
      final surahs = await QuranData.instance.load(forceRefresh: refresh);
      if (!mounted) return;
      setState(() {
        _all = surahs;
        _shown = surahs;
        _loading = false;
      });
      _filter(_searchController.text);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load the Quran. Check your connection and try again.';
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

  void _openEasyRead(int page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrganizedAyahViewScreen(surahs: _all, initialPage: page),
      ),
    ).then((_) {
      // Refresh "Continue reading" with the page the reader left on.
      if (mounted) setState(() {});
    });
  }

  void _openMushaf(int page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuranByPages(initialPage: page)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ReaderTheme.of(context);

    return Scaffold(
      backgroundColor: t.paper,
      appBar: AppBar(
        backgroundColor: ReaderTheme.green,
        foregroundColor: Colors.white,
        title: const Text('القرآن الكريم',
            style: TextStyle(fontFamily: 'Kitab-Bold')),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: ReaderTheme.green))
          : _error != null
              ? _errorState(t)
              : RefreshIndicator(
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
    );
  }

  Widget _errorState(ReaderTheme t) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 40, color: t.inkSoft),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: t.ink)),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: ReaderTheme.green),
                onPressed: () => _load(refresh: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );

  Widget _searchField(ReaderTheme t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        child: TextField(
          controller: _searchController,
          onChanged: _filter,
          style: TextStyle(color: t.ink),
          decoration: InputDecoration(
            hintText: 'Search by name or number',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _filter('');
                    },
                  ),
            filled: true,
            fillColor: t.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: t.divider),
            ),
          ),
        ),
      );

  /// Shown once the reader has been somewhere, so reopening the app puts
  /// them back on the page they left.
  Widget _continueCard(ReaderTheme t) {
    if (_prefs.lastPage <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Material(
        color: ReaderTheme.green,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openEasyRead(_prefs.lastPage),
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

  Widget _surahTile(Surah s, ReaderTheme t) {
    final page = s.ayahs.isEmpty ? 1 : s.ayahs.first.page;
    return Card(
      color: t.card,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: t.divider),
      ),
      child: ListTile(
        onTap: () => _openEasyRead(page),
        leading: _numberRosette(s.number, t),
        title: Text(s.englishName,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: t.ink)),
        subtitle: Text(
          '${s.englishNameTranslation} · ${s.isMakki ? "Makki" : "Madani"} · ${s.ayahs.length} ayahs · page $page',
          style: TextStyle(fontSize: 12, color: t.inkSoft),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.name,
                style: TextStyle(
                    fontFamily: 'Kitab-Bold', fontSize: 19, color: t.ink)),
            IconButton(
              tooltip: 'Open in Mushaf',
              icon: const Icon(Icons.auto_stories_outlined,
                  size: 20, color: ReaderTheme.gold),
              onPressed: () => _openMushaf(page),
            ),
          ],
        ),
      ),
    );
  }

  /// An eight-point rosette holding the surah number, echoing the Mushaf.
  Widget _numberRosette(int number, ReaderTheme t) => Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: t.dark
              ? ReaderTheme.green.withValues(alpha: 0.35)
              : ReaderTheme.goldSoft.withValues(alpha: 0.35),
          border: Border.all(color: ReaderTheme.gold, width: 1.2),
        ),
        child: Text(
          toArabicDigits(number),
          style: TextStyle(
            fontFamily: 'Kitab-Bold',
            fontSize: 15,
            color: t.dark ? ReaderTheme.goldSoft : ReaderTheme.green,
          ),
        ),
      );
}
