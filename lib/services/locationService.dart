import 'package:geolocator/geolocator.dart';

class Locationservice {
  /// Returns the current position or throws an exception on failure.
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // Return the found position to the caller
    return position;
  }

  /// Returns the distance in meters between the device's current location
  /// and the provided `lat`/`lng` coordinates.
  ///
  /// Throws the same exceptions as [getCurrentLocation] if location cannot
  /// be obtained.
  Future<double> distanceTo(double lat, double lng) async {
    final Position current = await getCurrentLocation();
    return Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      lat,
      lng,
    );
  }

  /// Given a list of candidate points, finds the nearest point to the
  /// device's current location and returns a map with keys:
  /// {
  ///   'lat': a double latitude value,
  ///   'lng': a double longitude value,
  ///   'distanceMeters': a double distance in meters
  /// }
  ///
  /// Each candidate may be provided as a Map containing numeric `lat` and
  /// `lng` (or `long`) entries. Example:
  /// [{'lat': 12.3, 'lng': 45.6}, {'lat': 11.1, 'long': 44.4}]
  ///
  /// Returns null if the input list is empty or contains no valid points.
  Future<Map<String, dynamic>?> getNearestPoint(
      List<Map<String, dynamic>> candidates) async {
    if (candidates.isEmpty) return null;
    final Position current = await getCurrentLocation();
    double? bestDist;
    double? bestLat;
    double? bestLng;

    for (final c in candidates) {
      final dynamic latRaw = c['lat'] ?? c['latitude'];
      final dynamic lngRaw = c['lng'] ?? c['long'] ?? c['longitude'];
      if (latRaw == null || lngRaw == null) continue;
      final double? lat = (latRaw is num) ? latRaw.toDouble() : double.tryParse(latRaw.toString());
      final double? lng = (lngRaw is num) ? lngRaw.toDouble() : double.tryParse(lngRaw.toString());
      if (lat == null || lng == null) continue;
      final d = Geolocator.distanceBetween(
        current.latitude,
        current.longitude,
        lat,
        lng,
      );
      if (bestDist == null || d < bestDist) {
        bestDist = d;
        bestLat = lat;
        bestLng = lng;
      }
    }

    if (bestDist == null) return null;
    return {'lat': bestLat, 'lng': bestLng, 'distanceMeters': bestDist};
  }

}