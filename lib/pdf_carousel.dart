import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';

class PdfCarouselItem {
  final String path;
  final String? annotation;

  PdfCarouselItem({required this.path, this.annotation});
}

class PdfCarousel extends StatefulWidget {
  final List<PdfCarouselItem> items;
  const PdfCarousel({super.key, required this.items});

  @override
  State<PdfCarousel> createState() => _PdfCarouselState();
}

class _PdfCarouselState extends State<PdfCarousel> {
  late final PageController pageController;
  bool loading = false;
  bool photoInitialized = false;
  int currentPage = 0;

  @override
  void initState() {
    pageController = PageController(initialPage: 0);
    currentPage = 0;
    loading = false;
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = Stack(
      children: [
        Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: PageView.builder(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return buildPdfPreview(context, item);
            },
            onPageChanged: (value) {
              setState(() {
                currentPage = value;
              });
            },
          ),
        ),
        if (widget.items.length > 1 && currentPage < widget.items.length - 1)
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 60,
              height: 56,
              child: buildArrowButton(
                context,
                onPressed: onRightArrowPressed,
                icon: const Icon(
                  Icons.arrow_forward_ios_sharp,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ),
        if (widget.items.length > 1 && currentPage > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 60,
              height: 56,
              child: buildArrowButton(
                context,
                onPressed: onLeftArrowPressed,
                icon: const Icon(
                  Icons.arrow_back_ios_sharp,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ),
        if (loading)
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 2,
              sigmaY: 2,
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
    return IgnorePointer(
      ignoring: !photoInitialized,
      child: Scaffold(
        appBar: AppBar(title: const Text('Previews')),
        body: body,
        backgroundColor: Colors.black,
      ),
    );
  }

  Widget buildPdfPreview(
    BuildContext context,
    PdfCarouselItem item,
  ) {
    return DocumentView(
      key: Key('ItemPreview${item.hashCode}'),
      onCreated: (controller) async {
        final config = Config();
        config.autoSaveEnabled = false;
        config.hideTopToolbars = true;
        config.continuousAnnotationEditing = false;
        config.readOnly = true;
        config.showLeadingNavButton = false;
        config.hideBottomToolbar = true;
        await controller.openDocument(
          item.path,
          config: config,
        );
        final annotation = item.annotation;
        if (annotation != null) {
          try {
            await controller.importAnnotations(annotation);
          } catch (e) {
            log('Error while importing annotation');
            log(e.toString());
          }
        }
        setState(() {
          photoInitialized = true;
        });
      },
    );
  }

  Widget buildArrowButton(
    BuildContext context, {
    required void Function() onPressed,
    required Icon icon,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size.square(44),
        maximumSize: const Size.square(44),
      ),
      onPressed: photoInitialized ? onPressed : null,
      child: Center(child: icon),
    );
  }

  void onRightArrowPressed() {
    setState(() {
      photoInitialized = false;
    });
    pageController.animateToPage(
      currentPage + 1,
      duration: kTabScrollDuration,
      curve: Curves.easeIn,
    );
  }

  void onLeftArrowPressed() {
    setState(() {
      photoInitialized = false;
    });
    pageController.animateToPage(
      currentPage - 1,
      duration: kTabScrollDuration,
      curve: Curves.easeIn,
    );
  }
}
