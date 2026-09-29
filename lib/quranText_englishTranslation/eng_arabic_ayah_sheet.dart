import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../quran_ayah/reader_theme.dart';
import 'eng_arabic_model_class.dart';
import 'eng_arabic_prefs.dart';

/// Opens when a reader taps an ayah in the Study reader.
///
/// Once the audio task is applied, a "Listen" button belongs here too:
/// `QuranAudioService.instance.loadSurah(surah, startIndex: ayah.numberInSurah - 1)`.
/// It is left out for now so this reader does not depend on that work.
class EngArabicAyahSheet extends StatefulWidget {
  final AyahEngArabic ayah;
  final String surahEnglishName;
  final String surahArabicName;

  const EngArabicAyahSheet({
    super.key,
    required this.ayah,
    required this.surahEnglishName,
    required this.surahArabicName,
  });

  @override
  State<EngArabicAyahSheet> createState() => _EngArabicAyahSheetState();
}

class _EngArabicAyahSheetState extends State<EngArabicAyahSheet> {
  final _prefs = EngArabicPrefs.instance;

  String get _reference =>
      '${widget.surahEnglishName} ${widget.ayah.surahNumber}:${widget.ayah.numberInSurah}';

  String _shareText({bool arabic = true, bool translation = true}) => [
        if (arabic) widget.ayah.text,
        if (translation && widget.ayah.translationText != null)
          widget.ayah.translationText!.trim(),
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
            Row(
              children: [
                Expanded(
                  child: Text(_reference,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: ReaderTheme.green)),
                ),
                Text(widget.surahArabicName,
                    style: TextStyle(
                        fontFamily: 'Kitab-Bold', fontSize: 19, color: t.ink)),
              ],
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.ayah.text,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontFamily: 'Kitab-Bold',
                          fontSize: 25,
                          height: 2.0,
                          color: t.ink),
                    ),
                    Divider(height: 24, color: t.divider),
                    Text(
                      widget.ayah.translationText?.trim() ??
                          'No translation available for this verse.',
                      style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: widget.ayah.translationText == null
                              ? t.inkSoft
                              : t.ink),
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
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: ReaderTheme.green,
                        foregroundColor: Colors.white),
                    icon: Icon(
                        bookmarked ? Icons.bookmark : Icons.bookmark_border),
                    label: Text(bookmarked ? 'Saved' : 'Save this verse'),
                    onPressed: () async {
                      await _prefs.toggleBookmark(widget.ayah.key);
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  tooltip: 'Copy',
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _shareText()));
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Verse copied')));
                  },
                ),
                IconButton.outlined(
                  tooltip: 'Share',
                  icon: const Icon(Icons.share),
                  onPressed: () => SharePlus.instance.share(
                      ShareParams(text: _shareText(), subject: _reference)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => SharePlus.instance.share(ShareParams(
                      text: _shareText(translation: false),
                      subject: _reference)),
                  child: const Text('Share Arabic only'),
                ),
                TextButton(
                  onPressed: () => SharePlus.instance.share(ShareParams(
                      text: _shareText(arabic: false), subject: _reference)),
                  child: const Text('Share meaning only'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
