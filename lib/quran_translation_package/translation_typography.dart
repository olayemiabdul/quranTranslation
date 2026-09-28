import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Picks a typeface that can actually draw the edition's script.
///
/// This matters more than it sounds. A Latin face such as Noto Serif or
/// Inter has no Arabic or Urdu glyphs at all, so Urdu set in one falls back
/// glyph by glyph to whatever the phone happens to have — which on many
/// Android builds is a naskh face, not nastaliq. Urdu written in naskh is
/// legible but wrong, the way English set in blackletter is wrong.
///
/// Families are looked up by name rather than by a generated method, so a
/// different google_fonts version cannot break the build. An unknown family
/// falls back to the platform default instead of throwing.
class TranslationTypography {
  const TranslationTypography._();

  /// Scripts that run right to left.
  static const Set<String> rtlLanguages = {
    'ar', 'ur', 'fa', 'ps', 'sd', 'he', 'ug', 'dv', 'ku', 'yi',
  };

  static String languageOf(String edition) =>
      edition.split('.').first.toLowerCase();

  static bool isRtl(String edition) => rtlLanguages.contains(languageOf(edition));

  /// The family name for an edition's script, or null to keep the default.
  static String? _familyFor(String edition, {required bool serif}) {
    switch (languageOf(edition)) {
      case 'ur':
        // Urdu is written in nastaliq. Nothing else is right.
        return 'Noto Nastaliq Urdu';
      case 'ar':
      case 'fa':
      case 'ps':
      case 'sd':
      case 'ku':
      case 'ug':
        return serif ? 'Noto Naskh Arabic' : 'Noto Sans Arabic';
      case 'bn':
        return serif ? 'Noto Serif Bengali' : 'Noto Sans Bengali';
      case 'hi':
        return serif ? 'Noto Serif Devanagari' : 'Noto Sans Devanagari';
      case 'th':
        return serif ? 'Noto Serif Thai' : 'Noto Sans Thai';
      case 'ta':
        return serif ? 'Noto Serif Tamil' : 'Noto Sans Tamil';
      case 'ml':
        return serif ? 'Noto Serif Malayalam' : 'Noto Sans Malayalam';
      case 'ru':
      case 'uk':
      case 'bg':
      case 'sr':
      case 'az':
        // Cyrillic is covered by the Latin families below.
        return null;
      default:
        return null; // Latin and anything else
    }
  }

  /// Body style for this edition at the reader's chosen size and spacing.
  static TextStyle body(
    String edition, {
    required double fontSize,
    required double lineHeight,
    required Color color,
    required bool serif,
  }) {
    final base = TextStyle(
      fontSize: fontSize * sizeFactor(edition),
      height: minLineHeight(edition, lineHeight),
      color: color,
    );

    final family = _familyFor(edition, serif: serif);
    try {
      if (family != null) return GoogleFonts.getFont(family, textStyle: base);
      return serif
          ? GoogleFonts.notoSerif(textStyle: base)
          : GoogleFonts.inter(textStyle: base);
    } catch (_) {
      // Family not available in this google_fonts build, or offline on the
      // very first run. The platform default still renders the script.
      return base;
    }
  }

  /// Nastaliq hangs its words on a steep diagonal, so it needs far more room
  /// between lines than a Latin face. Anything under about 2.4 collides.
  static double minLineHeight(String edition, double chosen) =>
      languageOf(edition) == 'ur' ? (chosen < 2.4 ? 2.4 : chosen) : chosen;

  /// Nastaliq reads small at a nominal size; Arabic naskh slightly so.
  static double sizeFactor(String edition) {
    switch (languageOf(edition)) {
      case 'ur':
        return 1.25;
      case 'ar':
      case 'fa':
      case 'ps':
      case 'sd':
        return 1.12;
      default:
        return 1.0;
    }
  }

  /// Nastaliq's descenders get clipped by tight vertical padding.
  static EdgeInsets versePadding(String edition) =>
      languageOf(edition) == 'ur'
          ? const EdgeInsets.symmetric(vertical: 10)
          : const EdgeInsets.symmetric(vertical: 4);
}
