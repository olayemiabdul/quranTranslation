import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../enum/reciter_list_enum.dart';
import '../enum/translator_list_enum.dart';
import 'mushaf_frame.dart';

enum AyahAction { playFromHere }

/// Long-press sheet: translation in the reader's chosen language, plus
/// listen, copy and share. Uses the Quran Cloud API the app already relies on.
class AyahSheet extends StatefulWidget {
  final int surah;
  final int ayah;
  const AyahSheet({super.key, required this.surah, required this.ayah});

  @override
  State<AyahSheet> createState() => _AyahSheetState();
}

class _AyahSheetState extends State<AyahSheet> {
  static const _kTranslation = 'mushaf_translation';
  static const _kReciter = 'mushaf_reciter';

  String _edition = 'en.sahih';
  String _reciter = 'ar.alafasy';
  String? _translation;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final p = await SharedPreferences.getInstance();
    _edition = p.getString(_kTranslation) ?? _edition;
    _reciter = p.getString(_kReciter) ?? _reciter;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _translation = null;
      _failed = false;
    });
    try {
      final res = await http
          .get(Uri.parse(
              'https://api.alquran.cloud/v1/ayah/${widget.surah}:${widget.ayah}/$_edition'))
          .timeout(const Duration(seconds: 15));
      final text = json.decode(res.body)['data']['text'] as String;
      if (mounted) setState(() => _translation = text);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  String get _arabic => getVerse(widget.surah, widget.ayah);
  String get _ref => '${getSurahNameEnglish(widget.surah)} ${widget.surah}:${widget.ayah}';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.black26, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Text(_ref,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600, color: MushafColors.greenDeep)),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(_arabic,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontFamily: 'UthmanTN2', fontSize: 24, height: 1.9)),
                  const Divider(height: 24, color: MushafColors.goldSoft),
                  if (_translation != null)
                    Text(_translation!,
                        style: const TextStyle(fontSize: 16, height: 1.55))
                  else if (_failed)
                    TextButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Translation needs internet. Try again'),
                    )
                  else
                    const LinearProgressIndicator(color: MushafColors.green),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: TranslatorName.values.any((t) => t.text == _edition) ? _edition : null,
              isExpanded: true,
              hint: const Text('Sahih International (English)'),
              decoration: const InputDecoration(
                  labelText: 'Translation', border: OutlineInputBorder(), isDense: true),
              items: TranslatorName.values
                  .map((t) => DropdownMenuItem(value: t.text, child: Text(t.label.trim())))
                  .toList(),
              onChanged: (v) async {
                if (v == null) return;
                _edition = v;
                (await SharedPreferences.getInstance()).setString(_kTranslation, v);
                _load();
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _reciter,
              isExpanded: true,
              decoration: const InputDecoration(
                  labelText: 'Reciter', border: OutlineInputBorder(), isDense: true),
              items: [
                const DropdownMenuItem(value: 'ar.alafasy', child: Text('Mishary Alafasy')),
                ...ReciterName.values
                    .where((r) => r.text != 'ar.alafasy')
                    .map((r) => DropdownMenuItem(value: r.text, child: Text(r.label))),
              ],
              onChanged: (v) async {
                if (v == null) return;
                setState(() => _reciter = v);
                (await SharedPreferences.getInstance()).setString(_kReciter, v);
              },
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: MushafColors.green),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Listen from here'),
                  onPressed: () => Navigator.pop(context, AyahAction.playFromHere),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                tooltip: 'Copy',
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _shareText));
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Ayah copied')));
                },
              ),
              IconButton.outlined(
                tooltip: 'Share',
                icon: const Icon(Icons.share),
                onPressed: () => SharePlus.instance.share(ShareParams(text: _shareText)),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  String get _shareText => [
        _arabic,
        if (_translation != null) _translation!,
        '($_ref)',
        'Shared from Universal Quran',
      ].join('\n\n');
}
