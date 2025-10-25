import 'package:flutter/material.dart';

class AlarmCard extends StatelessWidget {
  final String time;
  final String label;
  final bool isActive;

  AlarmCard({required this.time, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xff31363F),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: ListTile(
        leading: Icon(
          Icons.alarm,
          color: isActive ? Color(0xff76ABAE) : Colors.grey,
        ),
        title: Text(
          time,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
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