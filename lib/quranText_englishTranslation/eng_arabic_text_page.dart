import 'package:flutter/material.dart';

import '../quran_ayah/reader_theme.dart';
import '../quran_ayah/surah_class.dart' show kBasmala, toArabicDigits;
import '../quran_translation_package/translation_typography.dart';
import 'eng_arabic_model_class.dart';
import 'eng_arabic_prefs.dart';
import 'quran_content_engArabic.dart';

/// One page of the Study reader: each ayah in Arabic, with its meaning
/// underneath.
///
/// Three things were wrong with the old page:
///
/// 1. The Arabic and the English were set at the **same font size**, taken
///    from the screen height. Uthmani script needs to be noticeably larger
///    than Latin to read as comfortably, so one size always left one of them
///    wrong, and the reader had no say in either.
/// 2. The Basmala was stripped from the Arabic of ayah 1 and shown as a
///    heading — but the translation of ayah 1 still began "In the name of
///    Allah…", so the same sentence appeared twice, once in each script,
///    in different places.
/// 3. `SizedBox(height: screenHeight)` wrapped a `Container(height:
///    screenHeight)` around a `ListView`: two fixed heights fighting, with a
///    photo (`qp.jpg`) as the background of the surah heading text.
class EngArabicTextPageNew extends StatefulWidget {
  final QuranPageEngArabic page;
  final int? focusAyahNumber;
  final void Function(AyahEngArabic ayah, PageContentEngArabic content)? onAyahTap;

  const EngArabicTextPageNew({
    super.key,
    required this.page,
    this.focusAyahNumber,
    this.onAyahTap,
  });

  @override
  State<EngArabicTextPageNew> createState() => _EngArabicTextPageNewState();
}

class _EngArabicTextPageNewState extends State<EngArabicTextPageNew> {
  final _prefs = EngArabicPrefs.instance;

  @override
  Widget build(BuildContext context) {
    final t = ReaderTheme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final maxWidth = width >= 760 ? 720.0 : double.infinity;
    final hPad = width >= 760 ? 24.0 : 16.0;

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
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 28),
          children: [
            for (final content in widget.page.engArabicContents) ...[
              if (content.isNewSurah) ...[
                _surahHeading(content, t),
                if (content.hasBismillah) _basmala(content, t),
              ],
              for (final ayah in content.ayahsn) _ayahBlock(ayah, content, t),
            ],
            const SizedBox(height: 16),
            Center(child: _pageNumber(t)),
          ],
        ),
      ),
    );
  }

  Widget _ayahBlock(
      AyahEngArabic ayah, PageContentEngArabic content, ReaderTheme t) {
    final focused = ayah.number == widget.focusAyahNumber;
    final bookmarked = _prefs.isBookmarked(ayah.key);

    return InkWell(
      onTap: () => widget.onAyahTap?.call(ayah, content),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: focused ? t.highlight : t.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: focused
                ? ReaderTheme.gold
                : bookmarked
                    ? ReaderTheme.gold.withValues(alpha: 0.6)
                    : t.divider,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ayahBadge(ayah, t),
                Row(children: [
                  if (ayah.sajda)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.star_border,
                          size: 15, color: ReaderTheme.gold),
                    ),
                  if (bookmarked)
                    const Icon(Icons.bookmark, size: 15, color: ReaderTheme.gold),
                ]),
              ],
            ),
            if (_prefs.showArabic) ...[
              const SizedBox(height: 10),
              Text(
                '${ayah.text} ﴿${toArabicDigits(ayah.numberInSurah)}﴾',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Kitab-Bold',
                  // Its own size, independent of the translation below.
                  fontSize: _prefs.arabicSize,
                  height: 2.0,
                  fontWeight: FontWeight.w600,
                  color: t.ink,
                ),
              ),
            ],
            if (_prefs.showArabic && _prefs.showTranslation)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: t.divider),
              ),
            if (_prefs.showTranslation)
              Text(
                ayah.translationText?.trim() ??
                    'No translation available for this verse in the chosen edition.',
                style: TranslationTypography.body(
                  _prefs.edition,
                  fontSize: _prefs.translationSize,
                  lineHeight: 1.55,
                  color: ayah.translationText == null ? t.inkSoft : t.ink,
                  serif: true,
                ),
                textDirection: TranslationTypography.isRtl(_prefs.edition)
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                textAlign: TranslationTypography.isRtl(_prefs.edition)
                    ? TextAlign.right
                    : TextAlign.left,
              ),
          ],
        ),
      ),
    );
  }

  Widget _ayahBadge(AyahEngArabic ayah, ReaderTheme t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: t.dark
              ? ReaderTheme.green.withValues(alpha: 0.35)
              : ReaderTheme.goldSoft.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '${ayah.surahNumber}:${ayah.numberInSurah}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: t.dark ? ReaderTheme.goldSoft : ReaderTheme.green,
          ),
        ),
      );

  Widget _surahHeading(PageContentEngArabic content, ReaderTheme t) => Container(
        margin: const EdgeInsets.only(top: 8, bottom: 14),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: t.headerBand,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ReaderTheme.gold, width: 1.3),
        ),
        child: Column(
          children: [
            Text(
              content.surahName,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Kitab-Bold',
                fontSize: (_prefs.arabicSize * 0.95).clamp(20, 34),
                fontWeight: FontWeight.bold,
                color: t.dark ? ReaderTheme.goldSoft : ReaderTheme.green,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${content.surahNumber}. ${content.englishName} · ${content.englishNameTranslation}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: t.inkSoft),
            ),
          ],
        ),
      );

  /// Both scripts, once each, in one place — instead of the Arabic as a
  /// heading and the English buried at the front of ayah 1.
  Widget _basmala(PageContentEngArabic content, ReaderTheme t) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            if (_prefs.showArabic)
              Text(
                kBasmala,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Kitab-Bold',
                  fontSize: (_prefs.arabicSize * 0.9).clamp(18, 34),
                  height: 1.9,
                  color: t.ink,
                ),
              ),
            if (_prefs.showTranslation && content.bismillahTranslation != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  content.bismillahTranslation!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: (_prefs.translationSize * 0.95).clamp(11, 24),
                    fontStyle: FontStyle.italic,
                    color: t.inkSoft,
                  ),
                ),
              ),
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
        child: Text(
          toArabicDigits(widget.page.pageNumber),
          style: const TextStyle(
              color: Colors.white, fontFamily: 'Kitab-Bold', fontSize: 14),
        ),
      );
}
