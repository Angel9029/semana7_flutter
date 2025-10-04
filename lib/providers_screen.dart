import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProvidersScreen());
}

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  List<Map<String, dynamic>> proveedores = [];
  final TextEditingController _razonSocial = TextEditingController();
  final TextEditingController _ruc = TextEditingController();
  final TextEditingController _direccion = TextEditingController();
  final TextEditingController _contacto = TextEditingController();
  final TextEditingController _email = TextEditingController();

  String? _categoria = 'Carnes';

  var noProv;

  @override
  void initState() {
    super.initState();
    noProv = CircularProgressIndicator();
    obtenerMenu();
  }

  Future<void> obtenerMenu() async {
    try {
      // Accede a la colección 'productos' y obtiene todos los documentos
      final snapshot = await FirebaseFirestore.instance
          .collection('proveedores')
          .get();
      // Transforma los documentos en una lista de mapas
      setState(() {
        proveedores = snapshot.docs
            .map(
              (doc) => {
                'id': doc.id, // Guarda el ID del documento
                ...doc.data(), // Agrega el contenido del documento
              },
            )
            .toList();

        noProv = proveedores.isEmpty ? Text("No existen proveedores") : null;
      });
    } catch (e) {
      mostrarSnackBar('Error al obtener proveedores: $e');
    }
  }

  Future<void> crearMenu() async {
    try {
      final rsocial = _razonSocial.text.trim();
      final ruc = _ruc.text.trim();
      final categoria = _categoria.toString().trim();
      final contacto = _contacto.text.trim();
      final direccion = _direccion.text.trim();
      final email = _email.text.trim();
      // Accede a la colección 'productos' y obtiene todos los documentos
      if (rsocial.isEmpty) {
        mostrarSnackBar("La razón social no puede estar vacía");
        return;
      }

      if (ruc.isEmpty) {
        mostrarSnackBar("El RUC no puede estar vacío");
        return;
      }

      if (ruc.length != 11 || int.tryParse(ruc) == null) {
        mostrarSnackBar("El RUC debe tener 11 dígitos");
        return;
      }

      if (categoria.isEmpty) {
        mostrarSnackBar("La categoría no puede estar vacía");
        return;
      }

      if (contacto.length != 9 || int.tryParse(contacto) == null) {
        mostrarSnackBar("El contacto debe tener 9 dígitos");
        return;
      }

      if (direccion.isEmpty) {
        mostrarSnackBar("La dirección no puede estar vacía");
        return;
      }

      if (email.isEmpty) {
        mostrarSnackBar("El email no puede estar vacío");
        return;
      }

      if (!email.contains('@') || !email.contains('.')) {
        mostrarSnackBar("El email debe ser válido");
        return;
      }

      await FirebaseFirestore.instance.collection('proveedores').add({
        'rsocial': rsocial,
        'ruc': ruc,
        'direccion': direccion,
        'categoria': categoria,
        'contacto': contacto,
        'email': email,
      });
      // Transforma los documentos en una lista de mapas
      _razonSocial.clear();
      _ruc.clear();
      _direccion.clear();
      _contacto.clear();
      _email.clear();

      obtenerMenu();
      mostrarSnackBar("Proveedor agregado correctamente ✅");
    } catch (e) {
      mostrarSnackBar('Error al obtener productos: $e');
    }
  }

  void mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
  // Future<void> actualizarProductos(String id) async {
  //   try {
  //     final nombre = _nombre.text.trim();
  //     final precio = double.tryParse(_precio.text.trim());
  //     // Accede a la colección 'productos' y obtiene todos los documentos
  //     // Transforma los documentos en una lista de mapas
  //     await FirebaseFirestore.instance.collection('Productos').doc(id).update({
  //       'nombre': nombre,
  //       'precio': precio,
  //     });

  //     _nombre.clear();
  //     _precio.clear();

  //   } catch (e) {
  //     print('Error al obtener productos: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Proveedores')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 16,
          children: [
            ExpansionTile(
              title: const Text("Agregar nuevo Proveedor"),
              childrenPadding: const EdgeInsets.all(16),
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Razón Social"),
                  controller: _razonSocial,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "RUC"),
                  controller: _ruc,
                  // keyboardType: TextInputType.phone,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Dirección"),
                  controller: _direccion,
                  // keyboardType: TextInputType.phone,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Contacto"),
                  controller: _contacto,
                  // keyboardType: TextInputType.phone,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Email"),
                  controller: _email,
                  // keyboardType: TextInputType.phone,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      DropdownMenu(
                        width: 200,
                        dropdownMenuEntries: [
                          DropdownMenuEntry(value: 'Carnes', label: 'Carnes'),
                          DropdownMenuEntry(
                            value: 'Verduras',
                            label: 'Verduras',
                          ),
                          DropdownMenuEntry(value: 'Bebidas', label: 'Bebidas'),
                          DropdownMenuEntry(value: 'Insumos', label: 'Insumos'),
                        ],
                        initialSelection: _categoria,
                        onSelected: (String? value) {
                          setState(() {
                            _categoria = value;
                          });
                        },
                        label: Text("Categoría"),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(onPressed: crearMenu, child: Text("Agregar")),
              ],
            ),
            Expanded(
              child: proveedores.isEmpty
                  ? Center(child: noProv) // Cargando...
                  : ListView.builder(
                      padding: EdgeInsets.only(top: 20),
                      itemCount: proveedores.length,
                      itemBuilder: (context, index) {
                        final proveedor = proveedores[index];
                        return ListTile(
                          leading: Icon(Icons.person),
                          title: Text(proveedor['rsocial'] ?? 'Sin nombre'),
                          subtitle: Text(
                            'RUC: ${proveedor['ruc'] ?? 'N/A'}\n'
                            'Dirección: ${proveedor['direccion'] ?? 'N/A'}\n'
                            'Contacto: ${proveedor['contacto'] ?? 'N/A'}\n'
                            'Email: ${proveedor['email'] ?? 'N/A'}\n'
                            'Categoría: ${proveedor['categoria'] ?? 'N/A'}',
                          ),
                          trailing: Text(
                            'ID: ${proveedor['id'].toString().substring(0, 5)}...',
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
