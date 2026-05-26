import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';


class ExportDialog extends StatefulWidget {
  const ExportDialog({super.key});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  final TextEditingController nameController =
  TextEditingController(text: "output.pdf");

  String? selectedFolder;
  bool overwrite = false;

  Future<void> pickFolder() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path == null) return;

    setState(() {
      selectedFolder = path;
    });
  }

  void confirm() {
    if (selectedFolder == null) return;

    final filePath = "$selectedFolder${Platform.pathSeparator}${nameController.text}";

    Navigator.pop(context, {
      "path": filePath,
      "overwrite": overwrite,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Export PDF"),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          /// FILE NAME
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "File name",
            ),
          ),

          const SizedBox(height: 10),

          /// FOLDER PICK
          Row(
            children: [
              Expanded(
                child: Text(
                  selectedFolder ?? "No folder selected",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: pickFolder,
                child: const Text("Choose"),
              )
            ],
          ),

          const SizedBox(height: 10),

          /// OVERWRITE
          Row(
            children: [
              Checkbox(
                value: overwrite,
                onChanged: (v) {
                  setState(() {
                    overwrite = v ?? false;
                  });
                },
              ),
              const Text("Allow overwrite")
            ],
          ),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: selectedFolder == null ? null : confirm,
          child: const Text("Export"),
        ),
      ],
    );
  }
}