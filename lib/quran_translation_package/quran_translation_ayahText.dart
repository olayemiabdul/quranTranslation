import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../quran_ayah/reader_theme.dart';
import 'quran_translation_content.dart';
import 'translation_prefs.dart';
import 'translation_typography.dart';
import 'translations_model_class.dart';

/// Renders one page of the Translation reader.
///
/// The old version put every single ayah in its own bordered, italic card,
/// which turns a page of scripture into a stack of boxes and is tiring to
/// read. A translation is prose: it is set as prose here, with the ayah
/// number as a small marker in the flow, the way printed translations do it.
///
/// It also sized the text from the screen HEIGHT (`screenHeight * 0.025`),
/// so the same text was a different size on every phone and the reader had
/// no say. Size and spacing are now the reader's choice.
class AllTranslationTextPage extends StatefulWidget {
  final QuranPageTranslation page;

  /// True when the chosen edition's script runs right to left (Urdu,
  /// Persian, Pashto and so on).
  final bool rtl;

  /// Ayah to flash, e.g. after arriving from search.
  final int? focusAyahNumber;
  final void Function(AyahTranslation ayah, PageContentTranslation content)? onAyahTap;

  const AllTranslationTextPage({
    super.key,
    required this.page,
    this.rtl = false,
    this.focusAyahNumber,
    this.onAyahTap,
  });

  @override
  State<AllTranslationTextPage> createState() => _AllTranslationTextPageState();
}

class _AllTranslationTextPageState extends State<AllTranslationTextPage> {
  final Map<int, TapGestureRecognizer> _taps = {};
  final _prefs = TranslationPrefs.instance;

  @override
  void dispose() {
    for (final r in _taps.values) {
      r.dispose();
    }
    super.dispose();
  }

  TapGestureRecognizer _tapFor(AyahTranslation ayah, PageContentTranslation content) =>
      _taps.putIfAbsent(
        ayah.number,
        () => TapGestureRecognizer()
          ..onTap = () => widget.onAyahTap?.call(ayah, content),
      );

  /// Script-aware: Urdu gets nastaliq, Arabic-script languages get naskh,
  /// Latin gets the reader's serif or sans choice. A Latin face has no Urdu
  /// glyphs at all, so this is correctness, not polish.
  TextStyle _body(ReaderTheme t) => TranslationTypography.body(
        _prefs.edition,
        fontSize: _prefs.fontSize,
        lineHeight: _prefs.lineHeight,
        color: t.ink,
        serif: _prefs.serif,
      );

  @override
  Widget build(BuildContext context) {
    final t = ReaderTheme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    // A comfortable measure: long lines are the main reason a wide screen
    // reads worse than a phone.
    final maxWidth = width >= 700 ? 680.0 : double.infinity;
    final hPad = width >= 700 ? 24.0 : 20.0;

    if (widget.page.isEmpty) {
      return Container(
        color: t.paper,
        alignment: Alignment.center,
        child: Text('Page ${widget.page.pageNumber}',
            style: TextStyle(color: t.inkSoft)),
      );
    }

    return Container(
      color: t.paper,
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 30),
          children: [
            for (final content in widget.page.contents) ...[
              if (content.isNewSurah) ...[
                _surahHeading(content, t),
                if (content.bismillah != null) _bismillah(content.bismillah!, t),
              ],
              _prose(content, t),
              if (content.ayahs.any((a) => a.sajda)) _sajdaNote(t),
            ],
            const SizedBox(height: 18),
            Center(child: _pageNumber(t)),
          ],
        ),
      ),
    );
  }

  /// The ayahs of one surah on this page, set as continuous prose.
  Widget _prose(PageContentTranslation content, ReaderTheme t) {
    final body = _body(t);

    return Padding(
      // Nastaliq descenders need more vertical room than Latin.
      padding: TranslationTypography.versePadding(_prefs.edition),
      child: RichText(
        textDirection: widget.rtl ? TextDirection.rtl : TextDirection.ltr,
        textAlign: widget.rtl ? TextAlign.right : TextAlign.left,
        text: TextSpan(
          children: [
            for (final ayah in content.ayahs) ...[
              if (_prefs.showVerseNumbers)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: _verseMarker(ayah, t),
                ),
              TextSpan(
                text: '${ayah.text.trim()}  ',
                recognizer: _tapFor(ayah, content),
                style: body.copyWith(
                  backgroundColor: _tint(ayah, t),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color? _tint(AyahTranslation ayah, ReaderTheme t) {
    if (ayah.number == widget.focusAyahNumber) return t.highlight;
    if (_prefs.isBookmarked(ayah.key)) {
      return ReaderTheme.gold.withValues(alpha: t.dark ? 0.12 : 0.16);
    }
    return null;
  }

  /// A small numeral in the flow of the text, not a heading of its own.
  Widget _verseMarker(AyahTranslation ayah, ReaderTheme t) => Padding(
        padding: widget.rtl
            ? const EdgeInsets.only(left: 5)
            : const EdgeInsets.only(right: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: t.dark
                ? ReaderTheme.green.withValues(alpha: 0.35)
                : ReaderTheme.goldSoft.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            '${ayah.numberInSurah}',
            style: TextStyle(
              fontSize: (_prefs.fontSize * 0.62).clamp(10, 18),
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: t.dark ? ReaderTheme.goldSoft : ReaderTheme.green,
            ),
          ),
        ),
      );

  Widget _surahHeading(PageContentTranslation content, ReaderTheme t) => Container(
        margin: const EdgeInsets.only(top: 10, bottom: 14),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: t.headerBand,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ReaderTheme.gold, width: 1.2),
        ),
        child: Column(
          children: [
            Text(
              '${content.surahNumber}. ${content.englishName}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: (_prefs.fontSize * 1.05).clamp(16, 26),
                fontWeight: FontWeight.w600,
                color: t.dark ? ReaderTheme.goldSoft : ReaderTheme.green,
              ),
            ),
            if (content.englishNameTranslation.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                content.englishNameTranslation,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: t.inkSoft),
              ),
            ],
          ],
        ),
      );

  Widget _bismillah(String text, ReaderTheme t) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(
          text,
          textAlign: TextAlign.center,
          textDirection: widget.rtl ? TextDirection.rtl : TextDirection.ltr,
          style: _body(t).copyWith(
            // Arabic-script faces have no italic; Flutter would fake a slant.
            fontStyle: widget.rtl ? FontStyle.normal : FontStyle.italic,
            fontSize: (_prefs.fontSize * 0.95).clamp(12, 30) *
                TranslationTypography.sizeFactor(_prefs.edition),
            color: t.inkSoft,
          ),
        ),
      );

  Widget _sajdaNote(ReaderTheme t) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_border, size: 15, color: ReaderTheme.gold),
            const SizedBox(width: 6),
            Text('A verse of prostration falls on this page',
                style: TextStyle(fontSize: 12, color: t.inkSoft)),
          ],
        ),
      );

  Widget _pageNumber(ReaderTheme t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        decoration: BoxDecoration(
          color: ReaderTheme.green,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ReaderTheme.gold, width: 1.2),
        ),
        child: Text('${widget.page.pageNumber}',
            style: const TextStyle(color: Colors.white, fontSize: 13)),
      );
}
