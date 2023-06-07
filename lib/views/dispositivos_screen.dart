// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import '../controllers/dispositivos.dart';
import 'habitaciones_screen.dart';
import 'switch_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DispositivosScreen extends StatefulWidget {
  final Habitacion habitacion;
  final Function(Duration) onTiempoSeleccionado;

  const DispositivosScreen(
      {Key? key, required this.habitacion, required this.onTiempoSeleccionado})
      : super(key: key);

  @override
  _DispositivosScreenState createState() => _DispositivosScreenState();
}

class _DispositivosScreenState extends State<DispositivosScreen> {
  CollectionReference dispositivosCollection =
      FirebaseFirestore.instance.collection('dispositivos');
  List<Dispositivo> dispositivos = [];
  final TextEditingController _nombreDispositivoController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarDispositivos();
  }

  void cargarDispositivos() async {
    QuerySnapshot dispositivosSnapshot = await dispositivosCollection.get();

    setState(() {
      dispositivos = dispositivosSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Dispositivo(nombre: data['nombre']);
      }).toList();
    });
  }

  bool dispositivoExistente(String nombreDispositivo) {
    for (var dispositivo in dispositivos) {
      if (dispositivo.nombre.toLowerCase() == nombreDispositivo.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  void eliminarDispositivo(Dispositivo dispositivo) async {
    String dispositivoId = '';
    QuerySnapshot dispositivosSnapshot = await dispositivosCollection.get();
    for (var doc in dispositivosSnapshot.docs) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data?['nombre'] == dispositivo.nombre) {
        dispositivoId = doc.id;
      }
    }
    if (dispositivoId.isNotEmpty) {
      await dispositivosCollection.doc(dispositivoId).delete();
      setState(() {
        dispositivos.remove(dispositivo);
      });
    }
  }

  void modificarDispositivo(Dispositivo dispositivo, String nuevoNombre) async {
    await dispositivosCollection
        .doc(dispositivo.nombre)
        .update({'nombre': nuevoNombre});
    cargarDispositivos();
  }

  void mostrarDialogoModificarDispositivo(Dispositivo dispositivo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String nuevoNombre = dispositivo.nombre;
        return AlertDialog(
          title: const Text('Modificar Dispositivo'),
          content: TextField(
            controller: TextEditingController(text: dispositivo.nombre),
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
                modificarDispositivo(dispositivo, nuevoNombre);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Variable global para almacenar el tiempo seleccionado
  late Duration tiempoSeleccionado;

  void mostrarDialogoTemporizadorDispositivo(Dispositivo dispositivo) {
    int horas = 0;
    int minutos = 0;
    int segundos = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Temporizador'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              horas = int.tryParse(value) ?? 0;
                              if (horas > 99) {
                                horas = 99;
                              }
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Horas',
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              minutos = int.tryParse(value) ?? 0;
                              if (minutos > 59) {
                                minutos = 59;
                              }
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Minutos',
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              segundos = int.tryParse(value) ?? 0;
                              if (segundos > 59) {
                                segundos = 59;
                              }
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Segundos',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    int totalSegundos = horas * 3600 + minutos * 60 + segundos;
                    tiempoSeleccionado = Duration(seconds: totalSegundos);
                    Navigator.of(context).pop();

                    // Llama a la función de retorno pasando el tiempo seleccionado
                    // ignore: unnecessary_null_comparison
                    if (widget.onTiempoSeleccionado != null) {
                      widget.onTiempoSeleccionado(tiempoSeleccionado);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habitacion.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Nuevo Dispositivo'),
                    content: TextField(
                      controller: _nombreDispositivoController,
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
                          String nombreDispositivo =
                              _nombreDispositivoController.text;
                          if (nombreDispositivo.isNotEmpty &&
                              !dispositivoExistente(nombreDispositivo)) {
                            await dispositivosCollection.add({
                              'nombre': nombreDispositivo,
                            });
                            cargarDispositivos();
                            _nombreDispositivoController.clear();
                            Navigator.of(context).pop();
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content:
                                      const Text('El dispositivo ya existe.'),
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
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Mis dispositivos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: dispositivos.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    child: ListTile(
                      title: Text(dispositivos[index].nombre),
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
                                      '¿Estás seguro de eliminar este dispositivo?'),
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
                                        eliminarDispositivo(
                                            dispositivos[index]);
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
                            onPressed: () => mostrarDialogoModificarDispositivo(
                                dispositivos[index]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.access_alarm),
                            onPressed: () =>
                                mostrarDialogoTemporizadorDispositivo(
                                    dispositivos[index]),
                          ),
                          IconButton(
                            //onPressed: () => mostrarDialogoEstadoDispositivo(
                            //dispositivos[index]),
                            onPressed: () {},
                            icon: CircleAvatar(
                              backgroundColor: dispositivos[index].encendido
                                  ? Colors.green
                                  : Colors.red,
                              radius: 10,
                            ),
                          )
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SwitchApp(), // Reemplaza 'SwitchApp()' con la instancia apropiada de la clase SwitchApp
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
    );
  }
}
