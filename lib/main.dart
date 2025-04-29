import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yt_downloader/screens/download_list_screen.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Download Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red),
      home: const InitScreen(),
      routes: {
        '/downloads': (context) => const DownloadsListScreen(),
      },
    );
  }
}

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [Permission.storage].request();
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
