import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../services/download_service.dart';
import '../providers/app_state.dart';

class DownloadScreen extends StatefulWidget {
  final String videoUrl;
  final String quality;

  const DownloadScreen(
      {super.key, required this.videoUrl, required this.quality});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final DownloadService _downloadService = DownloadService();
  double _progress = 0;
  StreamSubscription<double>? _subscription;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    _subscription = _downloadService
        .downloadVideo(widget.videoUrl, qualityLabel: widget.quality)
        .listen(
      (progress) {
        if (!mounted) return;
        setState(() {
          _progress = progress;
        });

        if (_progress >= 1) {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Download Complete!')));
          Navigator.pop(context); // Close the download screen
        }
      },
      onError: (error) {
        debugPrint(error.toString());
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animate = context.read<AppState>().useAnimations;
    return Scaffold(
      appBar: AppBar(title: const Text('Downloading')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 10,
                      ),
                    ),
                    Text(
                      '${(_progress * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ).animate(target: animate ? 1 : 0).fadeIn(duration: 300.ms),
              const SizedBox(height: 24),
              LinearProgressIndicator(value: _progress, minHeight: 8),
              const SizedBox(height: 12),
              Text(
                'Downloading... ${(_progress * 100).toStringAsFixed(0)}% completed',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
