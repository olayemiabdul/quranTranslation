import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../quran_ayah/reader_theme.dart';
import 'translation_prefs.dart';
import 'translations_model_class.dart';

/// Fetches the Uthmani Arabic for a single ayah, on demand, and keeps it.
/// The Translation reader deliberately shows no Arabic on the page, so this
/// is how someone checks the original when they want to.
class ArabicAyahStore {
  ArabicAyahStore._();
  static final ArabicAyahStore instance = ArabicAyahStore._();

  final Map<String, String> _memory = {};

  Future<String?> get(int surah, int ayah) async {
    final key = '$surah:$ayah';
    if (_memory.containsKey(key)) return _memory[key];

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('ar_ayah_$key');
    if (stored != null) {
      _memory[key] = stored;
      return stored;
    }

    try {
      final res = await http
          .get(Uri.parse('https://api.alquran.cloud/v1/ayah/$key/quran-uthmani'))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return null;
      final text = json.decode(res.body)['data']['text'].toString();
      _memory[key] = text;
      await prefs.setString('ar_ayah_$key', text);
      return text;
    } catch (_) {
      return null;
    }
  }
}

/// Opens when a reader taps an ayah in the Translation reader.
class TranslationAyahSheet extends StatefulWidget {
  final AyahTranslation ayah;
  final String surahEnglishName;

  const TranslationAyahSheet({
    super.key,
    required this.ayah,
    required this.surahEnglishName,
  });

  @override
  State<TranslationAyahSheet> createState() => _TranslationAyahSheetState();
}

class _TranslationAyahSheetState extends State<TranslationAyahSheet> {
  final _prefs = TranslationPrefs.instance;
  String? _arabic;
  bool _loadingArabic = false;

  Future<void> _loadArabic() async {
    setState(() => _loadingArabic = true);
    final text = await ArabicAyahStore.instance
        .get(widget.ayah.surahNumber, widget.ayah.numberInSurah);
    if (!mounted) return;
    setState(() {
      _arabic = text;
      _loadingArabic = false;
    });
    if (text == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('The Arabic needs an internet connection.'),
      ));
    }
  }

  String get _reference =>
      '${widget.surahEnglishName} ${widget.ayah.surahNumber}:${widget.ayah.numberInSurah}';

  String get _shareText => [
        if (_arabic != null) _arabic!,
        widget.ayah.text.trim(),
        '($_reference)',
        'Shared from Universal Quran',
      ].join('\n\n');

  @override
  Widget build(BuildContext context) {
    final t = ReaderTheme.of(context);
    final bookmarked = _prefs.isBookmarked(widget.ayah.key);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: t.inkSoft,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(_reference,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: ReaderTheme.green)),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_arabic != null) ...[
                      Text(
                        _arabic!,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontFamily: 'Kitab-Bold',
                            fontSize: 24,
                            height: 2.0,
                            color: t.ink),
                      ),
                      Divider(height: 24, color: t.divider),
                    ],
                    Text(
                      widget.ayah.text.trim(),
                      style: TextStyle(
                          fontSize: 16, height: 1.6, color: t.ink),
                    ),
                    if (widget.ayah.sajda) ...[
                      const SizedBox(height: 10),
                      Row(children: [
                        const Icon(Icons.star_border,
                            size: 16, color: ReaderTheme.gold),
                        const SizedBox(width: 6),
                        Text('Verse of prostration',
                            style: TextStyle(fontSize: 12, color: t.inkSoft)),
                      ]),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _arabic != null
                      ? OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.check),
                          label: const Text('Arabic shown'),
                        )
                      : FilledButton.icon(
                          style: FilledButton.styleFrom(
                              backgroundColor: ReaderTheme.green,
                              foregroundColor: Colors.white),
                          onPressed: _loadingArabic ? null : _loadArabic,
                          icon: _loadingArabic
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.translate),
                          label: const Text('Show the Arabic'),
                        ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark',
                  icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: bookmarked ? ReaderTheme.gold : null),
                  onPressed: () async {
                    await _prefs.toggleBookmark(widget.ayah.key);
                    setState(() {});
                  },
                ),
                IconButton.outlined(
                  tooltip: 'Copy',
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _shareText));
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Verse copied')));
                  },
                ),
                IconButton.outlined(
                  tooltip: 'Share',
                  icon: const Icon(Icons.share),
                  // share_plus v10+ API, matching widget_data.dart.
                  // On share_plus 9.x this is Share.share(text, subject: ...).
                  onPressed: () => SharePlus.instance
                      .share(ShareParams(text: _shareText, subject: _reference)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
