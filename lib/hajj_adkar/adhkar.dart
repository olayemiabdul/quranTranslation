import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../quran_ayah/quran_data.dart';
import '../quran_ayah/reader_theme.dart';
import 'adhkar_data.dart';
import 'tasbih_counter.dart';

/// The adhkar said after the obligatory prayers.
///
/// The old page was 1,272 lines of hand-placed widgets, and it had problems
/// that were structural rather than cosmetic:
///
///  * Six of the eleven screens were a bare `Column` inside a `PageView`,
///    with no scrolling. On any phone shorter than the content — which is
///    most of them — the page overflowed with the yellow-and-black stripes.
///  * Alignment was faked with hard pixel padding: `EdgeInsets.only(left: 220)`,
///    `right: 270`, `right: 200`. On a small phone that pushes text off the
///    screen; on a tablet it strands it in the middle.
///  * The text was white over a light mosque photograph, with no scrim.
///  * Entries 3 and 10 were the same dhikr, twice. The opening hadith was
///    printed twice on the same screen. Entries 6, 7 and 8 carried the same
///    three trailing hadiths each.
///  * There was no counter, which is the one thing a person actually needs
///    when saying something thirty-three times.
///
/// The content corrections are listed in ADHKAR_REVIEW.md.
class RemembrancePage extends StatefulWidget {
  const RemembrancePage({super.key});

  @override
  State<RemembrancePage> createState() => _RemembrancePageState();
}

class _RemembrancePageState extends State<RemembrancePage> {
  static const _kFontSize = 'adhkar_font_size';

  double _arabicSize = 26;
  final Map<int, int> _counts = {}; // dhikr number -> times said

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _arabicSize = p.getDouble(_kFontSize) ?? 26);

    // QuranData.cached is in memory only, so after a cold start it is empty
    // until a reader has opened. If the Quran is saved on the device, load it
    // from there so the Quranic passages come from the mushaf text. If it is
    // not, keep the fallback rather than start a download from this page.
    if (QuranData.instance.cached == null && await QuranData.isOnDevice()) {
      try {
        await QuranData.instance.load();
        if (mounted) setState(() {});
      } catch (_) {
        // The typed fallback stays on screen.
      }
    }
  }

  Future<void> _setSize(double v) async {
    setState(() => _arabicSize = v.clamp(18, 44));
    (await SharedPreferences.getInstance()).setDouble(_kFontSize, _arabicSize);
  }

  int get _completed =>
      afterPrayerAdhkar.where((d) => (_counts[d.number] ?? 0) >= d.count).length;

  @override
  Widget build(BuildContext context) {
    final t = ReaderTheme.of(context);

    return Scaffold(
      backgroundColor: t.paper,
      appBar: AppBar(
        backgroundColor: ReaderTheme.green,
        foregroundColor: Colors.white,
        title: const Text('After the prayer'),
        actions: [
          IconButton(
            tooltip: 'Text size',
            icon: const Icon(Icons.text_fields),
            onPressed: _openSize,
          ),
          if (_counts.isNotEmpty)
            IconButton(
              tooltip: 'Start again',
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(_counts.clear),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: _completed / afterPrayerAdhkar.length,
            minHeight: 3,
            backgroundColor: ReaderTheme.greenDeep,
            color: ReaderTheme.gold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _opening(t),
          for (final dhikr in afterPrayerAdhkar) _card(dhikr, t),
          const SizedBox(height: 12),
          _reviewNote(t),
        ],
      ),
    );
  }

  Widget _opening(ReaderTheme t) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: ReaderTheme.green,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ReaderTheme.gold, width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Kitab-Bold',
                fontSize: _arabicSize * 0.85,
                height: 1.9,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              kSittingAfterPrayer,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, height: 1.55, fontSize: 14),
            ),
            const SizedBox(height: 6),
            const Text(
              kSittingAfterPrayerRef,
              style: TextStyle(color: ReaderTheme.goldSoft, fontSize: 12),
            ),
          ],
        ),
      );

  Widget _card(Dhikr dhikr, ReaderTheme t) {
    final said = _counts[dhikr.number] ?? 0;
    final done = said >= dhikr.count;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: done ? ReaderTheme.gold : t.divider, width: done ? 1.4 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? ReaderTheme.gold : ReaderTheme.green,
                  ),
                  child: done
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text('${dhikr.number}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dhikr.title,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: t.ink)),
                      const SizedBox(height: 2),
                      Text(
                        dhikr.count > 1
                            ? '${dhikr.when} · ${dhikr.count} times'
                            : dhikr.when,
                        style: TextStyle(fontSize: 12, color: t.inkSoft),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Text(dhikr.context,
                style: TextStyle(fontSize: 13, height: 1.5, color: t.inkSoft)),
          ),
          for (final passage in dhikr.passages) _passage(passage, t),
          if (dhikr.virtue != null)
            Container(
              margin: const EdgeInsets.fromLTRB(14, 4, 14, 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ReaderTheme.gold.withValues(alpha: t.dark ? 0.14 : 0.16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(dhikr.virtue!,
                  style: TextStyle(
                      fontSize: 13, height: 1.45, color: t.ink)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dhikr.grading == null
                        ? dhikr.reference
                        : '${dhikr.reference} · ${dhikr.grading}',
                    style: TextStyle(fontSize: 11, color: t.inkSoft),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.copy, size: 18, color: t.inkSoft),
                  onPressed: () => _copy(dhikr),
                ),
                IconButton(
                  tooltip: 'Share',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.share, size: 18, color: t.inkSoft),
                  onPressed: () => SharePlus.instance
                      .share(ShareParams(text: _plainText(dhikr))),
                ),
              ],
            ),
          ),
          // The counter every adhkar app needs and this one did not have.
          TasbihCounter(
            target: dhikr.count,
            value: said,
            onChanged: (v) => setState(() => _counts[dhikr.number] = v),
          ),
        ],
      ),
    );
  }

  Widget _passage(DhikrPassage passage, ReaderTheme t) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quranic passages are read from the app's own Quran data, so
            // they can never drift from the mushaf. The old page had them
            // retyped by hand, and Ayat al-Kursi was missing its first alif.
            _ArabicText(
              passage: passage,
              fontSize: _arabicSize,
            ),
            const SizedBox(height: 10),
            Text(passage.transliteration,
                style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: t.inkSoft)),
            const SizedBox(height: 6),
            Text(passage.translation,
                style: TextStyle(fontSize: 14.5, height: 1.55, color: t.ink)),
          ],
        ),
      );

  void _copy(Dhikr dhikr) {
    Clipboard.setData(ClipboardData(text: _plainText(dhikr)));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Copied')));
  }

  String _plainText(Dhikr dhikr) => [
        dhikr.title,
        for (final p in dhikr.passages) ...[
          p.arabic ?? '',
          p.transliteration,
          p.translation,
        ],
        dhikr.grading == null
            ? dhikr.reference
            : '${dhikr.reference} · ${dhikr.grading}',
        'Shared from Universal Quran',
      ].where((s) => s.isNotEmpty).join('\n\n');

  void _openSize() {
    final t = ReaderTheme.read(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: t.paper,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Arabic size',
                    style: TextStyle(fontSize: 17, color: t.ink)),
                Slider(
                  value: _arabicSize,
                  min: 18,
                  max: 44,
                  divisions: 13,
                  activeColor: ReaderTheme.green,
                  label: _arabicSize.round().toString(),
                  onChanged: (v) {
                    _setSize(v);
                    setSheet(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _reviewNote(ReaderTheme t) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          'References follow the printed hadith collections. If you find an '
          'error in the Arabic or an attribution, please tell us so it can be '
          'corrected.',
          style: TextStyle(fontSize: 12, height: 1.5, color: t.inkSoft),
        ),
      );
}

/// Draws a passage's Arabic, preferring the app's Quran data over anything
/// typed into the source.
class _ArabicText extends StatelessWidget {
  final DhikrPassage passage;
  final double fontSize;

  const _ArabicText({required this.passage, required this.fontSize});

  String? _fromQuranData() {
    if (passage.source != ArabicSource.quran) return null;
    final surahs = QuranData.instance.cached;
    if (surahs == null) return null;

    for (final surah in surahs) {
      if (surah.number != passage.surah) continue;
      final parts = <String>[];
      for (final ayah in surah.ayahs) {
        if (ayah.numberInSurah >= passage.ayahStart! &&
            ayah.numberInSurah <= passage.ayahEnd!) {
          parts.add(ayah.text);
        }
      }
      if (parts.isNotEmpty) return parts.join('  ');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = ReaderTheme.of(context);
    final text = _fromQuranData() ?? passage.arabic;
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: t.headerBand,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ReaderTheme.gold.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        // RTL direction, not just right alignment: the old page set
        // textAlign only, which misplaces punctuation in mixed text.
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontFamily: 'Kitab-Bold',
          fontSize: fontSize,
          height: 2.1,
          fontWeight: FontWeight.w600,
          color: t.ink,
        ),
      ),
    );
  }
}
