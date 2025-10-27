# pointAlarm

A Flutter alarm / notification project that uses Firebase Firestore for storing alarm data and supports multiple platforms (Android, iOS, Web, Windows). This README gives quick setup and run instructions, an overview of the project structure, and notes for contributors.

## Highlights

- Uses Flutter (Dart) and Firebase (firebase_core, cloud_firestore)
- Cross-platform: Android, iOS, Web, Windows (project contains platform folders)
- Custom fonts included (Poppins)

## Prerequisites

- Flutter SDK (compatible with Dart SDK >= 3.7.2 as specified in `pubspec.yaml`) — install from https://flutter.dev
- Platform toolchains for targets you want to run: Android SDK / Xcode (macOS) / Visual Studio (Windows) / Web supported by Flutter
- Firebase project and platform config files (Android `google-services.json` is present in `app/` — check `android/app/google-services.json`)

## Quick setup

1. Install Flutter and ensure `flutter` is on your PATH.
2. From the repository root, fetch packages:

```powershell
flutter pub get
```

3. If you intend to use Firebase, ensure the Firebase configuration files are in place:

- Android: `android/app/google-services.json` (already in the repo under `app/`)
- iOS/macOS: add the `GoogleService-Info.plist` to the respective Runner targets
- Web: add Firebase config to `web/index.html` or use `firebase_options.dart` (see `lib/firebase_options.dart`)

Note: `lib/firebase_options.dart` exists for ease of initializing Firebase using the Firebase CLI `flutterfire` tooling. If you regenerated Firebase options, replace this file accordingly.

## Running the app

- Run on the default device/emulator attached:

```powershell
flutter run
```

- Run on a specific device, e.g., Android emulator or Windows desktop:

```powershell
flutter devices
flutter run -d <device-id>
```

## Recommended checks

```powershell
flutter pub get
flutter analyze
flutter test
```

## Project structure (selected)

- `lib/` — Dart source code
	- `main.dart` — app entrypoint
	- `firebase_options.dart` — generated Firebase configuration
	- `Components/` — UI components (e.g., `alarmCard.dart`)
	- `Pages/` — app pages (e.g., `myHome.dart`)
	- `services/` — platform/service integration (e.g., `firestore.dart`)
- `android/`, `ios/`, `windows/`, `macos/`, `linux/` — platform projects
- `fonts/` — included fonts (Poppins)

## Firebase notes

- The project depends on `firebase_core` and `cloud_firestore`. Confirm your Firebase project settings match the app's package id/bundle id and that you have uploaded the correct `google-services.json` / `GoogleService-Info.plist`.

## Contributing

Contributions are welcome. Suggested workflow:

1. Fork the repository.
2. Create a feature branch.
3. Add tests for new behavior where appropriate.
4. Open a pull request describing your changes.

## License

Include a LICENSE file in the repository if you plan to open-source this project. If none is present, add one to clarify terms.

