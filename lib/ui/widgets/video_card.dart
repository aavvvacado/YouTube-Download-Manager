import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VideoCard extends StatelessWidget {
  final String title;
  final String author;
  final String thumbnailUrl;
  final List<String> qualities;
  final String selectedQuality;
  final ValueChanged<String> onQualityChanged;
  final VoidCallback onDownload;
  final bool animate;

  const VideoCard({
    super.key,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    required this.qualities,
    required this.selectedQuality,
    required this.onQualityChanged,
    required this.onDownload,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(thumbnailUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(author, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedQuality,
              items: qualities.map((q) => DropdownMenuItem(value: q, child: Text(q))).toList(),
              onChanged: (v) => v != null ? onQualityChanged(v) : null,
              decoration: const InputDecoration(labelText: 'Quality'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.download),
              label: const Text('Download'),
            ),
          ],
        ),
      ),
    );

    return animate
        ? card
            .animate(target: 1)
            .fadeIn(duration: 300.ms)
            .moveY(begin: 6, end: 0, curve: Curves.easeOutCubic)
        : card;
  }
}
