import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/home_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    minimumSize: Size(800, 600),
    center: true,
    title: "PDF Knife",
  );

  await windowManager.waitUntilReadyToShow(
    windowOptions,
        () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );

  runApp(const PdfKnifeApp());
}

class PdfKnifeApp extends StatefulWidget {
  const PdfKnifeApp({super.key});

  @override
  State<PdfKnifeApp> createState() => _PdfKnifeAppState();
}

class _PdfKnifeAppState extends State<PdfKnifeApp> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {

      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      debugPrint(
        "Window ready, plugins initialized",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "PDF Knife",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}