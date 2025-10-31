import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapCard extends StatelessWidget {
  final String label;
  final String description;

  const MapCard({super.key, required this.label, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff31363F),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: SizedBox(
        height: 200,
        child: FlutterMap(
          options: const MapOptions(),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
          ],
        ),
      ),
    );
  }
}
