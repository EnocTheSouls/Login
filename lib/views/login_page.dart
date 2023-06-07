// ignore_for_file: use_build_context_synchronously

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iqswitch/utils.dart';
import '../pages/forgot_password_page.dart';
// ignore: unused_import
import '../main.dart';

class LoginWidget extends StatefulWidget {
  final VoidCallback onClickedSignUp;
  const LoginWidget({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icono2.png',
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: emailController,
              cursorColor: const Color.fromARGB(255, 0, 0, 0),
              textInputAction: TextInputAction.next,
              decoration:
                  const InputDecoration(labelText: 'Correo Electrónico'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (email) =>
                  email != null && !EmailValidator.validate(email)
                      ? 'Ingresa un correo válido'
                      : null,
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: passwordController,
              textInputAction: TextInputAction.done,
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
              icon: const Icon(Icons.lock_open, size: 32),
              label: const Text(
                'Iniciar Sesión',
                style: TextStyle(fontSize: 24),
              ),
              onPressed: signIn,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                  fontSize: 20,
                ),
              ),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ForgotPasswordPage(),
              )),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 20,
                ),
                text: '¿No te has registrado?',
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = widget.onClickedSignUp,
                    text: '  Registrarse',
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Future signIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
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
