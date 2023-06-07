// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, use_build_context_synchronously, non_constant_identifier_names
import '../controllers/dispositivos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dispositivos_screen.dart';

class HabitacionesScreen extends StatefulWidget {
  const HabitacionesScreen({Key? key}) : super(key: key);
  @override
  _HabitacionesScreenState createState() => _HabitacionesScreenState();
}

class Habitacion {
  String nombre;
  List<Dispositivo> dispositivos;
  Habitacion({required this.nombre, List<Dispositivo>? dispositivos})
      // ignore: unnecessary_this
      : this.dispositivos = dispositivos ?? [];
}

class _HabitacionesScreenState extends State<HabitacionesScreen> {
  CollectionReference habitacionesCollection =
      FirebaseFirestore.instance.collection('habitaciones');
  List<Habitacion> habitaciones = [];
  TextEditingController _nombreHabitacionController = TextEditingController();
  bool isAdmin = false;
  @override
  void initState() {
    super.initState();
    cargarHabitaciones();
    verificarAdmin();
  }

  void verificarAdmin() async {
    // Obtener información del usuario actual
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Comprobar si el usuario es administrador en tu lógica específica
      // Aquí se muestra un ejemplo simple donde se considera administrador si el email contiene la palabra 'admin'
      setState(() {
        isAdmin = user.email!.contains('admin');
      });
    }
  }

  void cargarHabitaciones() async {
    QuerySnapshot habitacionesSnapshot = await habitacionesCollection.get();
    setState(() {
      habitaciones = habitacionesSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Habitacion(nombre: data['nombre']);
      }).toList();
    });
  }

  bool habitacionExistente(String nombreHabitacion) {
    for (var habitacion in habitaciones) {
      if (habitacion.nombre.toLowerCase() == nombreHabitacion.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  void eliminarHabitacion(Habitacion habitacion) async {
    String habitacionId = '';
    QuerySnapshot habitacionesSnapshot = await habitacionesCollection.get();
    for (var doc in habitacionesSnapshot.docs) {
      if (doc.data() is Map &&
          (doc.data() as Map).containsKey('nombre') &&
          (doc.data() as Map)['nombre'] == habitacion.nombre) {
        habitacionId = doc.id;
      }
    }
    if (habitacionId.isNotEmpty) {
      await habitacionesCollection.doc(habitacionId).delete();
      setState(() {
        habitaciones.remove(habitacion);
      });
    }
  }

  void modificarHabitacion(Habitacion habitacion, String nuevoNombre) async {
    String habitacionId = '';
    QuerySnapshot habitacionesSnapshot = await habitacionesCollection.get();
    for (var doc in habitacionesSnapshot.docs) {
      if (doc.data() is Map &&
          (doc.data() as Map).containsKey('nombre') &&
          (doc.data() as Map)['nombre'] == habitacion.nombre) {
        habitacionId = doc.id;
        break;
      }
    }
    if (habitacionId.isNotEmpty) {
      await habitacionesCollection
          .doc(habitacionId)
          .update({'nombre': nuevoNombre});
      setState(() {
        habitacion.nombre = nuevoNombre;
      });
    }
  }

  void mostrarDialogoModificarHabitacion(Habitacion habitacion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String nuevoNombre = habitacion.nombre;
        return AlertDialog(
          title: const Text('Modificar Habitación'),
          content: TextField(
            controller: TextEditingController(text: habitacion.nombre),
            onChanged: (value) {
              nuevoNombre = value;
            },
            decoration: const InputDecoration(
              labelText: 'Ingresar nuevo nombre',
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Modificar'),
              onPressed: () {
                modificarHabitacion(habitacion, nuevoNombre);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back, size: 32),
              label: const Text(
                'Sign Out',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () => FirebaseAuth.instance.signOut(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Mis habitaciones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: habitaciones.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    child: ListTile(
                      title: Text(habitaciones[index].nombre),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirmar eliminación'),
                                  content: const Text(
                                      '¿Estás seguro de eliminar esta habitación?'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Cancelar'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Eliminar'),
                                      onPressed: () {
                                        eliminarHabitacion(habitaciones[index]);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => mostrarDialogoModificarHabitacion(
                                habitaciones[index]),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DispositivosScreen(
                              // ignore: avoid_types_as_parameter_names
                              habitacion: habitaciones[index],
                              // ignore: avoid_types_as_parameter_names
                              onTiempoSeleccionado: (Duration) {},
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            'Agregar habitaciones',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Nueva Habitación'),
                    content: TextField(
                      controller: _nombreHabitacionController,
                      decoration: const InputDecoration(
                        labelText: 'Ingresar nombre',
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Agregar'),
                        onPressed: () async {
                          String nombreHabitacion =
                              _nombreHabitacionController.text;
                          if (nombreHabitacion.isNotEmpty &&
                              !habitacionExistente(nombreHabitacion)) {
                            await habitacionesCollection.add({
                              'nombre': nombreHabitacion,
                            });
                            cargarHabitaciones();
                            _nombreHabitacionController.clear();
                            Navigator.of(context).pop();
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content:
                                      const Text('La habitación ya existe.'),
                                  actions: [
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
