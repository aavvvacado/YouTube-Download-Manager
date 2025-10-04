import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../services/youtube_service.dart';
import 'download_screen.dart';
import '../providers/app_state.dart';
import '../ui/widgets/styled_text_field.dart';
import '../ui/widgets/styled_button.dart';
import '../ui/widgets/video_card.dart';
import '../ui/widgets/app_nav_bar.dart';


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
  void initState() {
    super.initState();
    _urlController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Download Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            tooltip: 'Theme mode',
            onPressed: appState.toggleThemeMode,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      bottomNavigationBar: const AppNavBar(currentIndex: 0),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(
                  'Download videos quickly',
                  style: Theme.of(context).textTheme.headlineMedium,
                ).animate(target: appState.useAnimations ? 1 : 0).fadeIn(duration: 250.ms).moveY(begin: 6, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Paste a YouTube link below and fetch details to start.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StyledTextField(
                        controller: _urlController,
                        hint: 'Paste YouTube URL',
                        icon: Icons.link,
                        onSubmitted: (_) => _fetchVideoInfo(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 48,
                      child: StyledButton(
                        onPressed: _isLoading || _urlController.text.trim().isEmpty ? null : _fetchVideoInfo,
                        icon: _isLoading ? null : Icons.search,
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Fetch'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: _videoInfo == null
                      ? SizedBox(
                          key: const ValueKey('empty'),
                          height: 80,
                          child: Center(
                            child: Text(
                              'No video loaded yet',
                              style: TextStyle(color: Theme.of(context).hintColor),
                            ),
                          ),
                        )
                      : VideoCard(
                          key: const ValueKey('info'),
                          title: _videoInfo!.title,
                          author: _videoInfo!.author,
                          thumbnailUrl: _videoInfo!.thumbnailUrl,
                          qualities: _videoInfo!.availableQualities.isNotEmpty
                              ? _videoInfo!.availableQualities
                              : _qualityOptions,
                          selectedQuality: _selectedQuality,
                          onQualityChanged: (q) => setState(() => _selectedQuality = q),
                          onDownload: _downloadVideo,
                          animate: appState.useAnimations,
                        ),
                ),
              ],
            ),
          ),
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
      if (!mounted) return;
      setState(() {
        _videoInfo = videoInfo;
        // If available qualities include the app default, pick it
        final appDefault = context.read<AppState>().defaultQuality;
        if (_videoInfo!.availableQualities.contains(appDefault)) {
          _selectedQuality = appDefault;
        }
      });
    } catch (e) {
      if (!mounted) return;
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

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
