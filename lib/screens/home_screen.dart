import 'package:flutter/material.dart';

import '../services/youtube_service.dart';
import 'download_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  YoutubeVideoInfo? _videoInfo;
  bool _isLoading = false;
  String _selectedQuality = '720p';

  final List<String> _qualityOptions = ['1080p', '720p', '480p', '360p'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('YouTube Download Manager')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Paste YouTube URL',
                labelStyle: TextStyle(color: Colors.grey[700]),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Colors.blueAccent, width: 2),
                ),
                prefixIcon: const Icon(Icons.link, color: Colors.blueAccent),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: _fetchVideoInfo,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              child: const Text(
                'Fetch Video Info',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_videoInfo != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(_videoInfo!.thumbnailUrl),
              ),
              const SizedBox(height: 16),
              Text(
                _videoInfo!.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _videoInfo!.author,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedQuality,
                decoration: InputDecoration(
                  labelText: 'Select Quality',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                items: _qualityOptions.map((quality) {
                  return DropdownMenuItem(
                    value: quality,
                    child: Text(quality),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedQuality = value!;
                  });
                },
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _downloadVideo,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text(
                  'Download Video',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/downloads');
        },
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.video_library,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  String _cleanUrl(String url) {
    try {
      Uri uri = Uri.parse(url);
      if (uri.host.contains('youtu.be')) {
        return 'https://www.youtube.com/watch?v=${uri.pathSegments.first}';
      } else if (uri.host.contains('youtube.com')) {
        String? videoId = uri.queryParameters['v'];
        if (videoId != null && videoId.isNotEmpty) {
          return 'https://www.youtube.com/watch?v=$videoId';
        }
      }
      return url;
    } catch (e) {
      return url;
    }
  }

  Future<void> _fetchVideoInfo() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final cleanUrl = _cleanUrl(_urlController.text.trim());
      final videoInfo = await YoutubeService().fetchVideoInfo(cleanUrl);
      setState(() {
        _videoInfo = videoInfo;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch video info: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _downloadVideo() {
    final cleanUrl = _cleanUrl(_urlController.text.trim());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DownloadScreen(
          videoUrl: cleanUrl,
          quality: _selectedQuality,
        ),
      ),
    );
  }
}
