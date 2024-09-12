import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';




import 'package:quran_complete_ui/widget/widget_data.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


    runApp(const CompleteQuranApp());

}

class CompleteQuranApp extends StatelessWidget {
  const CompleteQuranApp({super.key});

  @override
  Widget build(BuildContext context) {


      return  MaterialApp(
        debugShowCheckedModeBanner: false,
        //color: backGroundColor,
        theme: ThemeData(
          brightness: Brightness.dark,
      
        ),
        home: ShowUpAnimation(child: const CoverPageDetail()),
      );
  }
}

class ShowUpAnimation extends StatefulWidget {
  final Widget child;

  int? delay;

  ShowUpAnimation({super.key, required this.child, this.delay});

  @override
  _ShowUpAnimationState createState() => _ShowUpAnimationState();
}

class _ShowUpAnimationState extends State<ShowUpAnimation>
    with TickerProviderStateMixin {
  late AnimationController animController;

  /// CREATING THE ANIMATION  VARIABLE OF TYPE OFFSET
  late Animation<Offset> animOffset;

  /// CREATING THE TIMER VARIABLE
  late Timer timer;

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
    super.dispose();
    animController.dispose();
    timer.cancel();
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