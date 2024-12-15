import 'package:flutter/cupertino.dart';

class Responsive{
  static bool isMobile(BuildContext context){
    return MediaQuery.of(context).size.width<850;
  }

  static bool isTablet(BuildContext context){
    return MediaQuery.of(context).size.width<1100 &&
        MediaQuery.of(context).size.width>=850;
  }

  static bool isDesktop(BuildContext context){
    return
      MediaQuery.of(context).size.width>=1100;
  }
}