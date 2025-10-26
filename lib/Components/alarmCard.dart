import 'package:flutter/material.dart';

class AlarmCard extends StatelessWidget {
  final num id;
  final String time;
  final String label;
  final String type;
  final bool isActive;

  AlarmCard({
    required this.id,
    required this.time,
    required this.label,
    required this.type,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xff31363F),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: ListTile(
        title: Text(
          time,
          style: TextStyle(
            color: Color(0xffEEEEEEF),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          type + " | " + label,
          style: TextStyle(color: Color(0xffEEEEEEF), fontSize: 16),
        ),
        trailing: Switch(
          value: isActive,
          onChanged: (value) {},
          activeColor: Color(0xff76ABAE),
        ),
      ),
    );
  }
}
