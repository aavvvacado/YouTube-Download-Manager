import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../ui/widgets/app_nav_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      bottomNavigationBar: const AppNavBar(currentIndex: 2),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Theme mode'),
                subtitle: Text(_themeModeLabel(appState.themeMode)),
                trailing: DropdownButton<ThemeMode>(
                  value: appState.themeMode,
                  onChanged: (v) => v != null ? appState.setThemeMode(v) : null,
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  ],
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.motion_photos_on),
                title: const Text('Enable animations'),
                value: appState.useAnimations,
                onChanged: appState.setUseAnimations,
              ),
              const SizedBox(height: 16),
              Text('Downloads', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.hd),
                title: const Text('Default quality'),
                trailing: DropdownButton<String>(
                  value: appState.defaultQuality,
                  onChanged: (v) => v != null ? appState.setDefaultQuality(v) : null,
                  items: const [
                    DropdownMenuItem(value: '1080p', child: Text('1080p')),
                    DropdownMenuItem(value: '720p', child: Text('720p')),
                    DropdownMenuItem(value: '480p', child: Text('480p')),
                    DropdownMenuItem(value: '360p', child: Text('360p')),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const ListTile(
                leading: Icon(Icons.tune),
                title: Text('Audio/Video preferences'),
                subtitle: Text('More options coming soon'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}
