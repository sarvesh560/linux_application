import 'package:flutter/material.dart';


class CropEditorOverlay extends StatefulWidget {

  final Rect? initialRect;
  final Function(Rect rect) onChanged;

  const CropEditorOverlay({
    super.key,
    this.initialRect,
    required this.onChanged,
  });

  @override
  State<CropEditorOverlay> createState() =>
      _CropEditorOverlayState();
}

class _CropEditorOverlayState
    extends State<CropEditorOverlay> {

  late Rect rect;

  @override
  void initState() {
    super.initState();

    rect =
        widget.initialRect ??
            const Rect.fromLTWH(
              40,
              40,
              120,
              180,
            );
  }

  void emitNormalized(Size size) {

    final normalized = Rect.fromLTWH(

      rect.left / size.width,
      rect.top / size.height,

      rect.width / size.width,
      rect.height / size.height,

    );

    widget.onChanged(normalized);
  }

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(

      builder: (_, constraints) {

        final size = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        return Stack(

          children: [

            Positioned(

              left: rect.left,
              top: rect.top,

              child: GestureDetector(

                onPanUpdate: (d) {

                  final left =
                  (rect.left + d.delta.dx)
                      .clamp(
                    0.0,
                    size.width - rect.width,
                  );

                  final top =
                  (rect.top + d.delta.dy)
                      .clamp(
                    0.0,
                    size.height - rect.height,
                  );

                  setState(() {

                    rect = Rect.fromLTWH(
                      left,
                      top,
                      rect.width,
                      rect.height,
                    );

                  });

                  emitNormalized(size);
                },

                child: Container(

                  width: rect.width,
                  height: rect.height,

                  decoration: BoxDecoration(

                    border: Border.all(
                      color: Colors.blue,
                      width: 2,
                    ),

                    color: Colors.blue.withOpacity(
                      .15,
                    ),

                  ),

                  child: Stack(

                    children: [

                      Positioned(

                        right: 0,
                        bottom: 0,

                        child: GestureDetector(

                          onPanUpdate: (d) {

                            setState(() {

                              rect =
                                  Rect.fromLTWH(

                                    rect.left,
                                    rect.top,

                                    (rect.width +
                                        d.delta.dx)
                                        .clamp(
                                      50.0,
                                      size.width -
                                          rect.left,
                                    ),

                                    (rect.height +
                                        d.delta.dy)
                                        .clamp(
                                      50.0,
                                      size.height -
                                          rect.top,
                                    ),

                                  );

                            });

                            emitNormalized(size);
                          },

                          child: const Icon(
                            Icons.open_in_full,
                            size: 18,
                          ),

                        ),

                      ),

                    ],

                  ),

                ),

              ),

            ),

          ],

        );

      },

    );

  }

}