import 'package:flutter/material.dart';
import 'package:iqswitch/views/login_page.dart';

import '../views/signup_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  @override
  Widget build(BuildContext context) => isLogin
      ? LoginWidget(onClickedSignUp: toogle)
      : SignUpWidget(onClickedSignIn: toogle);

  void toogle() => setState(() => isLogin = !isLogin);
}
