import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeVideoInfo {
  final String title;
  final String thumbnailUrl;
  final List<String> availableQualities;
  final String author;
  Duration? duration;
  
  Duration? get videoDuration => duration;

  YoutubeVideoInfo(
      {required this.title,
      required this.thumbnailUrl,
      required this.availableQualities,
      required this.duration,
      required this.author});
}

class YoutubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  Future<YoutubeVideoInfo> fetchVideoInfo(String url) async {
    final video = await _yt.videos.get(url);
    final manifest = await _yt.videos.streamsClient.getManifest(video.id);

    // Deduplicate and sort quality labels descending (e.g., 1080p, 720p...)
    final qualitiesSet = manifest.muxed.map((e) => e.qualityLabel).toSet();
    final qualities = qualitiesSet.toList()
      ..sort((a, b) {
        int toInt(String s) => int.tryParse(s.replaceAll(RegExp(r'\D'), '')) ?? 0;
        return toInt(b).compareTo(toInt(a));
      });

    return YoutubeVideoInfo(
      title: video.title,
      thumbnailUrl: video.thumbnails.highResUrl,
      author: video.author,
      duration: video.duration,
      availableQualities: qualities,
    );
  }
}
