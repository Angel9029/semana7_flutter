import 'package:flutter/material.dart';

void main() {
  runApp(const ClientsScreen());
}

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello Client!'),
        ),
      ),
    );
  }
}
