import 'package:flutter/material.dart';
import '../Pages/setAlarmPage.dart';
import 'package:point_alarm/services/firestore.dart';

class AlarmCard extends StatelessWidget {
  final String id;
  final String time;
  final String label;
  final String description;
  final double? notifyBeforeKm;
  final bool isActive;

  const AlarmCard({
    super.key,
    required this.id,
    required this.time,
    required this.label,
    required this.description,
    this.notifyBeforeKm,
    this.isActive = false,
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
              color: Color(0xffEEEEEEF),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            notifyBeforeKm != null && notifyBeforeKm! > 0
                ? '$description · Notify: ${notifyBeforeKm!.toStringAsFixed(2)}km'
                : '$description',
            style: const TextStyle(color: Color(0xffEEEEEEF), fontSize: 16),
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
}
