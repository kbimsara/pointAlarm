import 'package:flutter/material.dart';

class AlarmPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final bool isEditing = id != null;

    return Scaffold(
      backgroundColor: const Color(0xff1E1E1E),
      appBar: appBar(isEditing),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isEditing) ...[
              _buildDetailItem('ID', id.toString()),
              _buildDetailItem('Current Time', time ?? ''),
              _buildDetailItem('Current Label', label ?? ''),
              _buildDetailItem('Current description', description ?? ''),
              _buildDetailItem('Status', isActive == true ? 'Active' : 'Inactive'),
              const Divider(color: Color(0xff76ABAE)),
              const SizedBox(height: 20),
            ],
            const Text(
              'Set New Alarm Details',
              style: TextStyle(
                color: Color(0xffEEEEEE),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // TODO: Add form fields for new alarm details
          ],
        ),
      ),
    );
  }

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
              style: const TextStyle(
                color: Color(0xffEEEEEE),
                fontSize: 16,
              ),
            ),
          ),
        ],
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
