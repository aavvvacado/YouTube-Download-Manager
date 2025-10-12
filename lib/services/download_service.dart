import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

class DownloadProgress {
  final String status;
  final double progress;
  final String? filePath;

  DownloadProgress(this.status, this.progress, this.filePath);
}

class DownloadService {
  final YoutubeExplode _yt = YoutubeExplode();

  Stream<DownloadProgress> downloadVideoWithAudio(String url, {String? qualityLabel}) async* {
    try {
      if (Platform.isAndroid) {
        if (!await Permission.storage.request().isGranted) {
          throw Exception('Storage permission is required to download videos.');
        }
      }

      yield DownloadProgress('Fetching video details...', 0.0, null);
      final video = await _yt.videos.get(url);
      final manifest = await _yt.videos.streamsClient.getManifest(video.id);
      final safeTitle = video.title.replaceAll(RegExp(r'[<>:"/\\|?*]+'), '_').trim();

      final videoOnlyStreams = manifest.videoOnly.sortByVideoQuality().reversed.toList();
      final audioOnlyStreams = manifest.audioOnly.sortByBitrate().reversed.toList();
      final muxedStreams = manifest.muxed.sortByVideoQuality().reversed.toList();

      StreamInfo? videoStreamInfo;
      StreamInfo? audioStreamInfo;

      if (qualityLabel != null) {
        try {
          // First, try to find the quality in video-only streams
          videoStreamInfo = videoOnlyStreams.firstWhere((s) => s.qualityLabel == qualityLabel);
        } catch (e) {
          // If not found, then try to find it in muxed streams
          try {
            videoStreamInfo = muxedStreams.firstWhere((s) => s.qualityLabel == qualityLabel);
          } catch (e) {
            // If still not found, it will be null and the fallback below will be used
            videoStreamInfo = null;
          }
        }
      }
      videoStreamInfo ??= videoOnlyStreams.isNotEmpty ? videoOnlyStreams.first : muxedStreams.firstOrNull;

      if (videoStreamInfo == null) {
        throw Exception('No downloadable video streams could be found for this video.');
      }

      final downloadsDir = await _getFinalPath(video.title);

      if (videoStreamInfo is MuxedStreamInfo) {
        final filePath = p.join(downloadsDir.path, '$safeTitle.${videoStreamInfo.container.name}');
        await for (final progress in _downloadStream(videoStreamInfo, filePath, status: 'Downloading...')) {
          yield progress;
        }
        yield DownloadProgress('Download complete', 1.0, filePath);
        return;
      }

      if (videoStreamInfo is VideoOnlyStreamInfo) {
        audioStreamInfo = audioOnlyStreams.firstOrNull;
        if (audioStreamInfo == null) {
          throw Exception('Could not find a matching audio stream.');
        }

        final tempDir = await getTemporaryDirectory();
        final tempVideoPath = p.join(tempDir.path, 'temp_video.mp4');
        final tempAudioPath = p.join(tempDir.path, 'temp_audio.m4a');
        final outputPath = p.join(downloadsDir.path, '$safeTitle.mp4');

        await for (final progress in _downloadStream(videoStreamInfo, tempVideoPath, status: 'Downloading video...')) {
          yield DownloadProgress(progress.status, progress.progress * 0.45, null);
        }

        await for (final progress in _downloadStream(audioStreamInfo, tempAudioPath, status: 'Downloading audio...')) {
          yield DownloadProgress(progress.status, 0.45 + (progress.progress * 0.45), null);
        }

        yield DownloadProgress('Merging files...', 0.9, null);
        final command = '-y -i "$tempVideoPath" -i "$tempAudioPath" -c copy "$outputPath"';
        final session = await FFmpegKit.execute(command);
        final returnCode = await session.getReturnCode();

        await File(tempVideoPath).delete();
        await File(tempAudioPath).delete();

        if (ReturnCode.isSuccess(returnCode)) {
          yield DownloadProgress('Download complete', 1.0, outputPath);
        } else {
          final logs = await session.getAllLogsAsString();
          throw Exception('FFmpeg merge failed. Logs: $logs');
        }
      }
    } on YoutubeExplodeException catch (e) {
      throw Exception('Failed to get video info. It may be private or unavailable. Error: ${e.message}');
    } on SocketException {
      throw Exception('Network error. Please check your internet connection.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Stream<DownloadProgress> _downloadStream(StreamInfo streamInfo, String filePath, {required String status}) async* {
    final file = File(filePath);
    final output = file.openWrite();
    final stream = _yt.videos.streamsClient.get(streamInfo);
    final totalBytes = streamInfo.size.totalBytes;
    int receivedBytes = 0;

    await for (final data in stream) {
      output.add(data);
      receivedBytes += data.length;
      final progress = receivedBytes / totalBytes;
      yield DownloadProgress(status, progress, filePath);
    }
    await output.flush();
    await output.close();
  }

  Future<Directory> _getFinalPath(String title) async {
    Directory? baseDir;
    if (Platform.isAndroid) {
      baseDir = await getExternalStoragePublicDirectory(StorageDirectory.downloads);
    }
    baseDir ??= await getApplicationDocumentsDirectory();

    final finalDir = Directory(p.join(baseDir.path, 'YouTubeDownloads'));
    if (!await finalDir.exists()) {
      await finalDir.create(recursive: true);
    }
    return finalDir;
  }
}

Future<Directory?> getExternalStoragePublicDirectory(StorageDirectory type) async {
  if (!Platform.isAndroid) return null;
  final directories = await getExternalStorageDirectories(type: type);
  return directories?.first;
}
