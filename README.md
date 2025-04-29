
# YouTube Download Manager

YouTube Download Manager is a Flutter mobile application developed as part of an assignment. The app allows users to fetch YouTube video details and download videos directly to their devices. It provides an intuitive interface with the ability to choose video quality and manage download history.

## Features

- **Fetch Video Information**: Paste any YouTube video URL to fetch video details (title, thumbnail, and author).
- **Download Videos**: Download videos in the preferred quality (1080p, 720p, 480p, 360p) after fetching video details.
- **Preview Before Downloading**: View video thumbnail and information before downloading.
- **Download History**: View the list of previously downloaded videos.
- **Clean and Modern UI**: Designed using Flutter’s Material Design principles for a sleek user experience.
- **Permission Handling**: App requests necessary permissions (storage access) on startup for seamless video downloads.

## Packages Used

| Package Name                | Purpose                                                 |
|-----------------------------|---------------------------------------------------------|
| `permission_handler`         | Requesting storage access permission.                  |
| `youtube_explode_dart`       | Extracting YouTube video metadata and streams.         |

## Folder Structure

```bash
/lib
  /screens
    - home_screen.dart
    - download_screen.dart
    - download_list_screen.dart
  /services
    - youtube_service.dart
    - download_service.dart
  main.dart
```

## Getting Started

### Prerequisites

- Install Flutter on your system: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
- Ensure you have a working development environment set up for Android/iOS.

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```bash
   cd youtube_download_manager
   ```
3. Install the dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Permissions

The app requests storage permissions at startup. Ensure that your device has the appropriate permissions to download and save videos.

### Usage

1. Paste a YouTube video URL in the input field on the home screen.
2. Fetch the video details to see the title, thumbnail, and author.
3. Select your desired video quality (1080p, 720p, 480p, 360p) and click "Download."
4. You can view your downloaded videos in the "Download History" screen.

## Notes

- The app was developed as part of an  assignment and showcases basic Flutter development skills.
- The project uses external libraries to interact with YouTube APIs and manage downloads efficiently.
