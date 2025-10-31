import 'package:flutter/material.dart';

void main() {
  runApp(const MapPage());
}

class MapPage extends StatelessWidget {
  const MapPage({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Map Page')),
        body: const Center(child: Text('Map Page Content')),
      ),
    );
  }
}
