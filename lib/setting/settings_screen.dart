import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widget/contact_us_wideget.dart';



class SettingsPageScreen extends StatelessWidget {
  const SettingsPageScreen({super.key});



  Future<void> privacyPolicy() async {
    final Uri url = Uri.parse('https://doc-hosting.flycricket.io/universal-quran-privacy-policy/898af9c7-316f-442b-be86-3b1fc773f490/privacy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication); // Ensures it opens in a browser
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> termsOfService(BuildContext context) async {
    final Uri url = Uri.parse('https://doc-hosting.flycricket.io/universal-quran-terms-of-use/eecb3614-fa91-4a97-b04a-11f9044fa2b1/terms');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication); // Ensures it opens in a browser
    } else {
      throw 'Could not launch $url';
    }
  }



  rateUs() async {
    const url = 'https://play.google.com/store/apps/details?id=com.tunedtech.quran_complete_ui'; //  app's Play Store URL
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  contactUs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ContactUsPage()),
    );
  }

  shareApp(BuildContext context) {
    Share.share('https://play.google.com/store/apps/details?id=com.tunedtech.quran_complete_ui', // Replace with your app's Play Store URL
        subject: 'Share Our App');
  }


  deleteAccount(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Container(
            height: 120,
            width: 200,
            //color: Colors.white,
            child: Center(child: Text('Failed to delete account: $e')))),
      );
    }
  }

  logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully.')),
    );
    // Navigate to login screen if needed
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      //backgroundColor: const Color(0xFF402D45),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        //leading: const Icon(Icons.settings, ),
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('Privacy Policy'),
            onTap: () => privacyPolicy(),
          ),
          ListTile(
            title: const Text('Terms of Service'),
            onTap: () => termsOfService(context),
          ),
          ListTile(
            title: const Text('Rate Us'),
            onTap: rateUs,
          ),
          ListTile(
            title: const Text('Contact Us'),
            onTap: () => contactUs(context),
          ),
          ListTile(
            title: const Text('Share App'),
            onTap: () => shareApp(context),
          ),
          ListTile(
            title: const Text('Delete Account'),
            onTap: () => deleteAccount(context),
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () => logout(context),
          ),
        ],
      ),
    );
  }
}

