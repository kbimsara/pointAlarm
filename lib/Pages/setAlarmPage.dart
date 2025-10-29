import 'package:flutter/material.dart';

void main() {
  runApp(AlarmPage());
}

class AlarmPage extends StatelessWidget {
  const AlarmPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1E1E1E),
      appBar: appBar(),
      body: Scaffold(
        backgroundColor: Color(0xff1E1E1E),
        body: Center(
          child: Text(
            'Alarm Page',
            style: TextStyle(color: Color(0xffEEEEEE), fontSize: 24),
          ),
        ),
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
