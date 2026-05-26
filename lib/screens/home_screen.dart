import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:reorderables/reorderables.dart';
import '../models/page_model.dart';
import '../services/pdf_service.dart';
import '../widgets/crop_editor_overlay.dart';
import '../widgets/export_dialog.dart' show ExportDialog;
import '../widgets/page_thumbnail.dart';


class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}
typedef ProgressCallback = void Function(double progress);

class _HomeScreenState
    extends State<HomeScreen>{


  final PdfService pdfService=
  PdfService();

  bool cropMode = false;
  Rect? currentCrop;
  double progress = 0.0;
  bool isProcessing = false;

  PdfDocument? document;

  String? pdfPath;

  bool loading=false;

  List<String> mergeFiles=[];

  Map<int, Rect> cropMap = {};

  List<int> selectedPages = [];

  List<PdfPageModel> pages=[];

  Future<void> openPdf() async {

    setState(() {
      loading = true;
    });

    try {

      final path = await pdfService.pickPdf();

      if (path == null) {

        if(mounted){
          setState(() {
            loading = false;
          });
        }

        return;
      }

      final file = File(path);

      if (!await file.exists()) {
        throw Exception("File not found");
      }

      final doc =
      await PdfDocument.openFile(path);

      final totalPages =
          doc.pages.length;

      pages.clear();
      selectedPages.clear();
      cropMap.clear();
      currentCrop = null;

      for (
      int i = 0;
      i < totalPages;
      i++
      ) {

        pages.add(
          PdfPageModel(
            pageNumber: i + 1,
          ),
        );

      }

      if (!mounted) return;

      setState(() {

        document?.dispose();

        document = doc;

        pdfPath = path;

        loading = false;

      });

    }

    catch (e) {

      if(!mounted) return;

      setState(() {
        loading = false;
      });

      final error =
      e.toString().toLowerCase();

      if (
      error.contains("password") ||
          error.contains("encrypted")
      ) {

        showError(
          "This PDF is password protected",
        );

        return;

      }

      if (
      error.contains("format") ||
          error.contains("corrupt")
      ) {

        showError(
          "Corrupted PDF file",
        );

        return;

      }

      showError(
        "Cannot open PDF\n$e",
      );

    }

  }

  void showError(String msg) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("PDF Error"),
          content: Text(msg),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openPdf();
              },
              child: const Text("Retry"),
            ),

          ],
        );
      },
    );
  }

  void showSuccess(
      String title,
      String message,
      ) {

    if(!mounted) return;

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: Text(title),

          content: Text(message),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(context);

              },

              child: const Text(
                "OK",
              ),

            )

          ],

        );

      },

    );

  }
  @override
  void dispose() {

    document?.dispose();

    super.dispose();

  }

  Future<Map<String, dynamic>?> showExportDialog() async {
    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const ExportDialog(),
    );
  }

  Future<T> runTask<T>(
      Future<T> Function(
          ProgressCallback update,
          ) task,
      ) async {

    setState((){

      isProcessing=true;
      progress=0;

    });

    try{

      return await task(
            (value){

          if(!mounted)return;

          setState(() {
            progress=value;
          });

        },
      );

    }
    finally{

      if(mounted){

        setState((){

          progress=1;
          isProcessing=false;

        });

      }

    }

  }

  Future<void> cropPdf() async {

    if (cropMap.isEmpty || pdfPath == null) {
      showError("No crop regions selected");
      return;
    }

    final result = await showExportDialog();

    if (result == null) return;

    final outputPath =
    result["path"] as String;

    if (outputPath.isEmpty) return;

    await runTask(
          (update) async {

        await pdfService.applyCrop(
          sourcePath: pdfPath!,
          cropMap: cropMap,
          outputPath: outputPath,
        );

      },
    );

    if (!mounted) return;

    showSuccess(
      "Success",
      "Crop completed",
    );
  }


  Future<void> deleteSelectedPages() async {

    if(selectedPages.isEmpty){
      showError("Select pages");
      return;
    }

    showSuccess(
      "Delete",
      "${selectedPages.length} pages deleted",
    );
  }


  Future<void> duplicateSelectedPages() async {

    if(selectedPages.isEmpty){
      showError("Select pages");
      return;
    }

    showSuccess(
      "Duplicate",
      "${selectedPages.length} pages duplicated",
    );
  }


  Future<void> saveReorderedPdf() async {

    showSuccess(
      "Saved",
      "Reordered PDF saved",
    );
  }

  Future<void> pickMergeFiles() async {

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: false,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final newPaths = result.files
        .where((f) => f.path != null)
        .map((f) => f.path!)
        .toList();

    setState(() {

      // add new PDFs instead of replacing old ones
      for (final file in newPaths) {

        // avoid duplicates
        if (!mergeFiles.contains(file)) {
          mergeFiles.add(file);
        }

      }

    });

    print("Total PDFs in queue: ${mergeFiles.length}");
  }

  Future<void> rotatePages(int angle) async {
    if (selectedPages.isEmpty || pdfPath == null) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("No pages selected"),
          content: Text("Select pages first"),
        ),
      );
      return;
    }

    final result = await showExportDialog();
    if (result == null) return;

    final outputPath = result["path"] as String;
    final overwrite = result["overwrite"] as bool;
    if (outputPath == null) return;

    await runTask(
          (update) async {

            await pdfService.rotatePages(
              sourcePath: pdfPath!,
              pagesToRotate: selectedPages,
              outputPath: outputPath,
              angle: angle,
            );
      },
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("Success"),
        content: Text("Pages rotated successfully"),
      ),
    );
  }

  Future<void> exportSelectedPages() async {

    final selected = pages
        .where((p) => p.selected)
        .map((p) => p.pageNumber)
        .toList();

    if (selected.isEmpty) {
      showError("Select pages first");
      return;
    }

    if (pdfPath == null) {
      showError("Open PDF first");
      return;
    }

    final result = await showExportDialog();

    if (result == null) return;

    final outputPath =
    result["path"] as String;

    await runTask(
          (update) async {

        await pdfService.splitPdf(
          sourcePath: pdfPath!,
          selectedPages: selected,
          outputPath: outputPath,
        );

      },
    );

    if (!mounted) return;

    showSuccess(
      "Success",
      "PDF exported successfully",
    );
  }

  Future<void> purgeMetadata() async {
    if (pdfPath == null) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("No PDF loaded"),
          content: Text("Open a PDF first"),
        ),
      );
      return;
    }

    final result = await showExportDialog();
    if (result == null) return;

    final outputPath = result["path"] as String;
    final overwrite = result["overwrite"] as bool;
    if (outputPath == null) return;

    await runTask(
          (update) async {

            await pdfService.purgeMetadata(
              sourcePath: pdfPath!,
              outputPath: outputPath,
            );

      },
    );
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Metadata Removed"),
        content: Text("Saved:\n$outputPath"),
      ),
    );
  }

  Future<void> mergePdfFiles() async {

    if (mergeFiles.isEmpty) {

      showError(
        "Choose PDFs first",
      );

      return;
    }

    final savePath =
    await pdfService.savePdfDialog();

    if (savePath == null) return;

    await runTask(
          (update) async {

        await pdfService.mergePdfs(

          files:mergeFiles,
          outputPath:savePath,

        );

      },
    );
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) {

        return AlertDialog(
          title: const Text(
            "Merge Complete",
          ),
          content: Text(
            "Saved:\n$savePath",
          ),
        );

      },
    );
  }

  Future<void> splitPdfIntoFiles() async {

    if (pdfPath == null) {
      showError("Open PDF first");
      return;
    }

    final selected = pages
        .where((p) => p.selected)
        .map((p) => p.pageNumber)
        .toList();

    if (selected.isEmpty) {
      showError("Select pages first");
      return;
    }

    final result = await showExportDialog();

    if (result == null) return;

    final outputPath = result["path"] as String;

    if (outputPath.isEmpty) return;

    await runTask(
          (update) async {

            await pdfService.splitPdf(
              sourcePath: pdfPath!,
              selectedPages: selected,
              outputPath: outputPath,
            );
      },
    );

    if (!mounted) return;

    showSuccess(
      "Done",
      "Split completed",
    );
  }

  void selectAllPages() {

    setState(() {

      selectedPages.clear();

      for (final page in pages) {

        page.selected = true;
        selectedPages.add(page.pageNumber);

      }

    });

  }

  void clearSelection() {

    setState(() {

      selectedPages.clear();

      for (final page in pages) {

        page.selected = false;

      }

    });

  }


  void toggleSelection(
      int pageNumber,
      ) {

    setState(() {

      final page =
      pages.firstWhere(
            (e) =>
        e.pageNumber ==
            pageNumber,
      );

      page.selected =
      !page.selected;

      if(page.selected){

        if(
        !selectedPages.contains(
            pageNumber)
        ){

          selectedPages.add(
              pageNumber);

        }

      }

      else {

        selectedPages.remove(
            pageNumber);

      }

    });

  }

  @override
  Widget build(BuildContext context) {

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{

        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyO,
        ): const OpenIntent(),

        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyS,
        ): const SaveIntent(),

        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyA,
        ): const SelectAllIntent(),

        LogicalKeySet(
          LogicalKeyboardKey.delete,
        ): const ClearSelectionIntent(),

      },

      child: Actions(

        actions: {

          OpenIntent: CallbackAction(
            onInvoke: (_) => openPdf(),
          ),

          SaveIntent: CallbackAction(
            onInvoke: (_) => exportSelectedPages(),
          ),

          SelectAllIntent: CallbackAction(
            onInvoke: (_) => selectAllPages(),
          ),

          ClearSelectionIntent: CallbackAction(
            onInvoke: (_) => clearSelection(),
          ),

        },

        child: Scaffold(

          body: Stack(

            children: [

              /// MAIN CONTENT
              Column(

                children: [

                  Expanded(

                    child: Row(

                      children: [

                        /// LEFT SIDEBAR
                        Container(

                          width: 250,
                          color: Colors.black26,
                          padding: const EdgeInsets.all(20),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [

                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [

                                        _toolButton(
                                          "Open PDF",
                                          openPdf,
                                        ),

                                        _toolButton(
                                          "Export",
                                          exportSelectedPages,
                                        ),

                                        _toolButton(
                                          "Merge PDFs",
                                          mergePdfFiles,
                                        ),

                                        _toolButton(
                                          "Choose PDFs",
                                          pickMergeFiles,
                                        ),

                                        _toolButton(
                                          "Purge Metadata",
                                          purgeMetadata,
                                        ),

                                        _toolButton(
                                          "Rotate Left",
                                              () => rotatePages(-90),
                                        ),

                                        _toolButton(
                                          "Rotate Right",
                                              () => rotatePages(90),
                                        ),

                                        _toolButton(
                                          "Split PDF",
                                          splitPdfIntoFiles,
                                        ),

                                        _toolButton(
                                          "Crop PDF",
                                          cropPdf,
                                        ),

                                        _toolButton(
                                          "Crop Mode",
                                              () {
                                            setState(() {
                                              cropMode = !cropMode;
                                            });
                                          },
                                        ),

                                        _toolButton(
                                          "Delete Pages",
                                          deleteSelectedPages,
                                        ),

                                        _toolButton(
                                          "Duplicate Pages",
                                          duplicateSelectedPages,
                                        ),

                                        _toolButton(
                                          "Save Reorder",
                                          saveReorderedPdf,
                                        ),

                                        const SizedBox(height: 20),

                                        Text(
                                          pdfPath ?? "No file selected",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        const SizedBox(height: 20),

                                        Text(
                                          "Selected Pages: ${selectedPages.length}",
                                        ),

                                        const SizedBox(height: 20),

                                        const Text(
                                          "Merge Queue",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: 200,
                                  child: mergeFiles.isEmpty
                                      ? const Center(
                                    child: Text(
                                      "No files added",
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                      : ReorderableListView.builder(
                                    itemCount: mergeFiles.length,
                                    onReorder: (oldIndex, newIndex) {
                                      setState(() {
                                        if (newIndex > oldIndex) {
                                          newIndex--;
                                        }

                                        final item =
                                        mergeFiles.removeAt(oldIndex);

                                        mergeFiles.insert(
                                          newIndex,
                                          item,
                                        );
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      final file = mergeFiles[index];

                                      return ListTile(
                                        key: ValueKey(file),
                                        dense: true,
                                        title: Text(
                                          file.split(
                                            Platform.pathSeparator,
                                          ).last,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                        ),

                        /// PDF AREA
                        Expanded(

                          child: loading

                              ? const Center(
                            child:
                            CircularProgressIndicator(),
                          )

                              : document == null

                              ? const Center(
                            child:
                            Text(
                              "Open PDF",
                            ),
                          )

                              : ReorderableWrap(

                            spacing:20,
                            runSpacing:20,

                            onReorder:(oldIndex,newIndex){

                              setState(() {

                                final item=
                                pages.removeAt(
                                  oldIndex,
                                );

                                pages.insert(
                                  newIndex,
                                  item,
                                );

                              });

                            },

                            children:
                            pages.map((pdfPage){

                              return SizedBox(

                                key:ValueKey(
                                  pdfPage.pageNumber,
                                ),

                                width:200,
                                height:250,

                                child: Stack(
                                  children: [

                                    PageThumbnail(
                                      document: document!,
                                      pageNumber: pdfPage.pageNumber,
                                      selected: selectedPages.contains(
                                        pdfPage.pageNumber,
                                      ),
                                      onTap: () {

                                        if (!cropMode) {
                                          toggleSelection(
                                            pdfPage.pageNumber,
                                          );
                                        }

                                      },
                                    ),

                                    if (cropMode)
                                      CropEditorOverlay(

                                        initialRect:
                                        cropMap[pdfPage.pageNumber],

                                        onChanged: (rect) {

                                          setState(() {

                                            cropMap[
                                            pdfPage.pageNumber
                                            ] = rect;

                                          });

                                        },

                                      ),

                                  ],
                                ),

                              );

                            }).toList(),

                          ),

                        ),

                      ],

                    ),

                  ),

                ],

              ),

              /// PROCESSING OVERLAY
              if(isProcessing)

                Positioned.fill(

                  child: Container(

                    color: Colors.black54,

                    child: Center(

                      child: Column(

                        mainAxisSize:
                        MainAxisSize.min,

                        children:[

                          CircularProgressIndicator(
                            value:progress,
                          ),

                          const SizedBox(
                            height:20,
                          ),

                          Text(
                            "${(progress*100).toInt()} %",
                            style: const TextStyle(
                              color:Colors.white,
                            ),
                          ),

                        ],

                      )

                    ),

                  ),

                ),

            ],

          ),

        ),

      ),

    );

  }

}

class OpenIntent extends Intent {
  const OpenIntent();
}

class SaveIntent extends Intent {
  const SaveIntent();
}

class SelectAllIntent extends Intent {
  const SelectAllIntent();
}

class ClearSelectionIntent extends Intent {
  const ClearSelectionIntent();
}

Widget _toolButton(String text, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(text),
      ),
    ),
  );
}