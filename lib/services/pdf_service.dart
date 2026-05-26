// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui';
// import 'package:file_picker/file_picker.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart' as sync;
//
//
//
// class PdfService {
//
//   Future<String?> pickPdf() async {
//
//     FilePickerResult? result =
//     await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf'],
//     );
//
//     if(result==null){
//       return null;
//     }
//
//     return result.files.single.path;
//   }
//
//   Future<String?> savePdfDialog() async {
//
//     String? outputPath=
//     await FilePicker.platform.saveFile(
//
//       dialogTitle:'Save PDF',
//
//       fileName:
//       'Merged_document.pdf',
//
//       type:FileType.custom,
//
//       allowedExtensions:['pdf'],
//
//     );
//
//     return outputPath;
//   }
//
//   Future<void> splitPdf({
//
//     required String sourcePath,
//     required List<int> selectedPages,
//     required String outputPath,
//
//   }) async {
//
//     final File sourceFile=
//     File(sourcePath);
//
//     final Uint8List bytes=
//     await sourceFile.readAsBytes();
//
//     final PdfDocument sourceDocument=
//     PdfDocument(inputBytes:bytes);
//
//     final PdfDocument newDocument=
//     PdfDocument();
//
//     for(
//     int pageNumber
//     in selectedPages
//     ){
//
//       newDocument.pages
//           .add()
//           .graphics
//           .drawPdfTemplate(
//
//         sourceDocument
//             .pages[pageNumber-1]
//             .createTemplate(),
//
//         const Offset(0,0),
//
//       );
//
//     }
//
//     List<int> saveBytes=
//     await newDocument.save();
//
//     File outputFile=
//     File(outputPath);
//
//     await outputFile.writeAsBytes(
//       saveBytes,
//     );
//
//     newDocument.dispose();
//
//     sourceDocument.dispose();
//
//   }
//
//   Future<List<String>> pickMultiplePdfs() async {
//
//     FilePickerResult? result=
//     await FilePicker.platform.pickFiles(
//
//       allowMultiple:true,
//
//       type:FileType.custom,
//
//       allowedExtensions:['pdf'],
//
//     );
//
//     if(result==null){
//       return [];
//     }
//
//     return result.paths
//         .whereType<String>()
//         .toList();
//
//   }
//
//   Future<void> mergePdfs({
//     required List<String> files,
//     required String outputPath,
//   }) async {
//
//     final sync.PdfDocument output = sync.PdfDocument();
//
//     for (final path in files) {
//
//       final input = sync.PdfDocument(
//         inputBytes: await File(path).readAsBytes(),
//       );
//
//       for (int i = 0; i < input.pages.count; i++) {
//
//         final page = input.pages[i];
//
//         final newPage = output.pages.add();
//
//         final template = page.createTemplate();
//
//         newPage.graphics.drawPdfTemplate(
//           template,
//           const Offset(0, 0),
//         );
//       }
//
//       input.dispose();
//     }
//
//     final bytes = await output.save();
//     await File(outputPath).writeAsBytes(bytes);
//     output.dispose();
//   }
//
//   Future<void> purgeMetadata({
//     required String sourcePath,
//     required String outputPath,
//   }) async {
//
//     final inputBytes = await File(sourcePath).readAsBytes();
//
//     final document = sync.PdfDocument(inputBytes: inputBytes);
//
//     document.documentInformation.title = '';
//     document.documentInformation.author = '';
//     document.documentInformation.subject = '';
//     document.documentInformation.keywords = '';
//
//     document.documentInformation.creator = '';
//     document.documentInformation.producer = '';
//
//
//     final bytes = await document.save();
//     await File(outputPath).writeAsBytes(bytes);
//
//     document.dispose();
//   }
//
//   Future<void> rotatePages({
//     required String sourcePath,
//     required List<int> pagesToRotate,
//     required String outputPath,
//     required int angle, // 90 or -90
//   }) async {
//
//     final bytes = await File(sourcePath).readAsBytes();
//     final document = sync.PdfDocument(inputBytes: bytes);
//
//     for (final pageNumber in pagesToRotate) {
//
//       final page = document.pages[pageNumber - 1];
//
//       // convert enum safely using current rotation index
//       final current = page.rotation.index;
//
//       int newRotationIndex;
//
//       if (angle > 0) {
//         newRotationIndex = (current + 1) % 4;
//       } else {
//         newRotationIndex = (current - 1) % 4;
//         if (newRotationIndex < 0) newRotationIndex = 3;
//       }
//
//       page.rotation = sync.PdfPageRotateAngle.values[newRotationIndex];
//     }
//
//     final saved = await document.save();
//     await File(outputPath).writeAsBytes(saved);
//
//     document.dispose();
//   }
//
//   Future<void> applyCrop({
//     required String sourcePath,
//     required Map<int, Rect> cropMap,
//     required String outputPath,
//   }) async {
//
//     final bytes = await File(sourcePath).readAsBytes();
//     final sourceDoc = sync.PdfDocument(inputBytes: bytes);
//     final outputDoc = sync.PdfDocument();
//
//     for (int i = 0; i < sourceDoc.pages.count; i++) {
//
//       final pageNumber = i + 1;
//       final sourcePage = sourceDoc.pages[i];
//
//       final template = sourcePage.createTemplate();
//       final newPage = outputDoc.pages.add();
//
//       final pageSize = sourcePage.size;
//
//       if (cropMap.containsKey(pageNumber)) {
//
//         final rect = cropMap[pageNumber]!;
//
//         final pdfRect = Rect.fromLTWH(
//           rect.left,
//           pageSize.height - rect.bottom,
//           rect.width,
//           rect.height,
//         );
//
//         newPage.graphics.drawPdfTemplate(
//           template,
//           Offset(-pdfRect.left, -pdfRect.top),
//         );
//
//       } else {
//
//         // no crop → copy full page
//         newPage.graphics.drawPdfTemplate(
//           template,
//           const Offset(0, 0),
//         );
//       }
//     }
//
//     final saved = await outputDoc.save();
//     await File(outputPath).writeAsBytes(saved);
//
//     sourceDoc.dispose();
//     outputDoc.dispose();
//   }
//
// }

import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sync;

typedef ProgressCallback=
void Function(double progress);


class PdfService {

  /// -------------------------
  /// SAFE FILE PICK
  /// -------------------------
  Future<String?> pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      return result?.files.single.path;
    } catch (e) {
      return null;
    }
  }


  Future<void> validateOutput(
      String path,
      bool overwrite,
      ) async {

    final file=File(path);

    if(
    await file.exists()
        &&
        !overwrite
    ){

      throw Exception(
          "File already exists"
      );

    }

  }

  Future<void> deletePages({

    required String sourcePath,
    required List<int> pages,
    required String outputPath,
    ProgressCallback? onProgress,

  }) async {

    final source=
    sync.PdfDocument(
      inputBytes:
      await File(
        sourcePath,
      ).readAsBytes(),
    );

    final output=
    sync.PdfDocument();

    try{

      for(
      int i=0;
      i<source.pages.count;
      i++
      ){

        final pageNo=i+1;

        if(
        pages.contains(
          pageNo,
        )
        ){
          continue;
        }

        final template=
        source.pages[i]
            .createTemplate();

        final page=
        output.pages.add();

        page.graphics.drawPdfTemplate(
          template,
          Offset.zero,
        );

        onProgress?.call(
          (i+1)
              /source.pages.count,
        );

      }

      await File(
        outputPath,
      ).writeAsBytes(
        await output.save(),
      );

    }
    finally{

      source.dispose();
      output.dispose();

    }

  }

  Future<void> duplicatePages({

    required String sourcePath,
    required List<int> pages,
    required String outputPath,
    ProgressCallback? onProgress,

  }) async {

    final source=
    sync.PdfDocument(
      inputBytes:
      await File(
        sourcePath,
      ).readAsBytes(),
    );

    final output=
    sync.PdfDocument();

    try{

      for(
      int i=0;
      i<source.pages.count;
      i++
      ){

        final current=
        source.pages[i];

        final template=
        current.createTemplate();

        final page=
        output.pages.add();

        page.graphics.drawPdfTemplate(
          template,
          Offset.zero,
        );

        if(
        pages.contains(
          i+1,
        )
        ){

          final copy=
          output.pages.add();

          copy.graphics.drawPdfTemplate(
            template,
            Offset.zero,
          );

        }

        onProgress?.call(
          (i+1)
              /source.pages.count,
        );

      }

      await File(
        outputPath,
      ).writeAsBytes(
        await output.save(),
      );

    }
    finally{

      source.dispose();
      output.dispose();

    }

  }

  Future<void> reorderPages({

    required String sourcePath,
    required List<int> newOrder,
    required String outputPath,

  }) async {

    final source=
    sync.PdfDocument(
      inputBytes:
      await File(
        sourcePath,
      ).readAsBytes(),
    );

    final output=
    sync.PdfDocument();

    try{

      for(
      int i in newOrder
      ){

        final template=
        source.pages[
        i-1
        ]
            .createTemplate();

        final page=
        output.pages.add();

        page.graphics.drawPdfTemplate(
          template,
          Offset.zero,
        );

      }

      await File(
        outputPath,
      ).writeAsBytes(
        await output.save(),
      );

    }
    finally{

      source.dispose();
      output.dispose();

    }

  }

  Future<String?> savePdfDialog() async {
    try {
      return await FilePicker.platform.saveFile(
        dialogTitle: 'Save PDF',
        fileName: 'output.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
    } catch (e) {
      return null;
    }
  }

  /// -------------------------
  /// SPLIT PDF (SAFE)
  /// -------------------------
  Future<void> splitPdf({
    required String sourcePath,
    required List<int> selectedPages,
    required String outputPath,
  }) async {

    final source = sync.PdfDocument(
      inputBytes: await File(sourcePath).readAsBytes(),
    );

    final output = sync.PdfDocument();

    try {

      for (final pageNumber
      in selectedPages) {

        if (pageNumber <= 0 ||
            pageNumber >
                source.pages.count) {
          continue;
        }

        final sourcePage =
        source.pages[
        pageNumber - 1];

        final section =
        output.sections!.add();

        section.pageSettings.size =
            sourcePage.size;

        section.pageSettings.rotate =
            sourcePage.rotation;

        final page =
        section.pages.add();

        page.graphics.drawPdfTemplate(
          sourcePage.createTemplate(),
          Offset.zero,
        );
      }

      await File(outputPath)
          .writeAsBytes(
        await output.save(),
      );

    } finally {

      source.dispose();
      output.dispose();

    }
  }

  /// -------------------------
  /// MERGE PDF (SAFE + LARGE FILE FRIENDLY)
  /// -------------------------

  Future<void> mergePdfs({
    required List<String> files,
    required String outputPath,
    ProgressCallback? onProgress,
  })async {

    final output = sync.PdfDocument();

    try {

      for (final path in files) {

        final file = File(path);

        if (!await file.exists()) {
          continue;
        }

        final input = sync.PdfDocument(
          inputBytes: await file.readAsBytes(),
        );

        try {

          for (int i = 0; i < input.pages.count; i++) {

            final sourcePage =
            input.pages[i];

            final template =
            sourcePage.createTemplate();

            final section =
            output.sections!.add();

            section.pageSettings.size =
                sourcePage.size;

            section.pageSettings.rotate =
                sourcePage.rotation;

            final newPage =
            section.pages.add();

            newPage.graphics.drawPdfTemplate(
              template,
              Offset.zero,
            );

          }

        } finally {

          input.dispose();

        }

      }

      final bytes =
      await output.save();

      await File(outputPath)
          .writeAsBytes(bytes);

    } finally {

      output.dispose();

    }

  }

  /// -------------------------
  /// METADATA PURGE (SAFE)
  /// -------------------------
  Future<void> purgeMetadata({
    required String sourcePath,
    required String outputPath,
  }) async {
    final doc = sync.PdfDocument(
      inputBytes: await File(sourcePath).readAsBytes(),
    );

    try {
      doc.documentInformation
        ..title = ''
        ..author = ''
        ..subject = ''
        ..keywords = ''
        ..creator = ''
        ..producer = '';

      final bytes = await doc.save();
      await File(outputPath).writeAsBytes(bytes);
    } finally {
      doc.dispose();
    }
  }

  /// -------------------------
  /// ROTATE PAGES (SAFE)
  /// -------------------------
  Future<void> rotatePages({
    required String sourcePath,
    required List<int> pagesToRotate,
    required String outputPath,
    required int angle,
  }) async {
    final doc = sync.PdfDocument(
      inputBytes: await File(sourcePath).readAsBytes(),
    );

    try {
      for (final pageNumber in pagesToRotate) {
        if (pageNumber <= 0 || pageNumber > doc.pages.count) continue;

        final page = doc.pages[pageNumber - 1];
        final current = page.rotation.index;

        int newIndex;

        if (angle > 0) {
          newIndex = (current + 1) % 4;
        } else {
          newIndex = (current - 1) % 4;
          if (newIndex < 0) newIndex = 3;
        }

        page.rotation = sync.PdfPageRotateAngle.values[newIndex];
      }

      final bytes = await doc.save();
      await File(outputPath).writeAsBytes(bytes);
    } finally {
      doc.dispose();
    }
  }

  /// -------------------------
  /// CROP (SAFE + FULL COPY MODE)
  /// -------------------------
  Future<void> applyCrop({
    required String sourcePath,
    required Map<int, Rect> cropMap,
    required String outputPath,
  }) async {

    final source =
    sync.PdfDocument(
      inputBytes:
      await File(sourcePath)
          .readAsBytes(),
    );

    final output =
    sync.PdfDocument();

    try {

      for(
      int i=0;
      i<source.pages.count;
      i++
      ){

        final pageNumber =
            i+1;

        final page =
        source.pages[i];

        final pageSize =
            page.size;

        final template =
        page.createTemplate();

        if(
        cropMap.containsKey(
            pageNumber)
        ){

          final normalized =
          cropMap[
          pageNumber]!;

          final actualRect =
          Rect.fromLTWH(

            normalized.left *
                pageSize.width,

            normalized.top *
                pageSize.height,

            normalized.width *
                pageSize.width,

            normalized.height *
                pageSize.height,

          );

          final pdfRect =
          Rect.fromLTWH(

            actualRect.left,

            pageSize.height -
                actualRect.bottom,

            actualRect.width,

            actualRect.height,

          );

          final section =
          output.sections!.add();

          section
              .pageSettings
              .size =
              Size(
                pdfRect.width,
                pdfRect.height,
              );

          final newPage =
          section.pages.add();

          newPage.graphics
              .drawPdfTemplate(

            template,

            Offset(
              -pdfRect.left,
              -pdfRect.top,
            ),

          );

        }

        else{

          final section =
          output.sections!.add();

          section
              .pageSettings
              .size=
              pageSize;

          final newPage =
          section.pages.add();

          newPage.graphics
              .drawPdfTemplate(
            template,
            Offset.zero,
          );

        }

      }

      await File(outputPath)
          .writeAsBytes(
        await output.save(),
      );

    } finally {

      source.dispose();
      output.dispose();

    }

  }
}
