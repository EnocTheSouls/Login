import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iqswitch/utils.dart';

import '../main.dart';

class SignUpWidget extends StatefulWidget {
  final Function() onClickedSignIn;

  const SignUpWidget({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.only(top: 80),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Crea una cuenta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 29,
                      color: Colors.blue), // Cambio de color del texto
                ),
                const SizedBox(height: 20), // Espacio adicional
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20), // Espaciado entre imagen y texto
                  child: Transform.rotate(
                    angle: 90 * 0.0174533, // 90 grados en radianes
                    child: Image.asset(
                      'assets/icono3.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),

                TextFormField(
                  controller: emailController,
                  cursorColor: Colors.white,
                  textInputAction: TextInputAction.next,
                  decoration:
                      const InputDecoration(labelText: 'Correo electrónico'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (email) =>
                      email != null && !EmailValidator.validate(email)
                          ? 'Ingresa un correo válido'
                          : null,
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: passwordController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value != null && value.length < 6
                      ? 'Ingresa al menos 6 caracteres'
                      : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  icon: const Icon(Icons.lock_open,
                      size: 32,
                      color: Colors.white), // Cambio de color del ícono
                  label: const Text(
                    'Regístrate',
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.white), // Cambio de color del texto
                  ),
                  onPressed: signUp,
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 20),
                    text: '¿Ya tienes cuenta? ',
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = widget.onClickedSignIn,
                        text: 'Entra aquí',
                        style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue), // Cambio de color del texto
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Future signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print(e);
      Utils.showSnackBar(e.message);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
