import 'package:flutter/material.dart';

import '../services/download_service.dart';

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

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    _downloadService.downloadVideo(widget.videoUrl).listen((progress) {
      setState(() {
        _progress = progress;
      });

      if (_progress >= 1) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Download Complete!')));
        Navigator.pop(context); // Close the download screen
      }
    }, onError: (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Download Failed'),
          content: const Text(
              'This video cannot be downloaded due to YouTube restrictions. Please try another video.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Downloading')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: _progress),
            const SizedBox(height: 20),
            Text('${(_progress * 100).toStringAsFixed(0)}% completed'),
          ],
        ),
      ),
    );
  }
}
