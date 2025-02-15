import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:universal_quran/constant.dart';


class CustomCard extends StatelessWidget {
  const CustomCard({super.key, required this.child, this.color, this.padding});
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 50,
      decoration: const BoxDecoration(
        // image: DecorationImage(
        //   image: const AssetImage('assets/images/mosque3.jpg'),
        //   fit: BoxFit.fill,
        //   colorFilter:
        //       ColorFilter.mode(Colors.white.withOpacity(1), BlendMode.dstATop),
        // ),
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
        //color:Color(0xff325444) ,
        color: cardBackgroundColor,
        //color:Color(0xff476E53),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}
