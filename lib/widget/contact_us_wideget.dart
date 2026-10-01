import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: confirm the support inbox before release.
const String _supportEmail = 'support@example.com';
const String _subject = 'Universal Quran feedback';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  String get _body => '${messageController.text}\n\n'
      '— ${nameController.text} <${emailController.text}>';

  // Hands the message to the user's mail app. If there is none, the message
  // is copied to the clipboard and the address shown so it can be sent by hand.
  Future<void> sendMessage() async {
    if (!formKey.currentState!.validate()) return;
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      // Built by hand: Uri's queryParameters encodes spaces as '+', which
      // most mail apps show literally.
      query: 'subject=${Uri.encodeComponent(_subject)}'
          '&body=${Uri.encodeComponent(_body)}',
    );
    bool opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!mounted) return;
    if (opened) {
      nameController.clear();
      emailController.clear();
      messageController.clear();
      return;
    }
    await Clipboard.setData(
        ClipboardData(text: 'To: $_supportEmail\nSubject: $_subject\n\n$_body'));
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No email app found'),
        content: const SelectableText(
          'Your message has been copied to the clipboard. '
          'Please paste it into an email to $_supportEmail.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // A fixed light design: pin the light theme so a dark app theme cannot
  // turn its default-coloured text white on these light surfaces.
  @override
  Widget build(BuildContext context) =>
      Theme(data: ThemeData.light(), child: Builder(builder: _buildLight));

  Widget _buildLight(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;


    double containerWidth = screenWidth < 850
        ? screenWidth * 0.9
        : screenWidth < 1100
        ? screenWidth * 0.6
        : screenWidth * 0.4;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: containerWidth,
            margin: const EdgeInsets.symmetric(vertical: 20),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 5),
                  blurRadius: 10,
                  spreadRadius: 1,
                  color: Colors.grey[300]!,
                )
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins ExtraBold',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Name',
                      prefixIcon: Icon(Icons.person, color: Colors.purple),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your name'
                        : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.mail, color: Colors.purple),
                    ),
                    validator: (email) {
                      if (email == null || email.isEmpty) {
                        return 'Please enter your email';
                      } else if (!EmailValidator.validate(email)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color(0xFF000000),
                        ),
                      ),
                      prefixIcon: const Icon(Icons.message, color: Colors.purple),
                    ),
                    maxLines: 5,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your message'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    width: 180,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xff151534),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      onPressed: sendMessage,
                      child: const Text('Open in email',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
