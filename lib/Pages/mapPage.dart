import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:point_alarm/Components/popup_message.dart';
import 'package:point_alarm/services/locationService.dart';

void main() {
  runApp(const MapPage());
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  double? _lat;
  double? _long;
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    _fetchLocation(context);
    return Scaffold(
      backgroundColor: const Color(0xff1E1E1E),
      appBar: appBar(),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app.point_alarm',
              ),
              MarkerLayer(
                markers:
                    _lat != null && _long != null
                        ? [
                          Marker(
                            point: LatLng(_lat!, _long!),
                            width: 48,
                            height: 48,
                            // older/newer flutter_map versions expect `child` for Marker
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ]
                        : [],
              ),
            ],
          ),
          if (_lat != null && _long != null)
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lat: ${_lat!.toStringAsFixed(6)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      'Lng: ${_long!.toStringAsFixed(6)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _fetchLocation(context),
        label: const Text('Get location'),
        icon: const Icon(Icons.my_location),
      ),
    );
  }

  void _fetchLocation(BuildContext context) async {
    // Fetch current location and show a preview
    final location = Locationservice();
    try {
      final currentPoint = await location.getCurrentLocation();
      setState(() {
        _lat = currentPoint.latitude;
        _long = currentPoint.longitude;
      });
      // center map to new location
      _mapController.move(LatLng(_lat!, _long!), 15.0);
    } catch (e) {
      // Handle common geolocation issues with actionable UI
      final String msg = e.toString();
      if (msg.contains('Location services are disabled')) {
        // Offer to open location settings
        await showPopupMessage<void>(
          context,
          title: 'Location Services Disabled',
          message:
              'Location services are turned off. Please enable them in settings.',
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Geolocator.openLocationSettings();
                Navigator.of(context).pop();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      } else if (msg.contains('permanently denied')) {
        // Permission denied forever — open app settings
        await showPopupMessage<void>(
          context,
          title: 'Location Permission Required',
          message:
              'Location permission is permanently denied. Please enable it from app settings.',
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Geolocator.openAppSettings();
                Navigator.of(context).pop();
              },
              child: const Text('Open App Settings'),
            ),
          ],
        );
      } else {
        // Generic error
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not get location: $e')));
      }
    }
  }

  //App bar
  AppBar appBar() {
    return AppBar(
      backgroundColor: const Color(0xff1E1E1E),
      iconTheme: const IconThemeData(color: Color(0xffEEEEEE)),
      title: Text('Map Page'),
      titleTextStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: Color(0xffEEEEEE),
      ),
      centerTitle: true,
    );
  }
}
