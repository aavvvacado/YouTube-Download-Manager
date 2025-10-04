import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../ui/widgets/app_nav_bar.dart';

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
    // Use platform-appropriate storage directory
    Directory baseDir;
    if (Platform.isAndroid) {
      final ext = await getExternalStorageDirectory();
      if (ext == null) {
        debugPrint('Could not access external storage');
        return;
      }
      baseDir = ext;
    } else {
      baseDir = await getApplicationDocumentsDirectory();
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
      bottomNavigationBar: const AppNavBar(currentIndex: 1),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: files.isEmpty
              ? Center(
                  child: Text(
                    'No downloaded videos found.',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index] as File;
                    final fileName = p.basename(file.path);
                    final fileSize = _formatBytes(file.lengthSync(), 2);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        leading: Container(
                          width: 64,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.play_circle_fill, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 36),
                        ),
                        title: Text(
                          fileName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(fileSize),
                        trailing: IconButton(
                          icon: Icon(Icons.play_arrow, color: Theme.of(context).colorScheme.primary),
                          onPressed: () => OpenFile.open(file.path),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
