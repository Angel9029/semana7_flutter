import 'package:flutter/material.dart';
import 'package:semana7_flutter/menu_screen.dart';
import 'package:semana7_flutter/providers_screen.dart';
import 'package:semana7_flutter/employees_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Bottom Nav Bar",
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const BottomNav(),
    );
  }
}

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _seleccion = 0;

  final List<Widget> _pantallas = const [
    MenuScreen(),
    EmployeesScreen(),
    ProvidersScreen(),
  ];

  void _onItemSelected(int item) {
    setState(() {
      _seleccion = item;
    });
  }

  @override
  Widget build(BuildContext contex) {
    return Scaffold (
      body: _pantallas[_seleccion],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _seleccion,
        onTap: _onItemSelected,
        items: const [ 
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: "Menu y platillos"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Empleados"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fire_truck),
            label: "Proveedores"
          ),
         ]
        ),
    );
  }
}