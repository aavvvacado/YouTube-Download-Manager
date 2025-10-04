import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:yt_downloader/screens/download_list_screen.dart';
import 'package:yt_downloader/theme.dart';
import 'package:yt_downloader/providers/app_state.dart';
import 'package:yt_downloader/screens/settings_screen.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            title: 'YouTube Download Manager',
            debugShowCheckedModeBanner: false,
            theme: BuildTheme.lightTheme,
            darkTheme: BuildTheme.darkTheme,
            themeMode: appState.themeMode,
            home: const InitScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/downloads': (context) => const DownloadsListScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
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
    if (Platform.isAndroid) {
      await [Permission.storage].request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
