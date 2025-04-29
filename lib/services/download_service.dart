import 'dart:io';

import 'package:path/path.dart' as p;
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

    final streamInfo = manifest.videoOnly.firstOrNull;
    if (streamInfo == null) {
      throw 'No available streams for this video.';
    }

    final stream = _yt.videos.streamsClient.get(streamInfo);
    final dir = Directory('/storage/emulated/0/AuthorityMartDownloads');
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
