// download_surah.dart
//
// Downloads surahs from the AlQuran Cloud API, ayah by ayah:
//   - reciter audio (one MP3 per ayah)
//   - Uthmani Arabic text (Bismillah split off ayah 1 into its own field)
//   - translation
//   - the reciter's Bismillah audio, for an opening frame
//
// No packages needed. Run it with the Dart that ships with Flutter:
//
//   dart run download_surah.dart --surah 67
//   dart run download_surah.dart --surah 18,36,67,55 --reciter ar.minshawi
//   dart run download_surah.dart --surah 1-114 --translation en.pickthall
//
// Options:
//   --surah        one number, a list (18,67) or a range (1-114). Required.
//   --reciter      audio edition, default ar.alafasy
//   --translation  translation edition, default en.sahih
//   --bitrate      force a bitrate in the audio URL (64, 128, 192...).
//                  Leave it out to use whatever the API returns.
//   --out          output folder, default ./surahs
//   --parallel     simultaneous downloads, default 4
//
// Output, e.g. for Al-Mulk:
//   surahs/067_Al-Mulk/
//     manifest.json        everything the video step needs, in ayah order,
//                          including each clip's length in seconds
//     timings.txt          page-by-page lengths to type into Canva
//     audio/bismillah.mp3  (not for Al-Fatiha or At-Tawbah)
//     audio/001.mp3 ... audio/030.mp3
//
// Re-running is safe: files that already downloaded are skipped, so an
// interrupted run just picks up where it stopped. For a surah you already
// downloaded, running the same command again just adds the timings.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

const apiBase = 'https://api.alquran.cloud/v1';

class Options {
  List<int> surahs = [];
  String reciter = 'ar.alafasy';
  String translation = 'en.sahih';
  String? bitrate;
  String out = 'surahs';
  int parallel = 4;
}

final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);

Future<void> main(List<String> args) async {
  final Options o;
  try {
    o = parseArgs(args);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}\n');
    stderr.writeln('Usage: dart run download_surah.dart --surah 67 '
        '[--reciter ar.alafasy] [--translation en.sahih] [--bitrate 128] '
        '[--out surahs] [--parallel 4]');
    exit(64);
  }

  var failed = 0;
  for (final s in o.surahs) {
    try {
      await downloadSurah(s, o);
    } catch (e) {
      failed++;
      stderr.writeln('Surah $s failed: $e');
    }
  }
  client.close(force: true);

  if (failed > 0) {
    stderr.writeln('\n$failed surah(s) had errors. Run the same command '
        'again to retry; finished files are skipped.');
    exit(1);
  }
  print('\nDone.');
}

Future<void> downloadSurah(int s, Options o) async {
  final url = '$apiBase/surah/$s/editions/'
      '${o.reciter},quran-uthmani,${o.translation}';
  final json = jsonDecode(utf8.decode(await fetchBytes(url)));
  if (json['code'] != 200) {
    throw Exception('API returned ${json['code']}: ${json['data']}');
  }

  // Editions come back in the order requested.
  final data = json['data'] as List;
  final audioEd = data[0];
  final textEd = data[1];
  final transEd = data[2];

  final englishName = textEd['englishName'] as String;
  final dir = Directory(
      '${o.out}/${pad3(s)}_${englishName.replaceAll(RegExp(r"[^A-Za-z0-9\-]"), "")}');
  final audioDir = Directory('${dir.path}/audio');
  await audioDir.create(recursive: true);

  final audioAyahs = audioEd['ayahs'] as List;
  final textAyahs = textEd['ayahs'] as List;
  final transAyahs = transEd['ayahs'] as List;
  print('\n$s. $englishName (${textEd['name']}) — '
      '${textAyahs.length} ayat, ${o.reciter}');

  final downloads = <MapEntry<String, File>>[];
  final ayahs = <Map<String, dynamic>>[];
  String? bismillahText;

  for (var i = 0; i < textAyahs.length; i++) {
    final t = textAyahs[i];
    final n = t['numberInSurah'] as int;
    var arabic = (t['text'] as String).replaceAll('﻿', '').trim();

    // Surahs other than Al-Fatiha (1) and At-Tawbah (9) have the Bismillah
    // joined to the front of ayah 1 in the Uthmani text. Split it off.
    if (n == 1 && s != 1 && s != 9) {
      final split = splitBismillah(arabic);
      if (split != null) {
        bismillahText = split[0];
        arabic = split[1];
      }
    }

    final audioUrl = withBitrate(audioAyahs[i]['audio'] as String, o.bitrate);
    final file = File('${audioDir.path}/${pad3(n)}.mp3');
    downloads.add(MapEntry(audioUrl, file));

    ayahs.add({
      'numberInSurah': n,
      'globalNumber': t['number'],
      'arabic': arabic,
      'translation': transAyahs[i]['text'],
      'audio': 'audio/${pad3(n)}.mp3',
      'audioUrl': audioUrl,
    });
  }

  // The reciter's Bismillah is global ayah 1 (Al-Fatiha 1:1).
  Map<String, dynamic>? bismillah;
  if (s != 1 && s != 9) {
    final url = withBitrate(
        (audioAyahs[0]['audio'] as String)
            .replaceFirst(RegExp(r'/\d+\.mp3$'), '/1.mp3'),
        o.bitrate);
    downloads.add(MapEntry(url, File('${audioDir.path}/bismillah.mp3')));
    bismillah = {
      'arabic': bismillahText ?? 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
      'audio': 'audio/bismillah.mp3',
    };
  }

  var done = 0;
  await runPool(downloads, o.parallel, (d) async {
    await downloadFile(d.key, d.value);
    done++;
    stdout.write('\r  audio $done/${downloads.length}');
  });
  stdout.writeln();

  // Measure every clip so page lengths can be set exactly.
  for (final a in ayahs) {
    a['durationSeconds'] =
        round2(await mp3DurationSeconds(File('${dir.path}/${a['audio']}')));
  }
  if (bismillah != null) {
    bismillah['durationSeconds'] = round2(
        await mp3DurationSeconds(File('${dir.path}/${bismillah['audio']}')));
  }

  final manifest = {
    'surah': s,
    'name': textEd['name'],
    'englishName': englishName,
    'englishNameTranslation': textEd['englishNameTranslation'],
    'revelationType': textEd['revelationType'],
    'reciter': o.reciter,
    'reciterName': audioEd['edition']?['englishName'],
    'translation': o.translation,
    'translationName': transEd['edition']?['englishName'],
    'bismillah': bismillah,
    'ayahs': ayahs,
  };
  await File('${dir.path}/manifest.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert(manifest));
  await File('${dir.path}/timings.txt')
      .writeAsString(buildTimings(englishName, bismillah, ayahs));
  print('  saved to ${dir.path} (see timings.txt for Canva page lengths)');
}

/// A page-by-page list: page 1 is the Bismillah (when there is one), then one
/// page per ayah — the same layout as the Canva design.
String buildTimings(String surahName, Map<String, dynamic>? bismillah,
    List<Map<String, dynamic>> ayahs) {
  final b = StringBuffer()
    ..writeln('$surahName — page lengths for Canva')
    ..writeln('Type each "length" into that page\'s duration box.')
    ..writeln('"starts at" is where that page begins in the finished video.')
    ..writeln();
  var page = 1;
  var t = 0.0;
  void row(String label, String audio, double secs) {
    b.writeln('Page ${page.toString().padLeft(3)}   ${label.padRight(10)}  '
        'length ${secs.toStringAsFixed(1).padLeft(5)}s   '
        'starts at ${clock(t)}   ($audio)');
    page++;
    t += secs;
  }

  if (bismillah != null) {
    row('Bismillah', 'bismillah.mp3', bismillah['durationSeconds']);
  }
  for (final a in ayahs) {
    row('Ayah ${a['numberInSurah']}', (a['audio'] as String).split('/').last,
        a['durationSeconds']);
  }
  b
    ..writeln()
    ..writeln('Total recitation: ${clock(t)}  (${t.toStringAsFixed(1)}s)')
    ..writeln('Add your outro page after page ${page - 1}.');
  return b.toString();
}

String clock(double secs) {
  final m = secs ~/ 60;
  final s = secs - m * 60;
  return '${m.toString().padLeft(2, '0')}:${s.toStringAsFixed(1).padLeft(4, '0')}';
}

double round2(double x) => (x * 100).roundToDouble() / 100;

/// Length of an MP3 in seconds, worked out by walking its MPEG audio frames
/// (accurate for both constant and variable bitrate files, no packages).
Future<double> mp3DurationSeconds(File file) async {
  final d = await file.readAsBytes();
  var i = 0;

  // Skip an ID3v2 tag at the start, if present.
  if (d.length >= 10 && d[0] == 0x49 && d[1] == 0x44 && d[2] == 0x33) {
    final size =
    (d[6] & 0x7f) << 21 | (d[7] & 0x7f) << 14 | (d[8] & 0x7f) << 7 | (d[9] & 0x7f);
    i = 10 + size + ((d[5] & 0x10) != 0 ? 10 : 0);
  }

  const brV1 = [0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320];
  const brV2 = [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160];
  const srV1 = [44100, 48000, 32000];

  var seconds = 0.0;
  var first = true;
  while (i + 4 <= d.length) {
    if (d[i] != 0xFF || (d[i + 1] & 0xE0) != 0xE0) {
      i++; // not a frame header; resync
      continue;
    }
    final ver = (d[i + 1] >> 3) & 3; // 3 = MPEG1, 2 = MPEG2, 0 = MPEG2.5
    final layer = (d[i + 1] >> 1) & 3; // 1 = Layer III
    final brIdx = d[i + 2] >> 4;
    final srIdx = (d[i + 2] >> 2) & 3;
    final pad = (d[i + 2] >> 1) & 1;
    if (ver == 1 || layer != 1 || brIdx == 0 || brIdx == 15 || srIdx == 3) {
      i++;
      continue;
    }
    final mpeg1 = ver == 3;
    final bitrate = (mpeg1 ? brV1 : brV2)[brIdx] * 1000;
    final sr = srV1[srIdx] ~/ (mpeg1 ? 1 : (ver == 2 ? 2 : 4));
    final samples = mpeg1 ? 1152 : 576;
    final len = (samples ~/ 8) * bitrate ~/ sr + pad;
    if (len <= 4) {
      i++;
      continue;
    }

    // The first frame of many files is a "Xing"/"Info" header, not audio.
    var isInfo = false;
    if (first) {
      final head = String.fromCharCodes(
          d.sublist(i, i + len > d.length ? d.length : i + len)
              .map((c) => c < 128 ? c : 0));
      isInfo = head.contains('Xing') || head.contains('Info');
      first = false;
    }
    if (!isInfo) seconds += samples / sr;
    i += len;
  }
  return seconds;
}

/// Returns [bismillah, rest] if the text starts with the Bismillah, else null.
/// Compares letters with the harakat removed, so small differences in the
/// diacritics don't break the match.
List<String>? splitBismillah(String text) {
  final words = text.split(RegExp(r'\s+'));
  if (words.length <= 4) return null;
  if (bareLetters(words[0]) != 'بسم') return null;
  return [words.take(4).join(' '), words.skip(4).join(' ')];
}

String bareLetters(String s) => s
    .replaceAll(RegExp('[ؐ-ًؚ-ٰٟۖ-ۭ]'), '')
    .replaceAll('ٱ', 'ا');

String withBitrate(String url, String? bitrate) => bitrate == null
    ? url
    : url.replaceFirst(RegExp(r'/audio/\d+/'), '/audio/$bitrate/');

Future<void> downloadFile(String url, File file) async {
  if (await file.exists() && await file.length() > 0) return; // resume
  final part = File('${file.path}.part');
  await part.writeAsBytes(await fetchBytes(url));
  await part.rename(file.path);
}

Future<List<int>> fetchBytes(String url) async {
  for (var attempt = 1;; attempt++) {
    try {
      return await _get(url).timeout(const Duration(minutes: 2));
    } catch (e) {
      if (attempt >= 4) rethrow;
      stderr.writeln('\n  retry $attempt: $url ($e)');
      await Future.delayed(Duration(seconds: attempt * 3));
    }
  }
}

Future<List<int>> _get(String url) async {
  final req = await client.getUrl(Uri.parse(url));
  final res = await req.close();
  if (res.statusCode != 200) {
    await res.drain<void>();
    throw HttpException('HTTP ${res.statusCode}', uri: Uri.parse(url));
  }
  final bytes = <int>[];
  await for (final chunk in res) {
    bytes.addAll(chunk);
  }
  return bytes;
}

Future<void> runPool<T>(
    List<T> items, int workers, Future<void> Function(T) task) async {
  var next = 0;
  Future<void> worker() async {
    while (next < items.length) {
      await task(items[next++]);
    }
  }

  await Future.wait(List.generate(workers, (_) => worker()));
}

String pad3(int n) => n.toString().padLeft(3, '0');

Options parseArgs(List<String> args) {
  final o = Options();
  for (var i = 0; i < args.length; i++) {
    final key = args[i];
    if (i + 1 >= args.length) throw FormatException('$key needs a value');
    final value = args[++i];
    switch (key) {
      case '--surah':
        o.surahs = parseSurahs(value);
      case '--reciter':
        o.reciter = value;
      case '--translation':
        o.translation = value;
      case '--bitrate':
        o.bitrate = value;
      case '--out':
        o.out = value;
      case '--parallel':
        o.parallel = int.parse(value).clamp(1, 16);
      default:
        throw FormatException('Unknown option $key');
    }
  }
  if (o.surahs.isEmpty) throw const FormatException('--surah is required');
  return o;
}

List<int> parseSurahs(String v) {
  final result = <int>{};
  for (final part in v.split(',')) {
    final range = part.trim().split('-');
    final a = int.parse(range[0]);
    final b = range.length > 1 ? int.parse(range[1]) : a;
    for (var n = a; n <= b; n++) {
      if (n < 1 || n > 114) throw FormatException('Surah $n is out of range');
      result.add(n);
    }
  }
  return result.toList()..sort();
}