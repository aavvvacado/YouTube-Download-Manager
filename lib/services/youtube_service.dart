import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeVideoInfo {
  final String title;
  final String thumbnailUrl;
  final List<String> availableQualities;
  final String author;
  var duration;

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

    List<String> qualities =
        manifest.muxed.map((e) => e.videoQualityLabel).toList();

    return YoutubeVideoInfo(
      title: video.title,
      thumbnailUrl: video.thumbnails.standardResUrl,
      author: video.author,
      duration: video.duration,
      availableQualities: qualities,
    );
  }
}
