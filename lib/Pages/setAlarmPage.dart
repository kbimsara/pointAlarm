import 'package:flutter/material.dart';
import 'package:point_alarm/Components/mapCard.dart';
import 'package:point_alarm/Pages/mapPage.dart';
import 'package:point_alarm/services/firestore.dart';
import 'package:point_alarm/services/locationService.dart';
import 'package:geolocator/geolocator.dart';
import 'package:point_alarm/Components/popup_message.dart';

class AlarmPage extends StatefulWidget {
  final String? id;
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
  // Persist the selected dropdown value across rebuilds
  int _selectedValue = 1;
  // Controllers for the form fields (moved to state so they persist)
  late final TextEditingController titleController;
  late final TextEditingController lableController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    lableController = TextEditingController();
  descriptionController = TextEditingController();
    // Delay the fetch until after the first frame so dialogs can be shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocation(context);
      // If editing an existing alarm, load it
      if (widget.id != null) {
        _loadAlarm();
      }
    });
  }

  Future<void> _loadAlarm() async {
    try {
      final fs = FirestoreService();
      final doc = await fs.getAlarmById(widget.id!);
      if (!doc.exists) return;
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        titleController.text = data['time']?.toString() ?? '';
        lableController.text = data['label']?.toString() ?? '';
        descriptionController.text = data['description']?.toString() ?? data['type']?.toString() ?? '';
        _lat = (data['lat'] is num) ? (data['lat'] as num).toDouble() : (data['lat'] != null ? double.tryParse(data['lat'].toString()) : null);
        _long = (data['long'] is num) ? (data['long'] as num).toDouble() : (data['long'] != null ? double.tryParse(data['long'].toString()) : null);
        // If notifyBeforeKm is present map back to selected value
        final nb = data['notifyBeforeKm'];
        if (nb == 0.25) _selectedValue = 1;
        else if (nb == 0.5) _selectedValue = 2;
        else if (nb == 0.75) _selectedValue = 3;
      });
    } catch (e) {
      // ignore load errors for now
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    lableController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.id != null;

  // FirestoreService will be used in saveAlarm

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
              _buildFormField('Set Time', titleController, '07:00 AM'),
              const SizedBox(height: 20),
                _buildFormField('Set Label', lableController, 'Morning Alarm'),
                const SizedBox(height: 20),
                _buildFormField('Set Description', descriptionController, 'Once'),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Notify Before:',
                    style: TextStyle(
                      color: Color(0xff76ABAE),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),
                  DropdownButton<int>(
                    value: _selectedValue,
                    dropdownColor: const Color(0xff31363F),
                    style: const TextStyle(color: Color(0xffEEEEEE)),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('0.25km')),
                      DropdownMenuItem(value: 2, child: Text('0.5km')),
                      DropdownMenuItem(value: 3, child: Text('0.75km')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedValue = value!;

                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 15),
              MapCard(lat: _lat, long: _long),
              const SizedBox(height: 5),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Open map page and await selected location
                    () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MapPage(),
                        ),
                      );
                      if (result != null && result is Map) {
                        final lat = result['lat'];
                        final lon =
                            result['long'] ?? result['lng'] ?? result['lon'];
                        if (lat != null && lon != null) {
                          setState(() {
                            _lat =
                                (lat is double)
                                    ? lat
                                    : double.tryParse(lat.toString());
                            _long =
                                (lon is double)
                                    ? lon
                                    : double.tryParse(lon.toString());
                          });
                        }
                      }
                    }();
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
                      onPressed: () async {
                            // Handle save action
                            await saveAlarm();
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
      // await showPopupMessage<void>(
      //   context,
      //   title: 'Selected Location',
      //   message:
      //       'Latitude: ${currentPoint.latitude}\nLongitude: ${currentPoint.longitude}',
      // );
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
      actions: isEditing
          ? [
              IconButton(
                onPressed: () async {
                  // Confirm delete
                  final confirm = await showPopupMessage<bool>(
                    context,
                    title: 'Delete Alarm',
                    message: 'Are you sure you want to delete this alarm?',
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                  if (confirm == true) {
                    try {
                      final fs = FirestoreService();
                      await fs.deleteAlarm(widget.id!);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Alarm deleted')));
                      Navigator.of(context).pop();
                    } catch (e) {
                      if (!mounted) return;
                      await showPopupMessage<void>(
                        context,
                        title: 'Delete failed',
                        message: 'Could not delete alarm: $e',
                      );
                    }
                  }
                },
                icon: const Icon(Icons.delete),
              )
            ]
          : null,
      titleTextStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: Color(0xffEEEEEE),
      ),
      centerTitle: true,
    );
  }

  printDetails() {
    print('Alarm Details:');
    print('ID: ${widget.id}');
    print('Label: ${widget.label}');
    print('Description: ${widget.description}');
    print('Is Active: ${widget.isActive}');
  }

  Future<void> saveAlarm() async {
    final fs = FirestoreService();
    final time = titleController.text.trim();
    final label = lableController.text.trim();
    // Map selectedValue to a distance in km
    double notifyBeforeKm = 0.25;
    if (_selectedValue == 2) notifyBeforeKm = 0.5;
    if (_selectedValue == 3) notifyBeforeKm = 0.75;

    final Map<String, dynamic> doc = {
      'time': time.isNotEmpty ? time : null,
      'label': label.isNotEmpty ? label : null,
      'description': descriptionController.text.isNotEmpty ? descriptionController.text : null,
      'isActive': true,
      'notifyBeforeKm': notifyBeforeKm,
      'lat': _lat,
      'long': _long,
    };

    try {
      if (widget.id != null) {
        // update existing document
        await fs.updateAlarm(widget.id!, doc);
      } else {
        await fs.addAlarm(doc);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.id != null ? 'Alarm updated' : 'Alarm saved')),
      );
      // Optionally navigate back after saving
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      await showPopupMessage<void>(
        context,
        title: 'Save failed',
        message: 'Could not save alarm: $e',
      );
    }
  }
}
