import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const EmployeesScreen());
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

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  List<Map<String, dynamic>> empleados = [];
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _dni = TextEditingController();
  final TextEditingController _cargo = TextEditingController();

  String? _area = 'Cocina';
  DateTime? _fechaIngreso = DateTime.now();
  bool _estado = false;

  var noEmpl;

  @override
  void initState() {
    super.initState();
    noEmpl = CircularProgressIndicator();
    obtenerMenu();
  }

  Future<void> obtenerMenu() async {
    try {
      // Accede a la colección 'productos' y obtiene todos los documentos
      final snapshot = await FirebaseFirestore.instance
          .collection('empleados')
          .get();
      // Transforma los documentos en una lista de mapas
      setState(() {
        empleados = snapshot.docs
            .map(
              (doc) => {
                'id': doc.id, // Guarda el ID del documento
                ...doc.data(), // Agrega el contenido del documento
              },
            )
            .toList();

        noEmpl = empleados.isEmpty ? Text("No existen empleados") : null;
      });
    } catch (e) {
      print('Error al obtener empleados: $e');
    }
  }

  Future<void> crearMenu() async {
    try {
      final nombre = _nombre.text.trim();
      final dni = _dni.text.trim();
      final area = _area.toString().trim();
      final cargo = _cargo.text.trim();
      final estado = _estado;
      final fechaIngreso = _fechaIngreso;

      if (nombre.isEmpty) {
        mostrarSnackBar("El nombre no puede estar vacío");
        return;
      }

      if (dni.isEmpty) {
        mostrarSnackBar("La porción no puede estar vacía");
        return;
      }

      if (dni.length != 8 || int.tryParse(dni) == null) {
        mostrarSnackBar("El DNI debe tener 8 dígitos");
        return;
      }

      if (area.isEmpty) {
        mostrarSnackBar("El área no puede estar vacía");
        return;
      }

      if (cargo.isEmpty) {
        mostrarSnackBar("Selecciona un cargo");
        return;
      }

      if (fechaIngreso == null) {
        mostrarSnackBar("Selecciona una fecha de ingreso");
        return;
      }
      // Accede a la colección 'productos' y obtiene todos los documentos
      await FirebaseFirestore.instance.collection('empleados').add({
        'nombre': nombre,
        'dni': dni,
        'area': area,
        'cargo': cargo,
        'ingreso': fechaIngreso,
        'estado': estado,
      });
      // Transforma los documentos en una lista de mapas
      _nombre.clear();
      _dni.clear();
      _cargo.clear();

      obtenerMenu();
    } catch (e) {
      print('Error al obtener productos: $e');
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
      appBar: AppBar(title: const Text('Lista de Empleados')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 16,
          children: [
            ExpansionTile(
              title: Text('Agregar nuevo empleado'),
              childrenPadding: const EdgeInsets.all(16),
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Nombre Completo"),
                  controller: _nombre,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "DNI"),
                  controller: _dni,
                  // keyboardType: TextInputType.phone,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      DropdownMenu(
                        width: 200,
                        dropdownMenuEntries: [
                          DropdownMenuEntry(value: 'Cocina', label: 'Cocina'),
                          DropdownMenuEntry(
                            value: 'Atención',
                            label: 'Atención',
                          ),
                          DropdownMenuEntry(
                            value: 'Delivery',
                            label: 'Delivery',
                          ),
                          DropdownMenuEntry(
                            value: 'Administración',
                            label: 'Administración',
                          ),
                        ],
                        initialSelection: _area,
                        onSelected: (String? value) {
                          setState(() {
                            _area = value;
                          });
                        },
                        label: Text("Área"),
                      ),
                    ],
                  ),
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Cargo"),
                  controller: _cargo,
                  // keyboardType: TextInputType.phone,
                ),
                Column(
                  spacing: 8,
                  children: [
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "Fecha de Ingreso: ${_fechaIngreso != null ? DateFormat('dd/MM/yyyy').format(_fechaIngreso!) : 'N/A'}",
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _fechaIngreso ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != _fechaIngreso) {
                              setState(() {
                                _fechaIngreso = picked;
                              });
                            }
                          },
                          child: Text('Seleccionar Ingreso'),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _estado,
                      onChanged: (value) {
                        setState(() {
                          _estado = value ?? true;
                        });
                      },
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _estado = !_estado; // Toggle the checkbox value
                        });
                      },
                      child: Text('${_estado ? "Activo" : "Inactivo"}'),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: crearMenu,
                  child: Text("Agregar Empleado"),
                ),
              ],
            ),
            Expanded(
              child: empleados.isEmpty
                  ? Center(child: noEmpl) // Cargando...
                  : ListView.builder(
                      padding: EdgeInsets.only(top: 20),
                      itemCount: empleados.length,
                      itemBuilder: (context, index) {
                        final empleado = empleados[index];
                        return ListTile(
                          leading: Icon(Icons.person),
                          title: Text(empleado['nombre'] ?? 'Sin nombre'),
                          subtitle: Text(
                            'DNI: ${empleado['dni'] ?? 'N/A'}\n'
                            'Área: ${empleado['area'] ?? 'N/A'}\n'
                            'Cargo: ${empleado['cargo'] ?? 'N/A'}\n'
                            'Fecha de Ingreso: ${(empleado['ingreso'] as Timestamp).toDate().day}/${(empleado['ingreso'] as Timestamp).toDate().month}/${(empleado['ingreso'] as Timestamp).toDate().year}\n'
                            'Estado: ${empleado['estado'] ? 'Activo' : 'Inactivo'}',
                          ),
                          trailing: Text(
                            'ID: ${empleado['id'].toString().substring(0, 5)}...',
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
