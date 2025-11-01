import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Small map preview card that recenters when [lat]/[long] update.
class MapCard extends StatefulWidget {
  /// Latitude to show (nullable).
  final double? lat;
  /// Longitude to show (nullable).
  final double? long;

  const MapCard({super.key, required this.lat, required this.long});

  @override
  State<MapCard> createState() => _MapCardState();
}

class _MapCardState extends State<MapCard> {
  final MapController _controller = MapController();

  @override
  void initState() {
    super.initState();
    // If initial coords are present, move after the first frame
    if (widget.lat != null && widget.long != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.move(LatLng(widget.lat!, widget.long!), 15.0);
      });
    }
  }

  @override
  void didUpdateWidget(covariant MapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When coordinates change, recenter the map
    if ((widget.lat != null && widget.long != null) &&
        (oldWidget.lat != widget.lat || oldWidget.long != widget.long)) {
      _controller.move(LatLng(widget.lat!, widget.long!), 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff31363F),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: SizedBox(
        height: 200,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _controller,
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
            if (widget.lat != null && widget.long != null)
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
                        'Lat: ${widget.lat!.toStringAsFixed(6)}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Lng: ${widget.long!.toStringAsFixed(6)}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
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

