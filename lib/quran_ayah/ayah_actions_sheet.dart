import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_quran/enum/reciter_list_enum.dart';
import 'package:universal_quran/enum/translator_list_enum.dart';
import 'reader_prefs.dart';
import 'reader_theme.dart';
import 'surah_class.dart';

enum AyahAction { playFromHere }

/// Opens when a reader taps an ayah: the ayah, its translation, and the
/// four things people actually want to do with it.
class AyahActionsSheet extends StatefulWidget {
  final Ayah ayah;
  final String surahNameArabic;
  final String surahNameEnglish;

  const AyahActionsSheet({
    super.key,
    required this.ayah,
    required this.surahNameArabic,
    required this.surahNameEnglish,
  });

  @override
  State<AyahActionsSheet> createState() => _AyahActionsSheetState();
}

class _AyahActionsSheetState extends State<AyahActionsSheet> {
  final _prefs = ReaderPrefs.instance;
  String? _translation;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _translation = null;
      _failed = false;
    });
    final text = await TranslationStore.instance.forAyah(
      widget.ayah.surahNumber,
      widget.ayah.numberInSurah,
      _prefs.translationEdition,
    );
    if (!mounted) return;
    setState(() {
      _translation = text;
      _failed = text == null;
    });
  }

  String get _reference =>
      '${widget.surahNameEnglish} ${widget.ayah.surahNumber}:${widget.ayah.numberInSurah}';

  String get _shareText => [
        widget.ayah.text,
        if (_translation != null) _translation!,
        '($_reference)',
        'Shared from Universal Quran',
      ].join('\n\n');

  @override
  Widget build(BuildContext context) {
    final t = ReaderTheme.of(context);
    final bookmarked = _prefs.isBookmarked(widget.ayah.key);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 10, 20, 16 + MediaQuery.of(context).viewInsets.bottom),
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
                  child: Text(
                    _reference,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: ReaderTheme.green),
                  ),
                ),
                Text(widget.surahNameArabic,
                    style: TextStyle(
                        fontFamily: 'Kitab-Bold', fontSize: 20, color: t.ink)),
              ],
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints:
                  BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.34),
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
                    Divider(height: 26, color: t.divider),
                    if (_translation != null)
                      Text(_translation!,
                          style: TextStyle(fontSize: 16, height: 1.55, color: t.ink))
                    else if (_failed)
                      TextButton.icon(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Translation needs internet. Try again'),
                      )
                    else
                      const LinearProgressIndicator(color: ReaderTheme.green),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: TranslatorName.values
                      .any((e) => e.text == _prefs.translationEdition)
                  ? _prefs.translationEdition
                  : null,
              isExpanded: true,
              hint: const Text('Sahih International (English)'),
              decoration: const InputDecoration(
                labelText: 'Translation',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: TranslatorName.values
                  .map((e) =>
                      DropdownMenuItem(value: e.text, child: Text(e.label.trim())))
                  .toList(),
              onChanged: (v) async {
                if (v == null) return;
                await _prefs.setTranslationEdition(v);
                _load();
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: ReciterName.values.any((e) => e.text == _prefs.reciter)
                  ? _prefs.reciter
                  : null,
              isExpanded: true,
              hint: const Text('Mishary Alafasy'),
              decoration: const InputDecoration(
                labelText: 'Reciter',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: ReciterName.values
                  .map((e) =>
                      DropdownMenuItem(value: e.text, child: Text(e.label.trim())))
                  .toList(),
              onChanged: (v) async {
                if (v == null) return;
                await _prefs.setReciter(v);
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: ReaderTheme.green,
                        foregroundColor: Colors.white),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Listen from here'),
                    onPressed: () =>
                        Navigator.pop(context, AyahAction.playFromHere),
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
                        const SnackBar(content: Text('Ayah copied')));
                  },
                ),
                IconButton.outlined(
                  tooltip: 'Share',
                  icon: const Icon(Icons.share),
                  onPressed: () => SharePlus.instance.share(
                      ShareParams(text: _shareText, subject: _reference)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
