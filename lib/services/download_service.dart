import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadService {
  final YoutubeExplode _yt = YoutubeExplode();

  Stream<double> downloadVideo(String url) async* {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }

    final video = await _yt.videos.get(url);
    final manifest = await _yt.videos.streamsClient.getManifest(video.id);

    final streamInfo = manifest.video.firstOrNull;
    if (streamInfo == null) {
      throw 'No available streams for this video.';
    }

    final stream = _yt.videos.streamsClient.get(streamInfo);
    final baseDir = await getExternalStorageDirectory();
    if (baseDir == null) {
      throw Exception('Failed to access external storage directory.');
    }
    final dir = Directory(p.join(baseDir.path, 'AuthorityMartDownloads'));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    if (!dir.existsSync()) {
      dir.createSync();
    }

    final filePath = p.join(dir.path, '${video.title}.mp4');
    final file = File(filePath);
    final output = file.openWrite();

    final len = streamInfo.size.totalBytes;
    int count = 0;

    await for (final data in stream) {
      count += data.length;
      output.add(data);
      yield count / len;
    }

    await output.flush();
    await output.close();
  }
}
