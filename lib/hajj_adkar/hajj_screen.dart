import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';



class HajjPage extends StatefulWidget {
  const HajjPage({super.key});

  @override
  State<HajjPage> createState() => _HajjPageState();
}

class _HajjPageState extends State<HajjPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //title: 'Hajj Guide',
      home: Scaffold(
        appBar: AppBar(
          //title: const Text('A-Z Hajj Guide,\nShehu Abdus-Salam Aladodo'),
        ),
        body: Expanded(child: SfPdfViewer.asset('assets/sounds/hajj.pdf')),
      ),
    );
  }
}