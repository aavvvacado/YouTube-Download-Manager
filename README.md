
# YouTube Download Manager

A modern Flutter app to fetch YouTube video details and download videos locally. The interface has been overhauled to be clean, responsive, and consistent with current design standards.

## Highlights

- Clean home layout with intuitive navigation bar (Home, Downloads, Settings)
- Light/dark theme support (Material 3, Google Fonts)
- Animated transitions and polished interactions (fetch, cards, progress)
- Animations toggle in Settings is respected across screens
- Styled widgets for inputs and buttons with consistent typography
- Card-based video preview with thumbnail, title, author, and quality selector
- Download progress with percentage and improved visuals
- Selected quality is used for download; filenames sanitized
- Settings for theme mode, animations, and default quality
- Responsive layout with centered content on larger screens

## Screens

- Home: Paste URL, fetch details, pick quality, and download
- Downloads: View downloaded videos in a card list and open files
- Settings: Theme mode (System/Light/Dark), animation toggle, default quality

## Tech Notes

- Material 3 color system with a seed-based color scheme
- Typography via `google_fonts` (Inter)
- Animations via `flutter_animate` (page, card, and progress)
- Optional `lottie` support (ready to use for future loader/hero animations)
- State via `provider`

Run `flutter pub get` after pulling changes.

## Dependencies

- permission_handler
- youtube_explode_dart
- path_provider, path, open_file, video_player
- provider, google_fonts, flutter_animate, lottie

## Project Structure

```bash
lib/
  main.dart
  theme.dart
  providers/
    app_state.dart
  services/
    download_service.dart
    youtube_service.dart
  screens/
    home_screen.dart
    download_screen.dart
    download_list_screen.dart
    settings_screen.dart
  ui/
    widgets/
      app_nav_bar.dart
      styled_button.dart
      styled_text_field.dart
      video_card.dart
```

## Getting Started

1. Ensure Flutter is installed and configured.
2. Install dependencies:
   `flutter pub get`
3. Run on a device or emulator:
   `flutter run`

## Usage

1. Paste a YouTube URL on Home.
2. Tap Fetch to load metadata and thumbnail.
3. Select quality and Download.
4. Open Downloads to view downloaded files.
5. Adjust theme and preferences in Settings.

## Permissions

The app requests storage permissions on startup to save videos.

## Notes

- This app uses `youtube_explode_dart` to obtain metadata and streams.
- If you add Lottie animations, include JSON assets under `flutter/assets` and reference them in code.
