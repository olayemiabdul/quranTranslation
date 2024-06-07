import 'dart:convert';
import 'dart:ui';
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_complete_ui/quran_translation_package/quran_translation_text.dart';

import '../constant.dart';
import '../reciter_class/reciter_list.dart';

class QuranByPages extends StatefulWidget {
  const QuranByPages({super.key});

  @override
  _QuranByPagesState createState() => _QuranByPagesState();
}

class _QuranByPagesState extends State<QuranByPages> {
  List<dynamic> quranTranslateData = [];
  final TextEditingController colorController = TextEditingController();
  final TextEditingController textEditingController = TextEditingController();
  ArabicNumbers arabicNumber = ArabicNumbers();

  TranslatorName? selectedReciter;
  List<String> pageUrls = [];
  int totalPages= 610;

  @override
  void initState() {
    super.initState();

    getQuranTranslationData();
  }

  Future<void> getQuranTranslationData() async {
    final response = await http
        .get(Uri.parse('https://api.alquran.cloud/v1/page/1/quran-uthmani'));
    if (response.statusCode == 200) {
      setState(() {
        quranTranslateData = json.decode(response.body)['data']['ayahs'];
      });
    } else {
      throw Exception('Failed to load Quran data');
    }
  }

  Future<void> getQuranTranslationReciter(int pageNumber) async {
    final response = await http.get(Uri.parse(
        'https://api.alquran.cloud/v1/page/$pageNumber/quran-uthmani'));
    if (response.statusCode == 200) {

      setState(() {
        quranTranslateData = json.decode(response.body)['data']['ayahs'];

        activePage = pageNumber;
        //pageUrls = List.generate(totalPages, (index) => "https://api.alquran.cloud/v1/page/${index + 1}/quran-uthmani");
      });
    } else {
      throw Exception('Failed to load Quran data');
    }
  }

  final PageController pageController = PageController();
  int activePage = 1;

  void onNextPage() {
    if (activePage < quranTranslateData.length) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,

      body: quranTranslateData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Container(
        height: MediaQuery.of(context).size.height,
        decoration:  const BoxDecoration(

          color: gridContainerColor,


          //color:gridContainerColor,
        ),

            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            getQuranTranslationReciter(activePage -1);
                          });
                        },
                        child: const Text('PreviousPage')),
                    const SizedBox(width: 20,),
                    Text('Page ${activePage.toString()}', style: const TextStyle(color: Colors.white),),
                    const SizedBox(width: 20,),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            getQuranTranslationReciter(activePage + 1);
                          });
                        },
                        child: const Text('NextPage')),
                  ],
                ),
                SizedBox(
                  height: 50,
                  width: 150,
                  child: TextField(
                    onChanged: (value){
                      setState(() {
                        //value=activePage.toString();
                        getQuranTranslationReciter(int.parse(value));

                      });
                    },
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                    ),
                    decoration: InputDecoration(
                      labelText: "Goto",
                      hintText: 'Enter Page number (1-604)',
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.amber,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      // prefixIcon: const Icon(
                      //   Icons.lock_outline,
                      // ),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: quranTranslateData.length,
                    shrinkWrap: false,
                    physics: const ScrollPhysics(),
                 //scrollDirection: Axis.horizontal,
                    controller: pageController,
                    // onPageChanged: (int page) {
                    //   setState(() {
                    //     //activePage = page;
                    //     activePage=page++;
                    //     getQuranTranslationReciter(activePage+1);
                    //
                    //   });
                    // },

                    itemBuilder: (context, index) {
                      final translatedtext = quranTranslateData[index];

                      //final utmaniayah=quranData[index]

                      return Card(
                        color: gridContainerColor,
                        child: ListTile(
                          title: Text(translatedtext["text"] ,  style: const TextStyle(
                              //wordSpacing: 2,


                              fontFamily: 'Kitab-Bold',
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: 30),
                              textAlign: TextAlign.right,),

                          leading:   Container(
                            alignment: Alignment.center,
                            height: 35,
                            width: 35,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: Text(
                              arabicNumber.convert( translatedtext['numberInSurah'].toString()),
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),

                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Text(' ${activePage.toString()}', style: const TextStyle(color: Colors.white),),
              ],
            ),
          ),
    );
  }
}
