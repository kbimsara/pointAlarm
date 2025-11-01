import 'package:flutter/material.dart';
// date formatting is done without external packages to avoid adding dependencies
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import '../Pages/setAlarmPage.dart';
import 'package:point_alarm/services/firestore.dart';

class AlarmCard extends StatelessWidget {
  final String id;
  final String time;
  final String label;
  final String description;
  final double? notifyBeforeKm;
  final bool isActive;
  final String? createdBy;
  final dynamic createdAt;

  const AlarmCard({
    super.key,
    required this.id,
    required this.time,
    required this.label,
    required this.description,
    this.notifyBeforeKm,
    this.isActive = false,
    this.createdBy,
    this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => AlarmPage(
                  id: id,
                  time: time,
                  label: label,
                  description: description,
                  isActive: isActive,
                ),
          ),
        );
      },
      child: Card(
        color: const Color(0xff31363F),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: ListTile(
          title: Text(
            label,
            style: const TextStyle(
              color: Color(0xffEEEEEE),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notifyBeforeKm != null && notifyBeforeKm! > 0
                    ? '$description · Notify: ${notifyBeforeKm!.toStringAsFixed(2)}km'
                    : '$description',
                style: const TextStyle(color: Color(0xffEEEEEE), fontSize: 16),
              ),
              const SizedBox(height: 6),
              if (createdBy != null || createdAt != null)
                Text(
                  _buildMetaText(),
                  style: const TextStyle(color: Color(0xffAAAAAA), fontSize: 12),
                ),
            ],
          ),
          trailing: Switch(
            value: isActive,
            onChanged: (value) async {
              try {
                final fs = FirestoreService();
                await fs.updateAlarm(id, {'isActive': value});
              } catch (e) {
                // ignore errors; the list will refresh via stream
              }
            },
            activeColor: const Color(0xff76ABAE),
          ),
        ),
      ),
    );
  }

  String _buildMetaText() {
    final parts = <String>[];
    if (createdBy != null && createdBy!.isNotEmpty) parts.add('By $createdBy');
    if (createdAt != null) {
      try {
        DateTime dt;
        if (createdAt is DateTime) {
          dt = createdAt as DateTime;
        } else if (createdAt is Timestamp) {
          dt = (createdAt as Timestamp).toDate();
        } else {
          // try dynamic toDate
          dt = (createdAt as dynamic).toDate();
        }
        parts.add(dt.toLocal().toString().split('.').first);
      } catch (e) {
        parts.add(createdAt.toString());
      }
    }
    return parts.join(' · ');
  }
}
