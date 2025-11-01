import 'package:flutter/material.dart';
import 'package:point_alarm/Components/mapCard.dart';
import 'package:point_alarm/Pages/mapPage.dart';
import 'package:point_alarm/services/locationService.dart';
import 'package:geolocator/geolocator.dart';
import 'package:point_alarm/Components/popup_message.dart';

class AlarmPage extends StatefulWidget {
  final num? id;
  final String? time;
  final String? label;
  final String? description;
  final bool? isActive;

  const AlarmPage({
    super.key,
    this.id,
    this.time,
    this.label,
    this.description,
    this.isActive,
  });

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  double? _lat;
  double? _long;

  @override
  void initState() {
    super.initState();
    // Delay the fetch until after the first frame so dialogs can be shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocation(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.id != null;

    return Scaffold(
      backgroundColor: const Color(0xff1E1E1E),
      appBar: appBar(isEditing),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isEditing) ...[
              _buildDetailItem('ID', widget.id.toString()),
              _buildDetailItem('Current Time', widget.time ?? ''),
              _buildDetailItem('Current Label', widget.label ?? ''),
              _buildDetailItem('Current description', widget.description ?? ''),
              _buildDetailItem(
                'Status',
                widget.isActive == true ? 'Active' : 'Inactive',
              ),

              // const Divider(color: Color(0xff76ABAE)),
              MapCard(lat: _lat, long: _long),
              const SizedBox(height: 20),
            ] else ...[
              _buildFormField('Set Time', TextEditingController(), '07:00 AM'),
              const SizedBox(height: 20),
              _buildFormField(
                'Set Label',
                TextEditingController(),
                'Morning Alarm',
              ),
              const SizedBox(height: 20),
              _buildFormField(
                'Set Description',
                TextEditingController(),
                'Once',
              ),
              const SizedBox(height: 15),
              MapCard(lat: _lat, long: _long),
              const SizedBox(height: 5),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // _fetchLocation(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff76ABAE),
                  ),
                  child: const Text(
                    'Select Location',
                    style: TextStyle(color: Color(0xff1E1E1E)),
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle save action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff76ABAE),
                      ),
                      child: const Text(
                        'Save Alarm',
                        style: TextStyle(color: Color(0xff1E1E1E)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
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
      // Show coordinates in a dialog using reusable helper
      await showPopupMessage<void>(
        context,
        title: 'Selected Location',
        message:
            'Latitude: ${currentPoint.latitude}\nLongitude: ${currentPoint.longitude}',
      );
    } catch (e) {
      // Handle common geolocation issues with actionable UI
      final String msg = e.toString();
      if (msg.contains('Location services are disabled')) {
        // Offer to open location settings
        // Offer to open location settings using reusable dialog
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
        // Permission denied forever — open app settings (via reusable dialog)
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

  //detail item widget
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Color(0xff76ABAE),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xffEEEEEE), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  //form field widget
  Widget _buildFormField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Color(0xffEEEEEE)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xff76ABAE)),
        hintText: 'Enter Here!',
        hintStyle: TextStyle(color: Color(0xffAAAAAA)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xff76ABAE)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xff76ABAE)),
        ),
      ),
    );
  }

  //App bar
  AppBar appBar(bool isEditing) {
    return AppBar(
      backgroundColor: const Color(0xff1E1E1E),
      iconTheme: const IconThemeData(color: Color(0xffEEEEEE)),
      title: Text(isEditing ? 'Edit Alarm' : 'New Alarm'),
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
