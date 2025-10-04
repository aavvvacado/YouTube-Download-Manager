import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadService {
  final YoutubeExplode _yt = YoutubeExplode();

  Stream<double> downloadVideo(String url, {String? qualityLabel}) async* {
    // Request storage permission on Android only
    if (Platform.isAndroid) {
      if (!await Permission.storage.isGranted) {
        await Permission.storage.request();
      }
    }

    final video = await _yt.videos.get(url);
    final manifest = await _yt.videos.streamsClient.getManifest(video.id);

    // Prefer muxed (audio+video). Use requested quality if available, else best.
    final muxed = manifest.muxed;
    final streamInfo = qualityLabel != null
        ? (muxed.firstWhere(
              (e) => e.qualityLabel == qualityLabel,
              orElse: () => muxed.withHighestBitrate(),
            ))
        : muxed.withHighestBitrate();
    if (streamInfo == null) {
      throw 'No available streams for this video.';
    }

    final stream = _yt.videos.streamsClient.get(streamInfo);
    // Choose platform-appropriate base directory
    final Directory baseDir;
    if (Platform.isAndroid) {
      final ext = await getExternalStorageDirectory();
      if (ext == null) {
        throw Exception('Failed to access external storage directory.');
      }
      baseDir = ext;
    } else {
      baseDir = await getApplicationDocumentsDirectory();
    }

    final dir = Directory(p.join(baseDir.path, 'AuthorityMartDownloads'));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    // Sanitize title for filesystem
    final safeTitle = video.title.replaceAll(RegExp(r'[<>:"/\\|?*]+'), '_').trim();
    final filePath = p.join(dir.path, '$safeTitle.mp4');
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
