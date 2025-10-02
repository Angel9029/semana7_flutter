import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const HomeScreen());
}

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: HomeScreen()
//       // Scaffold(
//         // body: Center(
//         //   child: Text('Hello Home!'),
//         // ),
//       // ),
//     );
//   }
// }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> productos = [];
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _precio = TextEditingController();
  var noProd;

  @override
  void initState() {
    super.initState();
     noProd = CircularProgressIndicator();
    obtenerProductos();
  }

  Future<void> obtenerProductos() async {
    try {
      // Accede a la colección 'productos' y obtiene todos los documentos
      final snapshot = await FirebaseFirestore.instance.collection('Productos').get();
      // Transforma los documentos en una lista de mapas
      setState(() {
        productos = snapshot.docs
          .map((doc) => {
          'id': doc.id, // Guarda el ID del documento
          ...doc.data(), // Agrega el contenido del documento
        })
        .toList();

      noProd = productos.isEmpty ? Text("No existen productos") : null;
      });
    } catch (e) {
      print('Error al obtener productos: $e');
    }
  }

  Future<void> crearProductos() async {
    try {
      final nombre = _nombre.text.trim();
      final precio = double.tryParse(_precio.text.trim());
      // Accede a la colección 'productos' y obtiene todos los documentos
      final snapshot = await FirebaseFirestore.instance.collection('Productos').add({
        'nombre': nombre,
        'precio': precio,
      });
      // Transforma los documentos en una lista de mapas
      _nombre.clear();
      _precio.clear();

    } catch (e) {
      print('Error al obtener productos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(title: const Text('Lista de Productos')),
    // body: productos.isEmpty
    // ? Center(child: noProd)  // Cargando...
    //   : ListView.builder(
    //   itemCount: productos.length,
    //   itemBuilder: (context, index) {
    //     final producto = productos[index];
    //     return ListTile(
    //       title: Text(producto['nombre'] ?? 'Sin nombre'),
    //       subtitle: Text('Precio: S/ ${producto['precio'] ?? '0.00'}'),
    //       trailing: Text('ID: ${producto['id']}'),
    //       );
    //     },
    //   ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: "Nombre"
            ),
            controller: _nombre,
          ),
          TextField(
            decoration: InputDecoration(
              labelText: "Precio"
            ),
            controller: _precio,
            // keyboardType: TextInputType.phone,
          ),
          ElevatedButton(
            onPressed: crearProductos, 
            child: Text("Agregar")
            )
        ],
      ),
      ),
    );
  }
}
