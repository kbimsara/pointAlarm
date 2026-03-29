import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:point_alarm/services/firestore.dart';
import 'package:point_alarm/services/notification_service.dart';

class AlarmMonitor {
  final FirestoreService _fs = FirestoreService();
  final FlutterTts _tts = FlutterTts();
  final NotificationService _notif = NotificationService();

  StreamSubscription<QuerySnapshot>? _sub;
  Timer? _pollTimer;
  List<QueryDocumentSnapshot> _latestDocs = [];
  final Set<String> _triggered = {};
  String? _user;
  bool _started = false;

  /// How often to re-check location against alarms (seconds).
  static const int _pollIntervalSec = 10;

  void start({String? user}) {
    if (_started) return;
    _started = true;
    _user = user;

    _tts.setVolume(1.0);
    _tts.setSpeechRate(0.5);

    // Listen to Firestore to keep a cached list of alarm docs.
    _sub = _fs.getAlarmsStream().listen((qs) {
      _latestDocs = qs.docs;
    });

    // Periodically poll the device location and check against cached alarms.
    _pollTimer = Timer.periodic(
      const Duration(seconds: _pollIntervalSec),
      (_) => _pollLocation(),
    );
  }

  void updateUser(String? user) {
    _user = user;
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    _pollTimer?.cancel();
    _pollTimer = null;
    _latestDocs = [];
    _triggered.clear();
    _started = false;
  }

  /// Mark a single alarm as acknowledged so it won't re-trigger.
  Future<void> acknowledgeAlarm(String id) async {
    _triggered.add(id);
    // Cancel the notification for this alarm.
    _notif.cancel(id.hashCode);
  }

  /// Stop TTS, cancel all notifications, and mark every alarm acknowledged.
  Future<void> acknowledgeAll() async {
    await _tts.stop();
    await _notif.cancelAll();
    // Mark every currently-known alarm so they won't re-fire.
    for (final doc in _latestDocs) {
      _triggered.add(doc.id);
    }
  }

  // ── Private ──────────────────────────────────────────────────────────

  Future<void> _pollLocation() async {
    if (_latestDocs.isEmpty) return;

    // Get current position once per poll cycle.
    final Position position;
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return;
      position = await Geolocator.getCurrentPosition();
    } catch (_) {
      return; // Silently skip this cycle on location errors.
    }

    for (final doc in _latestDocs) {
      try {
        final data = doc.data() as Map<String, dynamic>;

        // User filter
        if (_user != null && _user!.isNotEmpty) {
          final u = (data['user'] ?? '').toString().trim().toLowerCase();
          if (u.isEmpty || u != _user!.trim().toLowerCase()) continue;
        }

        if (!(data['isActive'] ?? false)) continue;

        final dynamic latRaw = data['lat'];
        final dynamic lngRaw = data['long'] ?? data['lng'];
        if (latRaw == null || lngRaw == null) continue;
        final double? lat =
            (latRaw is num) ? latRaw.toDouble() : double.tryParse(latRaw.toString());
        final double? lng =
            (lngRaw is num) ? lngRaw.toDouble() : double.tryParse(lngRaw.toString());
        if (lat == null || lng == null) continue;

        final nbRaw = data['notifyBeforeKm'];
        final double notifyKm = (nbRaw is num)
            ? nbRaw.toDouble()
            : (nbRaw != null ? double.tryParse(nbRaw.toString()) ?? 0.0 : 0.0);
        if (notifyKm <= 0) continue;

        final meters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          lat,
          lng,
        );

        if (meters <= notifyKm * 1000 && !_triggered.contains(doc.id)) {
          _triggered.add(doc.id);

          final label = data['label']?.toString() ?? 'Alarm';
          final desc = (data['description'] ?? data['type'] ?? '').toString();
          final distText = (meters / 1000).toStringAsFixed(2);
          final msg =
              '$label. ${desc.isNotEmpty ? '$desc. ' : ''}Distance $distText km.';

          // Show a system notification (works even with screen off).
          await _notif.showAlarmNotification(
            id: doc.id.hashCode,
            title: 'You\'re arriving! - $label',
            body:
                '${desc.isNotEmpty ? '$desc — ' : ''}$distText km away from your stop.',
          );

          // Also speak via TTS if app is in foreground.
          try {
            await _tts.speak(msg);
          } catch (_) {}
        }
      } catch (_) {
        // Skip individual alarm errors.
      }
    }
  }
}
