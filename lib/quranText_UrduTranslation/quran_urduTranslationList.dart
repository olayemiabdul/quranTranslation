import 'package:flutter/material.dart';

import '../quran_translation_package/quran_translationList.dart';

/// The Urdu entry point on the home grid.
///
/// This used to be about 600 lines: a second copy of the Translation reader
/// with `Urdu` typed in front of every class name. It carried its own copy
/// of every bug in the original, and any fix had to be made twice.
///
/// It is now the same reader opened in Urdu. The reader handles right-to-left
/// text, turns pages the other way, and sets the text in nastaliq rather than
/// a Latin face with no Urdu glyphs — which the old duplicate never did.
///
/// The class name is unchanged, so the home grid in `widget/widget_data.dart`
/// needs no edit.
class QuranUrduTranslationListPage extends StatelessWidget {
  const QuranUrduTranslationListPage({super.key});

  /// Used the first time only. After that the reader reopens on whichever
  /// Urdu translation was last chosen.
  static const String defaultUrduEdition = 'ur.jalandhry';

  @override
  Widget build(BuildContext context) {
    return const QuranTranslationListPage(
      language: 'ur',
      fallbackEdition: defaultUrduEdition,
      title: 'اردو ترجمہ',
    );
  }
}
