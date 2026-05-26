import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';


class PageThumbnail extends StatelessWidget {

  final PdfDocument document;
  final int pageNumber;
  final bool selected;
  final VoidCallback onTap;

  const PageThumbnail({
    super.key,
    required this.document,
    required this.pageNumber,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap:onTap,

      child: Stack(

        children: [

          AnimatedContainer(

            duration: const Duration(
              milliseconds:200,
            ),

            decoration: BoxDecoration(

              border: Border.all(

                color: selected
                    ? Colors.blue
                    : Colors.grey,

                width:selected
                    ?4
                    :1,

              ),

              borderRadius:
              BorderRadius.circular(
                  10),

            ),

            child: Card(

              child: Column(

                children: [

                  Expanded(

                    child: ClipRRect(

                      borderRadius:
                      BorderRadius.circular(
                          8),

                      child: PdfPageView(
                        document: document,
                        pageNumber: pageNumber,
                      ),

                    ),

                  ),

                  Padding(

                    padding:
                    const EdgeInsets.all(
                        8),

                    child: Text(
                      "Page $pageNumber",
                    ),

                  )

                ],

              ),

            ),

          ),

          if(selected)

            const Positioned(

              top:10,
              right:10,

              child: CircleAvatar(

                radius:14,

                backgroundColor:
                Colors.blue,

                child: Icon(
                  Icons.check,
                  size:18,
                ),

              ),

            )

        ],

      ),

    );

  }

}