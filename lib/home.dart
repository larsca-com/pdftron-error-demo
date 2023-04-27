import 'package:flutter/material.dart';
import 'package:pdftron_error_demo/pdf_carousel.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Photos without annotation'),
            onTap: () {
              navigateToView(
                context,
                PdfCarousel(
                  items: List.generate(
                    40,
                    (index) => PdfCarouselItem(
                      path: 'https://picsum.photos/id/$index/800/800',
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<dynamic> navigateToView(BuildContext context, Widget view) async {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return view;
      },
    ));
  }
}
