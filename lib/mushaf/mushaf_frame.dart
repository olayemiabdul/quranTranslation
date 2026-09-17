import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Colours taken from the printed King Fahd (Madinah) Mushaf.
class MushafColors {
  static const paper = Color(0xFFFFFCF0);
  static const paperDark = Color(0xFF14201A);
  static const green = Color(0xFF2F7A4A);
  static const greenDeep = Color(0xFF1C4F30);
  static const gold = Color(0xFFC9A227);
  static const goldSoft = Color(0xFFE8D48A);
  static const ink = Color(0xFF1A1A1A);
}

/// Wraps the page area in the green-and-gold border of the Madinah Mushaf.
class MushafFrame extends StatelessWidget {
  final Widget child;
  final bool dark;
  const MushafFrame({super.key, required this.child, this.dark = false});

  static const double band = 14; // width of the patterned border

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FramePainter(dark: dark),
      child: Padding(
        padding: const EdgeInsets.all(band + 6),
        child: child,
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  final bool dark;
  _FramePainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    const b = MushafFrame.band;
    final outer = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(6));
    final inner = RRect.fromRectAndRadius(
        Rect.fromLTWH(b, b, size.width - 2 * b, size.height - 2 * b), const Radius.circular(3));

    // Page paper
    canvas.drawRRect(inner, Paint()..color = dark ? MushafColors.paperDark : MushafColors.paper);

    // Green band
    final bandPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(outer)
      ..addRRect(inner);
    canvas.drawPath(bandPath, Paint()..color = MushafColors.green);

    // Repeating gold lozenges along the band
    final motif = Paint()..color = MushafColors.goldSoft;
    final dot = Paint()..color = MushafColors.greenDeep;
    void lozenge(Offset c) {
      const r = b * 0.34;
      final p = Path()
        ..moveTo(c.dx, c.dy - r)
        ..lineTo(c.dx + r, c.dy)
        ..lineTo(c.dx, c.dy + r)
        ..lineTo(c.dx - r, c.dy)
        ..close();
      canvas.drawPath(p, motif);
      canvas.drawCircle(c, r * 0.28, dot);
    }

    const step = b * 1.1;
    for (double x = b * 1.5; x < size.width - b; x += step) {
      lozenge(Offset(x, b / 2));
      lozenge(Offset(x, size.height - b / 2));
    }
    for (double y = b * 1.5; y < size.height - b; y += step) {
      lozenge(Offset(b / 2, y));
      lozenge(Offset(size.width - b / 2, y));
    }

    // Gold rules on both edges of the band
    final rule = Paint()
      ..color = MushafColors.gold
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(outer.deflate(0.75), rule..strokeWidth = 1.5);
    canvas.drawRRect(inner.inflate(0.75), rule..strokeWidth = 1.5);
    canvas.drawRRect(inner.deflate(3), rule..strokeWidth = 0.6);

    // Corner rosettes
    for (final c in [
      const Offset(b / 2, b / 2),
      Offset(size.width - b / 2, b / 2),
      Offset(b / 2, size.height - b / 2),
      Offset(size.width - b / 2, size.height - b / 2),
    ]) {
      _rosette(canvas, c, b * 0.62);
    }
  }

  void _rosette(Canvas canvas, Offset c, double r) {
    final petal = Paint()..color = MushafColors.gold;
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * r * 0.55, r * 0.3, petal);
    }
    canvas.drawCircle(c, r * 0.4, Paint()..color = MushafColors.greenDeep);
    canvas.drawCircle(c, r * 0.18, petal);
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.dark != dark;
}

/// The small medallion that holds the page number at the foot of the page.
class PageMedallion extends StatelessWidget {
  final String text;
  const PageMedallion(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: MushafColors.green,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MushafColors.gold, width: 1.5),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontFamily: 'UthmanTN2', fontSize: 15, height: 1.4)),
    );
  }
}

String toArabicDigits(int n) {
  const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return n.toString().split('').map((c) => d[int.parse(c)]).join();
}

const List<String> juzNamesArabic = [
  'الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس', 'السادس', 'السابع', 'الثامن',
  'التاسع', 'العاشر', 'الحادي عشر', 'الثاني عشر', 'الثالث عشر', 'الرابع عشر',
  'الخامس عشر', 'السادس عشر', 'السابع عشر', 'الثامن عشر', 'التاسع عشر', 'العشرون',
  'الحادي والعشرون', 'الثاني والعشرون', 'الثالث والعشرون', 'الرابع والعشرون',
  'الخامس والعشرون', 'السادس والعشرون', 'السابع والعشرون', 'الثامن والعشرون',
  'التاسع والعشرون', 'الثلاثون',
];
