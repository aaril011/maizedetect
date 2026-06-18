import 'package:flutter/material.dart';

import 'history_service.dart';
import 'home_shell.dart';
import 'maize_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Muat history tersimpan sebelum app dimulai
  await HistoryService.instance.load();
  runApp(const MaizeDetectApp());
}

class MaizeDetectApp extends StatelessWidget {
  const MaizeDetectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaizeDetect',
      debugShowCheckedModeBanner: false,
      theme: buildMaizeTheme(),
      home: const HomeShell(),
    );
  }
}
