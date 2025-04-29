import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DownloadsListScreen extends StatefulWidget {
  const DownloadsListScreen({super.key});

  @override
  State<DownloadsListScreen> createState() => _DownloadsListScreenState();
}

class _DownloadsListScreenState extends State<DownloadsListScreen> {
  List<FileSystemEntity> files = [];

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    final baseDir = await getExternalStorageDirectory();
    if (baseDir == null) {
      debugPrint('Could not access external storage');
      return;
    }

    final directory = Directory(p.join(baseDir.path, 'AuthorityMartDownloads'));
    if (directory.existsSync()) {
      setState(() {
        files = directory
            .listSync()
            .where((file) => file is File && file.path.endsWith('.mp4'))
            .toList();
      });
    } else {
      debugPrint('Download directory does not exist: ${directory.path}');
    }
  }

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (log(bytes) / log(1024)).floor();
    final size = bytes / pow(1024, i);
    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Downloaded Videos')),
      body: files.isEmpty
          ? const Center(child: Text('No downloaded videos found.'))
          : ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index] as File;
                final fileName = p.basename(file.path);
                final fileSize = _formatBytes(file.lengthSync(), 2);

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const Icon(Icons.video_file,
                        size: 40, color: Colors.blue),
                    title: Text(
                      fileName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(fileSize),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow, color: Colors.blue),
                      onPressed: () => OpenFile.open(file.path),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
