import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MenuScreen());
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

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<Map<String, dynamic>> platillos = [];
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _precio = TextEditingController();
  final TextEditingController _porcion = TextEditingController();

  String? _categoria = 'Pollo a la brasa';
  bool _disponibilidad = true;

  var noProd;

  @override
  void initState() {
    super.initState();
    noProd = CircularProgressIndicator();
    obtenerMenu();
  }

  Future<void> obtenerMenu() async {
    try {
      // Accede a la colección 'productos' y obtiene todos los documentos
      final snapshot = await FirebaseFirestore.instance
          .collection('menu')
          .get();
      // Transforma los documentos en una lista de mapas
      setState(() {
        platillos = snapshot.docs
            .map(
              (doc) => {
                'id': doc.id, // Guarda el ID del documento
                ...doc.data(), // Agrega el contenido del documento
              },
            )
            .toList();

        noProd = platillos.isEmpty ? Text("No existen productos") : null;
      });
    } catch (e) {
      print('Error al obtener productos: $e');
    }
  }

  Future<void> crearMenu() async {
    try {
      final nombre = _nombre.text.trim();
      final precio = double.tryParse(_precio.text.trim());
      final categoria = _categoria.toString().trim();
      final porcion = int.tryParse(_porcion.text.trim());
      final disponibilidad = _disponibilidad;
      // Accede a la colección 'productos' y obtiene todos los documentos
      if (nombre.isEmpty) {
        mostrarSnackBar("El nombre no puede estar vacío");
        return;
      }

      if (porcion == null) {
        mostrarSnackBar("La porción debe ser un número entero (ej: 12 o 1)");
        return;
      }

      if (precio == null) {
        mostrarSnackBar("El precio debe ser numérico (ej: 12 o 12.50)");
        return;
      }

      if (categoria.isEmpty) {
        mostrarSnackBar("Selecciona una categoría");
        return;
      }

      await FirebaseFirestore.instance.collection('menu').add({
        'nombre': nombre,
        'categoria': categoria,
        'porcion': porcion,
        'precio': precio,
        'disponibilidad': disponibilidad,
      });

      // Limpiar campos si todo fue bien
      _nombre.clear();
      _precio.clear();
      _porcion.clear();

      mostrarSnackBar("Platillo agregado correctamente ✅");
      obtenerMenu();
    } catch (e) {
      mostrarSnackBar("Error al guardar: $e");
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
      appBar: AppBar(title: const Text('Lista de Productos')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ExpansionTile(
              title: Text('Agregar nuevo platillo'),
              childrenPadding: const EdgeInsets.all(16),
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Nombre"),
                  controller: _nombre,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Porción"),
                  controller: _porcion,
                  // keyboardType: TextInputType.phone,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Precio"),
                  controller: _precio,
                  // keyboardType: TextInputType.phone,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      DropdownMenu(
                        width: 200,
                        dropdownMenuEntries: [
                          DropdownMenuEntry(
                            value: 'Pollo a la brasa',
                            label: 'Pollo a la brasa',
                          ),
                          DropdownMenuEntry(
                            value: 'Parrillas',
                            label: 'Parrillas',
                          ),
                          DropdownMenuEntry(
                            value: 'Guarniciones',
                            label: 'Guarniciones',
                          ),
                          DropdownMenuEntry(value: 'Postres', label: 'Postres'),
                        ],
                        initialSelection: _categoria,
                        onSelected: (String? value) {
                          setState(() {
                            _categoria = value;
                          });
                        },
                        label: Text("Categoria"),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _disponibilidad,
                      onChanged: (value) {
                        setState(() {
                          _disponibilidad = value ?? true;
                        });
                      },
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _disponibilidad =
                              !_disponibilidad; // Toggle the checkbox value
                        });
                      },
                      child: Text(
                        '${_disponibilidad ? "Disponible" : "No Disponible"}',
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: crearMenu,
                  child: Text("Agregar Platillo"),
                ),
              ],
            ),
            Expanded(
              child: platillos.isEmpty
                  ? Center(child: noProd) // Cargando...
                  : ListView.builder(
                      padding: EdgeInsets.only(top: 20),
                      itemCount: platillos.length,
                      itemBuilder: (context, index) {
                        final platillo = platillos[index];
                        return ListTile(
                          leading: Icon(Icons.fastfood),
                          title: Text(platillo['nombre'] ?? 'Sin nombre'),
                          subtitle: Text(
                            'Categoria: ${platillo['categoria'] ?? 'N/A'}\n'
                            'Porcion: ${platillo['porcion'] ?? 'N/A'}\n'
                            'Precio: S/ ${platillo['precio'] ?? '0.00'}\n'
                            'Disponible: ${platillo['disponibilidad'] ? 'Sí' : 'No'}',
                          ),
                          trailing: Text(
                            'ID: ${platillo['id'].toString().substring(0, 5)}...',
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
