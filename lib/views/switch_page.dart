import 'dart:async';

import 'package:flutter/material.dart';
// ignore: unused_import
import 'dispositivos_screen.dart';

void main() => runApp(const SwitchApp());

class SwitchApp extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const SwitchApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ).copyWith(
          secondary: const Color.fromARGB(255, 20, 14, 212),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor:
              Color.fromRGBO(33, 150, 243, 1), // Color de fondo de la AppBar
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w400,
            // Color del texto del título
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('IQ-Switch'),
        ),
        body: const Center(
          child: estadoDispositivo(),
        ),
      ),
    );
  }
}

// ignore: camel_case_types
class estadoDispositivo extends StatefulWidget {
  const estadoDispositivo({super.key});
  @override
  State<estadoDispositivo> createState() => _estadoDispositivoState();
}

// ignore: camel_case_types
class _estadoDispositivoState extends State<estadoDispositivo> {
  late Duration tiempoSeleccionado;
  bool encendido = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String imagePath =
        encendido ? 'assets/encendidoo.png' : 'assets/apagadoo.png';

    return Scaffold(
      backgroundColor: encendido ? Colors.white : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                imagePath, // Ruta de la imagen en la carpeta assets
                width: 400, // Ajusta el ancho de la imagen
                height: 400, // Ajusta la altura de la imagen
              ),
            ),
            const SizedBox(height: 60), // Espacio vertical adicional
            Transform.scale(
              scale: 2.0, // Ajusta la escala del interruptor
              child: Switch(
                value: encendido,
                activeColor: Colors.green,
                onChanged: (bool value) {
                  _timer
                      ?.cancel(); // Cancelar el temporizador existente si hay alguno
                  _timer = Timer(tiempoSeleccionado, () {
                    setState(() {
                      encendido =
                          false; // Apagar el foco al finalizar el tiempo
                    });
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
