# Point Alarm

A location-based alarm app built with Flutter for public transport commuters. Set your drop-off location before you sleep, and the app will alert you with notifications and voice alerts as you approach your stop — even with the screen off.

## The Problem

Commuters using buses, trains, or other public transport often fall asleep and miss their stop. Point Alarm solves this by continuously monitoring your GPS location in the background and triggering high-priority notifications when you're within range of your destination.

## Features

- **Location-based alarms** — Set a drop-off point on an interactive map, and get alerted when you're close
- **Background location monitoring** — Periodic GPS polling every 10 seconds, works with the screen off
- **System notifications** — High-priority alarm-style notifications that wake you up
- **Voice alerts (TTS)** — Text-to-speech announces your stop name and distance when in foreground
- **Configurable trigger radius** — Choose 0.25 km, 0.5 km, or 0.75 km notification distance
- **Interactive map** — OpenStreetMap with search (Nominatim API), tap-to-pin, and GPS location
- **Multi-user support** — Create user profiles, filter alarms per user
- **Real-time sync** — Alarm data stored in Firebase Firestore, synced across devices
- **Toggle alarms** — Enable/disable individual alarms without deleting them

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart SDK >= 3.7.2) |
| Database | Firebase Firestore |
| Maps | flutter_map + OpenStreetMap tiles |
| Location | Geolocator |
| Notifications | flutter_local_notifications |
| Voice | flutter_tts |
| Permissions | permission_handler |

## Prerequisites

- Flutter SDK (>= 3.7.2) — [flutter.dev](https://flutter.dev)
- Android SDK (minSdk 21) / Xcode (iOS) / Visual Studio (Windows)
- A Firebase project with Firestore enabled

## Quick Setup

1. Clone the repository:

```bash
git clone https://github.com/your-username/pointAlarm.git
cd pointAlarm
```

2. Install dependencies:

```bash
flutter pub get
```

3. Configure Firebase:
   - **Android:** Place `google-services.json` in `android/app/`
   - **iOS/macOS:** Add `GoogleService-Info.plist` to the Runner target
   - Or regenerate with `flutterfire configure` (see `lib/firebase_options.dart`)

4. Run the app:

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                          # App entry point, Firebase & notification init
├── firebase_options.dart              # Generated Firebase config
├── Pages/
│   ├── myHome.dart                    # Home page — alarm list, user management
│   ├── setAlarmPage.dart              # Create / edit alarm
│   └── mapPage.dart                   # Interactive map for location selection
├── Components/
│   ├── alarmCard.dart                 # Alarm list item with toggle switch
│   ├── mapCard.dart                   # Map preview widget
│   └── popup_message.dart             # Reusable dialog helper
└── services/
    ├── firestore.dart                 # Firestore CRUD operations
    ├── locationService.dart           # GPS location utilities
    ├── alarm_monitor.dart             # Periodic location polling & alarm triggering
    └── notification_service.dart      # Local notification management
```

## How It Works

1. **Create an alarm** — Set a label, description, and pick your drop-off location on the map
2. **Choose notification distance** — 0.25 / 0.5 / 0.75 km radius
3. **Board your transport and sleep** — The app monitors your GPS every 10 seconds
4. **Get alerted** — When you enter the trigger radius:
   - A high-priority system notification fires (works with screen off)
   - TTS announces: *"[Label]. [Description]. Distance X.XX km."*
5. **Acknowledge** — Tap "Stop alarms" to silence all alerts

## Android Permissions

The app requests the following permissions:

| Permission | Purpose |
|-----------|---------|
| `ACCESS_FINE_LOCATION` | GPS-based location tracking |
| `ACCESS_COARSE_LOCATION` | Approximate location fallback |
| `ACCESS_BACKGROUND_LOCATION` | Location monitoring with screen off |
| `FOREGROUND_SERVICE` | Keep location polling alive |
| `POST_NOTIFICATIONS` | System alarm notifications (Android 13+) |
| `WAKE_LOCK` | Prevent CPU sleep during checks |
| `VIBRATE` | Vibration with alarm notifications |

## Development

```bash
flutter pub get        # Install dependencies
flutter analyze        # Static analysis
flutter test           # Run tests
flutter run            # Run on connected device
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Open a pull request

## License

Add a LICENSE file to clarify terms if open-sourcing this project.
