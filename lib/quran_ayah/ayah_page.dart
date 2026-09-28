import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../quran_translation_package/translation_typography.dart';

import 'quran_content.dart';
import 'reader_prefs.dart';
import 'reader_theme.dart';
import 'surah_class.dart';

/// Renders one page of the Easy Read reader.
///
/// Two layouts share this widget:
///   * flowing  — the page as continuous justified Arabic, like a printed page
///   * studying — one ayah per block with its translation underneath
///
/// The old version painted a black page in light mode and a white page in
/// dark mode (the two colours were the wrong way round), used a photo as a
/// surah-header background, and had no way to act on a single ayah.
class AyahPageView extends StatefulWidget {
  final QuranPage page;

  /// Global ayah number currently being recited, highlighted as it plays.
  final int? playingAyahNumber;
  final void Function(Ayah ayah, PageContent content)? onAyahTap;

  const AyahPageView({
    super.key,
    required this.page,
    this.playingAyahNumber,
    this.onAyahTap,
  });

  @override
  State<AyahPageView> createState() => _AyahPageViewState();
}

class _AyahPageViewState extends State<AyahPageView> {
  /// One recognizer per ayah, created once and disposed with the page.
  final Map<int, TapGestureRecognizer> _taps = {};
  final _prefs = ReaderPrefs.instance;

  Future<Map<int, Map<int, String>>>? _translations;
  String? _loadedEdition;

  @override
  void dispose() {
    for (final r in _taps.values) {
      r.dispose();
    }
    super.dispose();
  }

  TapGestureRecognizer _tapFor(Ayah ayah, PageContent content) {
    return _taps.putIfAbsent(
      ayah.number,
      () => TapGestureRecognizer()
        ..onTap = () => widget.onAyahTap?.call(ayah, content),
    );
  }

  /// surah number -> (ayah in surah -> translation)
  Future<Map<int, Map<int, String>>> _loadTranslations(String edition) async {
    final out = <int, Map<int, String>>{};
    for (final c in widget.page.contents) {
      out[c.surahNumber] =
          await TranslationStore.instance.forSurah(c.surahNumber, edition);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final t = ReaderTheme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 600;
    final hPad = isWide ? width * 0.08 : 18.0;

    if (widget.page.isEmpty) {
      return Container(
        color: t.paper,
        alignment: Alignment.center,
        child: Text('Page ${widget.page.pageNumber}',
            style: TextStyle(color: t.inkSoft)),
      );
    }

    // Only fetch translations when the reader actually wants them.
    if (_prefs.showTranslation && _loadedEdition != _prefs.translationEdition) {
      _loadedEdition = _prefs.translationEdition;
      _translations = _loadTranslations(_loadedEdition!);
    }

    return Container(
      color: t.paper,
      child: ListView(
        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 28),
        children: [
          if (_prefs.showTranslation)
            ..._studyingLayout(t)
          else
            ..._flowingLayout(t, isWide),
          const SizedBox(height: 18),
          Center(child: _pageMedallion(t)),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ flowing
  List<Widget> _flowingLayout(ReaderTheme t, bool isWide) {
    final widgets = <Widget>[];

    for (final content in widget.page.contents) {
      if (content.isNewSurah) {
        widgets.add(_surahHeader(content, t));
        if (content.hasBismillah) widgets.add(_basmala(t));
      }
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: RichText(
            textAlign: TextAlign.justify,
            textDirection: TextDirection.rtl,
            text: TextSpan(
              children: [
                for (final ayah in content.ayahs) ...[
                  TextSpan(
                    text: '${ayah.text} ',
                    recognizer: _tapFor(ayah, content),
                    style: TextStyle(
                      fontFamily: 'Kitab-Bold',
                      fontSize: _prefs.fontSize,
                      height: _prefs.lineHeight,
                      fontWeight: FontWeight.w600,
                      color: t.ink,
                      backgroundColor: ayah.number == widget.playingAyahNumber
                          ? t.highlight
                          : null,
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: _ayahMarker(ayah, t),
                  ),
                  const TextSpan(text: ' '),
                ],
              ],
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  // ----------------------------------------------------------- studying
  List<Widget> _studyingLayout(ReaderTheme t) {
    return [
      FutureBuilder<Map<int, Map<int, String>>>(
        future: _translations,
        builder: (context, snap) {
          final data = snap.data ?? const <int, Map<int, String>>{};
          final widgets = <Widget>[];

          for (final content in widget.page.contents) {
            if (content.isNewSurah) {
              widgets.add(_surahHeader(content, t));
              if (content.hasBismillah) widgets.add(_basmala(t));
            }
            for (final ayah in content.ayahs) {
              final translation = data[content.surahNumber]?[ayah.numberInSurah];
              widgets.add(_ayahBlock(ayah, content, translation, t, snap));
            }
          }
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: widgets);
        },
      ),
    ];
  }

  Widget _ayahBlock(
    Ayah ayah,
    PageContent content,
    String? translation,
    ReaderTheme t,
    AsyncSnapshot snap,
  ) {
    final playing = ayah.number == widget.playingAyahNumber;
    return InkWell(
      onTap: () => widget.onAyahTap?.call(ayah, content),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: playing ? t.highlight : t.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: playing ? ReaderTheme.gold : t.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ayahMarker(ayah, t),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ayah.text,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Kitab-Bold',
                      fontSize: _prefs.fontSize,
                      height: _prefs.lineHeight,
                      fontWeight: FontWeight.w600,
                      color: t.ink,
                    ),
                  ),
                ),
              ],
            ),
            if (translation != null) ...[
              const SizedBox(height: 10),
              Text(
                translation,
                textDirection: TranslationTypography.isRtl(_loadedEdition ?? '')
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                style: TranslationTypography.body(
                  _loadedEdition ?? '',
                  fontSize: (_prefs.fontSize * 0.62).clamp(13, 20).toDouble(),
                  lineHeight: 1.5,
                  color: t.inkSoft,
                  serif: false,
                ),
              ),
            ] else if (snap.connectionState == ConnectionState.waiting) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(
                  minHeight: 2, color: ReaderTheme.green, backgroundColor: t.divider),
            ],
            if (ayah.sajda) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.star_border, size: 16, color: ReaderTheme.gold),
                const SizedBox(width: 6),
                Text('Sajda',
                    style: TextStyle(fontSize: 12, color: ReaderTheme.gold)),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------- pieces
  /// The ornamental band that opens a surah. Drawn, not a photo, so it stays
  /// crisp at any size and readable in both themes.
  Widget _surahHeader(PageContent content, ReaderTheme t) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: t.headerBand,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ReaderTheme.gold, width: 1.4),
      ),
      child: Column(
        children: [
          Text(
            // The API already sends "سُورَةُ ..."; only add it when missing.
            content.surahName.startsWith('سُورَةُ') ||
                    content.surahName.startsWith('سورة')
                ? content.surahName
                : 'سُورَةُ ${content.surahName}',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Kitab-Bold',
              fontSize: (_prefs.fontSize * 1.05).clamp(20, 34),
              fontWeight: FontWeight.bold,
              color: t.dark ? ReaderTheme.goldSoft : ReaderTheme.green,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            content.englishName,
            style: TextStyle(fontSize: 13, letterSpacing: 0.4, color: t.inkSoft),
          ),
        ],
      ),
    );
  }

  Widget _basmala(ReaderTheme t) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 2),
        child: Text(
          kBasmala,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'Kitab-Bold',
            fontSize: (_prefs.fontSize * 0.95).clamp(18, 32),
            height: 1.9,
            color: t.ink,
          ),
        ),
      );

  /// The end-of-ayah rosette carrying the ayah number in Arabic numerals.
  Widget _ayahMarker(Ayah ayah, ReaderTheme t) {
    final size = (_prefs.fontSize * 1.15).clamp(24.0, 42.0);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: t.dark
            ? ReaderTheme.green.withValues(alpha: 0.35)
            : ReaderTheme.goldSoft.withValues(alpha: 0.35),
        border: Border.all(color: ReaderTheme.gold, width: 1.2),
      ),
      child: Text(
        toArabicDigits(ayah.numberInSurah),
        style: TextStyle(
          fontFamily: 'Kitab-Bold',
          fontSize: size * 0.42,
          height: 1.1,
          color: t.dark ? ReaderTheme.goldSoft : ReaderTheme.green,
        ),
      ),
    );
  }

  Widget _pageMedallion(ReaderTheme t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: ReaderTheme.green,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ReaderTheme.gold, width: 1.4),
        ),
        child: Text(
          toArabicDigits(widget.page.pageNumber),
          style: const TextStyle(
              color: Colors.white, fontFamily: 'Kitab-Bold', fontSize: 15),
        ),
      );
}
