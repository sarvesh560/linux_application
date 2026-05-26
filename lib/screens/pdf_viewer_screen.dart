import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';


class PdfViewerScreen extends StatelessWidget {

  final PdfDocument document;
  final int pageNumber;

  const PdfViewerScreen({
    super.key,
    required this.document,
    required this.pageNumber,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(
          "Page $pageNumber",
        ),
      ),

      body: InteractiveViewer(

        minScale: .5,
        maxScale: 5,

        child: Center(

          child: PdfPageView(
            document: document,
            pageNumber: pageNumber,
          ),

        ),

      ),

    );
  }
}