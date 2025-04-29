import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

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
    Directory directory =
        Directory('/storage/emulated/0/AuthorityMartDownloads');
    if (directory.existsSync()) {
      setState(() {
        files = directory.listSync();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Downloaded Videos')),
      body: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          return ListTile(
            title: Text(file.path.split('/').last),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                OpenFile.open(file.path);
              },
            ),
          );
        },
      ),
    );
  }
}
