import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:url_launcher/url_launcher.dart';

class HajjPage extends StatefulWidget {
  const HajjPage({super.key});

  @override
  State<HajjPage> createState() => _HajjPageState();
}

class _HajjPageState extends State<HajjPage> {
  Future<void> HajjUmrah() async {
    final Uri url = Uri.parse('https://hajjumrahplanner.com/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url,
          mode:
              LaunchMode.externalApplication); // Ensures it opens in a browser
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hajj & Um-rah Guide'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 300, left: 16, right: 16),
        child: Column(
          children: [
            Center(
              child: Text(
                'Visit Hajj & Umrah Planner: An online platform dedicated to assisting pilgrims planning to perform Hajj and Umrah.',
                style: GoogleFonts.lateef(
                  textStyle: Theme.of(context).textTheme.displayLarge,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () => HajjUmrah(), child: const Text('Click here'))
          ],
        ),
      ),

      // Expanded(child: SfPdfViewer.asset('assets/sounds/hajj.pdf')),
    );
  }
}
