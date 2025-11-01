import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:point_alarm/Components/popup_message.dart';
import 'package:point_alarm/services/locationService.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    // Do not fetch on every build; fetch via FAB or other explicit actions
    return Scaffold(
      backgroundColor: const Color(0xff1E1E1E),
      appBar: appBar(),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // When the user taps the map, drop a pin and center the map there
              onTap: (tapPosition, point) {
                setState(() {
                  _lat = point.latitude;
                  _long = point.longitude;
                });
                _mapController.move(point, 15.0);
              },
            ),
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
          // Search overlay (top)
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search place (e.g. Coffee shop, City)',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isSearching
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: Padding(
                                padding: EdgeInsets.all(6.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : (_searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchResults = [];
                                    });
                                  },
                                )
                              : null),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: _searchPlaces,
                    onChanged: (v) {
                      if (v.trim().length > 2) {
                        _searchPlaces(v);
                      } else if (v.trim().isEmpty) {
                        setState(() => _searchResults = []);
                      }
                    },
                  ),
                ),
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _searchResults[index];
                        return ListTile(
                          title: Text(
                            item['display_name'] ?? '',
                            style: const TextStyle(fontSize: 13),
                          ),
                          onTap: () => _selectSearchResult(item),
                        );
                      },
                    ),
                  ),
              ],
            ),
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
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(12.0),
        child: SizedBox(
          height: 35,
          child: ElevatedButton.icon(
            onPressed: (_lat != null && _long != null)
                ? () {
                    // return the selected coordinates back to the caller
                    Navigator.of(context).pop({'lat': _lat!, 'long': _long!});
                  }
                : null,
            icon: const Icon(Icons.my_location, color: Color(0xff1E1E1E)),
            label: const Text(
              'Select this location',
              style: TextStyle(color: Color(0xff1E1E1E)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff76ABAE),
              shape: const StadiumBorder(),
              elevation: 4,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      // Use Nominatim (OpenStreetMap) public search API
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(q)}&format=json&limit=6');
      final resp = await http.get(url, headers: {
        'User-Agent': 'point_alarm_app/1.0 (your-email@example.com)'
      });
      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body) as List<dynamic>;
        final results = data.cast<Map<String, dynamic>>();
        setState(() {
          _searchResults = results
              .map((m) => {
                    'display_name': m['display_name'] as String? ?? '',
                    'lat': m['lat'] as String? ?? '',
                    'lon': m['lon'] as String? ?? '',
                  })
              .toList();
        });
      } else {
        setState(() => _searchResults = []);
      }
    } catch (e) {
      setState(() => _searchResults = []);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _selectSearchResult(Map<String, dynamic> item) {
    final lat = double.tryParse(item['lat'] ?? '');
    final lon = double.tryParse(item['lon'] ?? '');
    if (lat == null || lon == null) return;
    final point = LatLng(lat, lon);
    setState(() {
      _lat = lat;
      _long = lon;
      _searchResults = [];
      _searchController.text = item['display_name'] ?? '';
    });
    _mapController.move(point, 15.0);
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
