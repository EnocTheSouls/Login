// ignore: unused_import
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
  int sliderValue = 0;

  @override
  void initState() {
    super.initState();
  }

  final List<String> sliderImages = [
    'assets/foco2.png',
    'assets/foco3.png',
    'assets/foco4.png',
    'assets/foco5.png',
    'assets/foco6.png',
  ];
  final double imageSize = 500.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Cambiar el color de fondo a blanco
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            encendido
                ? SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Image.asset(
                            sliderImages[sliderValue],
                            width: imageSize,
                            height: imageSize,
                          ),
                        ),
                        Slider(
                          value: sliderValue.toDouble(),
                          min: 0,
                          max: sliderImages.length - 1,
                          onChanged: (double value) {
                            setState(() {
                              sliderValue = value.toInt();
                            });
                          },
                          divisions: sliderImages.length - 1,
                          label: sliderValue.toString(),
                        ),
                      ],
                    ),
                  )
                : Image.asset(
                    'assets/apagadoo.png',
                    width: imageSize,
                    height: imageSize,
                  ),
            const SizedBox(height: 60),
            // ignore: sized_box_for_whitespace
            Container(
              width: 200.0,
              child: Switch(
                value: encendido,
                activeColor: Colors.green,
                onChanged: (bool value) {
                  setState(() {
                    encendido = value;
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
