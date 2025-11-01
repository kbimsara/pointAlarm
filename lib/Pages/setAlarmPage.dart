import 'package:flutter/material.dart';
import 'package:point_alarm/Components/mapCard.dart';
import 'package:point_alarm/Pages/mapPage.dart';
import 'package:point_alarm/services/firestore.dart';
// location fetching removed from this page to avoid auto-updating MapCard
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
    // Delay actions until after the first frame. Do NOT auto-fetch device location here
    // to avoid overwriting any existing alarm coordinates or unexpectedly moving the MapCard.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If editing an existing alarm, load it. Do not call _fetchLocation automatically.
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
              // Editable fields when editing an existing alarm
              // Label
              _buildFormField('Label', lableController, 'Morning Alarm'),
              const SizedBox(height: 16),
              // Description
              _buildFormField('Description', descriptionController, 'Once'),
              const SizedBox(height: 12),
              // Notify before selector
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
              const SizedBox(height: 12),
              MapCard(lat: _lat, long: _long),
              const SizedBox(height: 12),
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
                        final lon = result['long'] ?? result['lng'] ?? result['lon'];
                        if (lat != null && lon != null) {
                          setState(() {
                            _lat = (lat is double) ? lat : double.tryParse(lat.toString());
                            _long = (lon is double) ? lon : double.tryParse(lon.toString());
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
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Update details (save will call update when widget.id != null)
                    await saveAlarm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff76ABAE),
                  ),
                  child: const Text(
                    'Update Details',
                    style: TextStyle(color: Color(0xff1E1E1E)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ] else ...[
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

  // Location fetching moved to MapPage; no automatic fetch on this page.

  // (detail view removed) Editable form fields are rendered above for both create and edit modes.

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
