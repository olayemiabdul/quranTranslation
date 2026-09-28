import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:universal_quran/provider/theme_provider.dart';
import 'package:universal_quran/widget/widget_data.dart';


import 'firebase_options.dart';


import 'package:flutter/material.dart';





import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'azan/azan_service.dart';
import 'quran_byPage/quran_pages.dart' show bootQcfFonts;
import 'constant.dart';

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // One place owns notifications now (see azan/azan_service.dart).
  await AzanService.instance.init();
  // Refresh the week of adhan alarms in the background on every launch.
  unawaited(AzanService.instance.rescheduleFromSaved());
  // Unpack/load the Madinah Mushaf page fonts in the background.
  unawaited(bootQcfFonts());
  // Drop the caches of readers that have been replaced. Not awaited, so it
  // never delays the first frame.
  unawaited(_cleanUpLegacyCaches());

  // Add error handling for Firebase initialization
  try {
    if (Firebase.apps.isEmpty) {  // Only initialize if no Firebase app exists
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(ChangeNotifierProvider(
    create: (_) => ThemeNotifier(),
    child: const CompleteQuranApp(),
  ));
}

/// The old Urdu reader cached the whole Urdu Quran under
/// 'UrduTranslationData', the old Translation reader under
/// 'translationData', and the old page-by-page reader (replaced by the
/// Mushaf) under 'quranPageData'. Nothing reads them any more, but they sit
/// in SharedPreferences, which is loaded into memory whole on every launch.
Future<void> _cleanUpLegacyCaches() async {
  try {
    final p = await SharedPreferences.getInstance();
    if (p.getBool('legacy_cache_cleared_v2') == true) return;
    for (final key in const ['UrduTranslationData', 'translationData', 'quranPageData']) {
      await p.remove(key);
    }
    await p.setBool('legacy_cache_cleared_v2', true);
  } catch (e) {
    debugPrint('Legacy cache cleanup failed: $e');
  }
}

class CompleteQuranApp extends StatelessWidget {
  const CompleteQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier.themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(

          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(

          ),
          // A real dark theme, so default text, sheets and dialogs follow
          // ThemeNotifier instead of staying light in night mode.
          darkTheme: _darkTheme,
          themeMode: themeMode, // Set the theme based on the ValueNotifier
          home:const ShowUpAnimation(child:CoverPageDetail(),), // Main screen widget
        );
      },
    );
  }
}



final ThemeData _darkTheme = () {
  final base = ThemeData.dark();
  return base.copyWith(
    // A step lighter than backGroundColor, which the home cards use.
    scaffoldBackgroundColor: const Color(0xFF1E1B27),
    canvasColor: const Color(0xFF1E1B27),
    colorScheme: base.colorScheme.copyWith(
      primary: selectionColor,
      secondary: Colors.amber,
      surface: const Color(0xFF262233),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: homeContainerColor,
      foregroundColor: Colors.white,
    ),
  );
}();

class ShowUpAnimation extends StatefulWidget {
  final Widget child;
  final int? delay;

  const ShowUpAnimation({super.key, required this.child, this.delay});

  @override
  _ShowUpAnimationState createState() => _ShowUpAnimationState();
}

class _ShowUpAnimationState extends State<ShowUpAnimation>
    with TickerProviderStateMixin {
  late AnimationController animController;

  /// CREATING THE ANIMATION  VARIABLE OF TYPE OFFSET
  late Animation<Offset> animOffset;

  /// CREATING THE TIMER VARIABLE
  Timer? timer;

  @override
  void initState() {
    super.initState();

    animController = AnimationController(
        vsync: this, duration: const Duration(seconds: 1));
    final curve =
    CurvedAnimation(curve: Curves.decelerate, parent: animController);
    animOffset = Tween<Offset>(begin: const Offset(0.0, 0.35), end: Offset.zero)
        .animate(curve);

    if (widget.delay == null) {
      animController.forward();
    } else {
      timer = Timer(Duration(milliseconds: widget.delay!), () {
        animController.forward();
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel(); // was 'late' and crashed when no delay was set
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animController,
      child: SlideTransition(
        position: animOffset,
        child: widget.child,
      ),
    );
  }
}