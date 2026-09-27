import 'dart:async';

import 'package:flutter/material.dart';

import '../quran_ayah/reader_theme.dart';
import 'translation_data.dart';
import 'translation_prefs.dart';
import 'translations_model_class.dart';

/// Search the whole translation for a word or phrase.
///
/// This is the one thing a translation can do that a Mushaf cannot, and the
/// old reader had no search at all. Everything runs against the copy already
/// on the device, so it works with no connection.
///
/// Pops with the chosen [AyahTranslation].
class TranslationSearchPage extends StatefulWidget {
  final List<TranslationSurahClass> surahs;

  const TranslationSearchPage({super.key, required this.surahs});

  @override
  State<TranslationSearchPage> createState() => _TranslationSearchPageState();
}

class _TranslationSearchPageState extends State<TranslationSearchPage> {
  final _controller = TextEditingController();
  final _prefs = TranslationPrefs.instance;

  Timer? _debounce;
  List<AyahTranslation> _results = const [];
  String _query = '';
  bool _searched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Debounced, because searching 6,236 verses on every keystroke would
  /// stutter on a mid-range phone.
  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () => _run(value));
  }

  void _run(String value) {
    final query = value.trim();
    if (query.length < 2) {
      setState(() {
        _results = const [];
        _query = query;
        _searched = query.isNotEmpty;
      });
      return;
    }
    setState(() {
      _query = query;
      _results = TranslationData.instance.search(widget.surahs, query);
      _searched = true;
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
    final rtl = TranslationData.isRtl(_prefs.edition);

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
            hintText: 'Search the translation',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                _run('');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (_searched) _resultCount(t),
          Expanded(child: _body(t, rtl)),
        ],
      ),
    );
  }

  Widget _resultCount(ReaderTheme t) => Container(
        width: double.infinity,
        color: t.headerBand,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          _results.isEmpty
              ? 'No verses found'
              : '${_results.length}${_results.length >= 300 ? "+" : ""} verses',
          style: TextStyle(color: t.inkSoft, fontSize: 13),
        ),
      );

  Widget _body(ReaderTheme t, bool rtl) {
    if (!_searched) {
      return _hint(t, 'Type a word or phrase to search every verse.');
    }
    if (_query.length < 2) {
      return _hint(t, 'Type at least two letters.');
    }
    if (_results.isEmpty) {
      return _hint(t, 'Nothing matched "$_query". Try a different wording.');
    }

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: t.divider),
      itemBuilder: (context, i) {
        final ayah = _results[i];
        return ListTile(
          title: Text(
            '${_surahName(ayah.surahNumber)}  ${ayah.surahNumber}:${ayah.numberInSurah}',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ReaderTheme.green),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: RichText(
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              textAlign: rtl ? TextAlign.right : TextAlign.left,
              text: TextSpan(
                children: _highlight(ayah.text.trim(), _query, t),
              ),
            ),
          ),
          trailing: Text('p.${ayah.page}',
              style: TextStyle(fontSize: 12, color: t.inkSoft)),
          onTap: () => Navigator.pop(context, ayah),
        );
      },
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

  /// Marks every occurrence of the query inside the verse, so the reader can
  /// see at a glance why each result matched.
  List<TextSpan> _highlight(String text, String query, ReaderTheme t) {
    final base = TextStyle(fontSize: 14, height: 1.45, color: t.ink);
    final marked = base.copyWith(
      backgroundColor: ReaderTheme.gold.withValues(alpha: t.dark ? 0.32 : 0.38),
      fontWeight: FontWeight.w600,
    );

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    // Lower-casing can change a string's length (Turkish İ, for one), which
    // would put the indices below out of step with [text].
    if (lowerText.length != text.length || lowerQuery.length != query.length) {
      return [TextSpan(text: text, style: base)];
    }
    final spans = <TextSpan>[];
    var start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start), style: base));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: base));
      }
      spans.add(TextSpan(
          text: text.substring(index, index + query.length), style: marked));
      start = index + query.length;
    }
    return spans;
  }
}
