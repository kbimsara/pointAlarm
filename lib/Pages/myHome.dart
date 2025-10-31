import 'package:flutter/material.dart';
import 'package:point_alarm/Components/alarmCard.dart';
import 'package:point_alarm/Pages/setAlarmPage.dart';
import 'package:point_alarm/services/firestore.dart';

void main() {
  runApp(MyHomePage());
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();
  void openBox() {
    // Function to open a box or perform an action
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xff31363F),
          title: Text('Open Box', style: TextStyle(color: Color(0xffEEEEEEF))),
          content: TextField(
            controller: textController,
            style: TextStyle(color: Color(0xffEEEEEEF)),
            decoration: InputDecoration(
              hintText: 'Box opened!',
              hintStyle: TextStyle(color: Color(0xffAAAAAA)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xff76ABAE)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xff76ABAE)),
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xff1E1E1E)),
                ),
                onPressed: () {
                  firestoreService.addAlarm(
                    textController.text,
                    true,
                    "label1",
                    "type1",
                  );
                  // Navigator.of(context).pop();
                  textController.clear();
                },
                child: Text('Save', style: TextStyle(color: Color(0xff76ABAE))),
              ),
            ),
          ],
        );
      },
    );
  }

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
                AlarmCard(
                  id: 1,
                  time: '07:00 AM',
                  label: 'Morning Alarm',
                  description: 'Once',
                  isActive: true,
                ),
                AlarmCard(
                  id: 2,
                  time: '08:30 AM',
                  label: 'Workout Alarm',
                  description: 'Once',
                  isActive: false,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // onPressed: openBox,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AlarmPage(
                    id: null,
                    time: null,
                    label: null,
                    description: null,
                    isActive: null,
                  ),
            ),
          );
        },
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
