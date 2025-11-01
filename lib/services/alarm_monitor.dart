import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:point_alarm/services/firestore.dart';
import 'package:point_alarm/services/locationService.dart';

/// Monitors alarms in Firestore and triggers a popup when the device
/// comes within the alarm's `notifyBeforeKm` distance from its lat/lng.
class AlarmMonitor {
  final FirestoreService _fs = FirestoreService();
  final Locationservice _loc = Locationservice();
  final FlutterTts _tts = FlutterTts();
  final Map<String, AudioPlayer> _playing = {};
  StreamSubscription<QuerySnapshot>? _sub;
  final Set<String> _triggered = {};
  BuildContext? _context;
  String? _user;

  /// Start monitoring alarms. Pass a [BuildContext] used to show popups.
  void start(BuildContext context, {String? user}) {
    _context = context;
    _user = user;
    _sub?.cancel();
    _sub = _fs.getAlarmsStream().listen((qs) {
      _checkAlarms(qs.docs);
    });
    // Configure TTS for short alarm announcements
    _tts.setSharedInstance(true);
    _tts.setVolume(1.0);
    _tts.setSpeechRate(0.5);
  }

  /// Update the user filter used when monitoring (null means no filter).
  void updateUser(String? user) {
    _user = user;
  }

  /// Stop monitoring and clear state.
  void stop() {
    _sub?.cancel();
    _sub = null;
    _triggered.clear();
    // stop and dispose any playing audio
    for (final p in _playing.values) {
      try {
        p.stop();
        p.dispose();
      } catch (_) {}
    }
    _playing.clear();
  }

  /// Acknowledge (stop) a specific alarm by id.
  Future<void> acknowledgeAlarm(String id) async {
    _triggered.add(id);
    final player = _playing.remove(id);
    if (player != null) {
      try {
        await player.stop();
        await player.dispose();
      } catch (_) {}
    }
  }

  /// Acknowledge (stop) all currently playing alarms.
  Future<void> acknowledgeAll() async {
    for (final id in List<String>.from(_playing.keys)) {
      await acknowledgeAlarm(id);
    }
  }

  Future<void> _checkAlarms(List<QueryDocumentSnapshot> docs) async {
    if (_context == null) return;
    for (final doc in docs) {
      try {
        final data = doc.data() as Map<String, dynamic>;

        // Filter by user if set (case-insensitive, trimmed)
        if (_user != null && _user!.isNotEmpty) {
          final u = (data['user'] ?? '').toString().trim().toLowerCase();
          final cu = _user!.trim().toLowerCase();
          if (u.isEmpty || u != cu) continue;
        }

        final bool isActive = data['isActive'] ?? false;
        if (!isActive) continue;

        final dynamic latRaw = data['lat'];
        final dynamic lngRaw = data['long'] ?? data['lng'];
        if (latRaw == null || lngRaw == null) continue;
        final double? lat = (latRaw is num) ? latRaw.toDouble() : double.tryParse(latRaw.toString());
        final double? lng = (lngRaw is num) ? lngRaw.toDouble() : double.tryParse(lngRaw.toString());
        if (lat == null || lng == null) continue;

        final nbRaw = data['notifyBeforeKm'];
        final double notifyKm = (nbRaw is num) ? nbRaw.toDouble() : (nbRaw != null ? double.tryParse(nbRaw.toString()) ?? 0.0 : 0.0);
        if (notifyKm <= 0) continue;

        // Compute distance in meters
        final meters = await _loc.distanceTo(lat, lng);
        if (meters <= notifyKm * 1000) {
          if (!_triggered.contains(doc.id)) {
            _triggered.add(doc.id);
            // show popup on the provided context
            // Play the alarm sound in loop and also announce a short TTS
            // message. Keep the playing AudioPlayer so the sound can be
            // stopped when the user acknowledges the alarm.
            final label = data['label']?.toString() ?? 'Alarm';
            final desc = (data['description'] ?? data['type'] ?? '').toString();
            final msg = '$label. ${desc.isNotEmpty ? '$desc. ' : ''}Distance ${(meters / 1000).toStringAsFixed(2)} kilometers.';
            try {
              // Start looping asset audio if not already playing for this id
              if (!_playing.containsKey(doc.id)) {
                final player = AudioPlayer();
                await player.setReleaseMode(ReleaseMode.loop);
                // AssetSource uses the asset path relative to pubspec assets
                await player.play(AssetSource('sound.mp3'), volume: 1.0);
                _playing[doc.id] = player;
              }
              // speak a short announcement as well
              await _tts.speak(msg);
            } catch (_) {
              // ignore audio/TTS errors
            }
          }
        }
      } catch (_) {
        // ignore individual alarm errors and continue
      }
    }
  }
}
