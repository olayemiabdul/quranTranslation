import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/theme_provider.dart';

/// Shared palette for both readers, so the Mushaf and Easy Read feel like
/// one app. Green and gold from the printed Madinah Mushaf.
///
/// Dark mode comes from [ThemeNotifier], which also drives `themeMode` in
/// `main.dart`, so this palette and the framework theme always agree.
class ReaderTheme {
  final bool dark;
  const ReaderTheme(this.dark);

  static const green = Color(0xFF1F5E3B);
  static const greenLight = Color(0xFF2F7A4A);
  static const gold = Color(0xFFC9A227);
  static const goldSoft = Color(0xFFE8D48A);

  /// Reading surface. Warm paper by day, soft ink at night — never pure
  /// black on pure white, which is tiring over a long session.
  Color get paper => dark ? const Color(0xFF12171B) : const Color(0xFFFBF7EC);
  Color get ink => dark ? const Color(0xFFEDE7D8) : const Color(0xFF1A1A1A);
  Color get inkSoft => dark ? const Color(0xFF9FA8A2) : const Color(0xFF6B6B6B);
  Color get divider => dark ? const Color(0xFF2A3239) : const Color(0xFFE6DFC9);
  Color get headerBand => dark ? const Color(0xFF17251D) : const Color(0xFFF1EAD6);
  Color get card => dark ? const Color(0xFF1A2026) : Colors.white;
  Color get highlight =>
      dark ? gold.withValues(alpha: 0.22) : gold.withValues(alpha: 0.30);

  /// Watches the notifier, so toggling the theme repaints the reader.
  static ReaderTheme of(BuildContext context) => ReaderTheme(
        context.watch<ThemeNotifier>().themeModeNotifier.value == ThemeMode.dark,
      );

  /// Same palette without subscribing — for callbacks and sheets.
  static ReaderTheme read(BuildContext context) => ReaderTheme(
        context.read<ThemeNotifier>().themeModeNotifier.value == ThemeMode.dark,
      );
}
