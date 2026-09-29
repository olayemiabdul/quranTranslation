import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../quran_ayah/reader_theme.dart';
import 'hajj_widget.dart';

/// Hajj and Umrah.
///
/// The old version of this page was a sentence and a button that opened
/// someone else's website in the browser — with `EdgeInsets.only(top: 300)`,
/// which overflows on a small phone before it renders anything.
///
/// Meanwhile `hajj_widget.dart` holds 1,183 lines of an actual guide,
/// `HajjActivity`, and **nothing in the app imports it**. It was written and
/// never wired up, so no user has ever seen it. That guide is the page now.
/// The external link is kept, but as one row at the bottom rather than the
/// whole feature.
class HajjPage extends StatelessWidget {
  const HajjPage({super.key});

  static final Uri _plannerUrl = Uri.parse('https://hajjumrahplanner.com/');

  Future<void> _openPlanner(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final opened =
          await launchUrl(_plannerUrl, mode: LaunchMode.externalApplication);
      if (!opened) throw Exception('could not open');
    } catch (_) {
      // The old code threw a bare string here, which surfaces as a red
      // screen in debug and as nothing at all in release.
      messenger.showSnackBar(const SnackBar(
        content: Text('Could not open the browser on this device.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ReaderTheme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: t.paper,
        appBar: AppBar(
          backgroundColor: ReaderTheme.green,
          foregroundColor: Colors.white,
          title: const Text('Hajj & Umrah'),
          bottom: const TabBar(
            indicatorColor: ReaderTheme.gold,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Guide'),
              Tab(text: 'Before you travel'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // The guide that was already written and never reachable.
            const HajjActivity(),
            _beforeYouTravel(context, t),
          ],
        ),
      ),
    );
  }

  Widget _beforeYouTravel(BuildContext context, ReaderTheme t) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _section(t, 'Take with you', const [
            'Ihram garments, and a spare set',
            'Unscented soap and toiletries',
            'Comfortable sandals you can slip off',
            'A small bag you can wear across your body',
            'Any medication, in its original packaging',
            'A printed card with your hotel and group contact',
          ]),
          _section(t, 'While in ihram, avoid', const [
            'Perfume and scented products',
            'Cutting hair or nails',
            'Covering the head (men) or the face (women)',
            'Stitched clothing (men)',
            'Hunting, or helping someone hunt',
            'Marriage contracts, and intimacy',
          ]),
          _section(t, 'Worth knowing', const [
            'Phone signal is poor and expensive around the Haram. Download '
                'what you need before you travel — this app works offline.',
            'Distances are longer than they look. Give yourself time.',
            'Learn the talbiyah by heart before you go.',
          ]),
          const SizedBox(height: 8),
          Card(
            color: t.card,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: t.divider),
            ),
            child: ListTile(
              leading: const Icon(Icons.open_in_new, color: ReaderTheme.green),
              title: const Text('Hajj & Umrah Planner'),
              subtitle: Text(
                'An outside website with trip planning tools. Opens in your browser.',
                style: TextStyle(fontSize: 12, color: t.inkSoft),
              ),
              onTap: () => _openPlanner(context),
            ),
          ),
        ],
      );

  Widget _section(ReaderTheme t, String title, List<String> items) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: ReaderTheme.green)),
            const SizedBox(height: 8),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6, right: 10),
                      child: Icon(Icons.circle,
                          size: 6, color: ReaderTheme.gold),
                    ),
                    Expanded(
                      child: Text(item,
                          style: TextStyle(
                              fontSize: 14, height: 1.5, color: t.ink)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}
