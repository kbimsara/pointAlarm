import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapCard extends StatelessWidget {
  /// Latitude to show (nullable).
  final double? lat;
  /// Longitude to show (nullable).
  final double? long;

  const MapCard({super.key, required this.lat, required this.long});

  @override
  Widget build(BuildContext context) {
    // Version-safe: render tiles and overlay a centered pin + coords box
    return Card(
      color: const Color(0xff31363F),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: SizedBox(
        height: 200,
        child: Stack(
          children: [
            FlutterMap(
              options: const MapOptions(),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app.point_alarm',
                ),
              ],
            ),
            // Center pin overlay
            const Center(
              child: Icon(
                Icons.location_on,
                color: Colors.red,
                size: 48,
                shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
              ),
            ),
            // Coordinates box
            if (lat != null && long != null)
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lat: ${lat!.toStringAsFixed(6)}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Lng: ${long!.toStringAsFixed(6)}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
