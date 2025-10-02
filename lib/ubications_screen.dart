import 'package:flutter/material.dart';

void main() {
  runApp(const UbicationsScreen());
}

class UbicationsScreen extends StatelessWidget {
  const UbicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello Ubications!'),
        ),
      ),
    );
  }
}
