import 'package:flutter/material.dart';
import 'package:lysts/components/components.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text("Login"),
          onPressed: () => Provider.of<AuthService>(context, listen: false)
              .setUid = "therealgenish",
        ),
      ),
    );
  }
}
