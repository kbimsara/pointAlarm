import 'package:flutter/material.dart';

void main() {
  runApp(MyHomePage());
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Home Page'),
        centerTitle: true,
      ),
      body: Center(
        child: Text('Welcome to My Home Page!'),
      ),
    );
  }
}