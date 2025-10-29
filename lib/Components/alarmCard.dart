import 'package:flutter/material.dart';
import '../Pages/setAlarmPage.dart';

class AlarmCard extends StatelessWidget {
  final num id;
  final String time;
  final String label;
  final String type;
  final bool isActive;

  const AlarmCard({
    super.key,
    required this.id,
    required this.time,
    required this.label,
    required this.type,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AlarmPage(),
          ),
        );
      },
      child: Card(
        color: const Color(0xff31363F),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: ListTile(
          title: Text(
            time,
            style: const TextStyle(
              color: Color(0xffEEEEEEF),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '$type | $label',
            style: const TextStyle(color: Color(0xffEEEEEEF), fontSize: 16),
          ),
          trailing: Switch(
            value: isActive,
            onChanged: (value) {},
            activeColor: const Color(0xff76ABAE),
          ),
        ),
      ),
    );
  }
}
