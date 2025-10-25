import 'package:flutter/material.dart';
import 'package:point_alarm/Components/alarmCard.dart';

void main() {
  runApp(MyHomePage());
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1E1E1E),
      appBar: appBar(),
      body: Column(
        children: [
          //Alarm state
          Container(
            margin: EdgeInsets.only(top: 30),
            child: Center(
              child: Text(
                'No Alarms Set',
                style: TextStyle(
                  color: Color.fromARGB(255, 184, 181, 181),
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 50),
            child: ListView(
              shrinkWrap: true,
              children: [
                AlarmCard(time: '07:00 AM', label: 'Morning Alarm', isActive: true),
                AlarmCard(time: '08:30 AM', label: 'Workout Alarm', isActive: false),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Color(0xff31363F),
        child: Icon(Icons.add),
        foregroundColor: Color(0xff76ABAE),
      ),
    );
  }

  //App bar
  AppBar appBar() {
    return AppBar(
      backgroundColor: Color(0xff1E1E1E),
      title: Text('Alarm'),
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
      centerTitle: true,
    );
  }
}
