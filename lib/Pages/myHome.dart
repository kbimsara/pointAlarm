import 'package:flutter/material.dart';

void main() {
  runApp(MyHomePage());
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Color(0xff1E1E1E),
      appBar: appBar(),
      body: Center(
        child: Text('Welcome to My Home Page!',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xffEEEEEE),
            )),
        ),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Color(0xff1E1E1E),
      title: Text('Point Alarm'),
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xffEEEEEE),
      ),
      centerTitle: true,
    );
  }
}
