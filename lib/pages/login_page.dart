import 'package:flutter/material.dart';
import 'package:lysts/components/components.dart';
import 'package:provider/provider.dart';
import 'package:social_login_buttons/social_login_buttons.dart';

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
      child: SizedBox(
        width: 300,
        child: Consumer<AuthService>(builder: (context, authService, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SocialLoginButton(
                buttonType: SocialLoginButtonType.google,
                onPressed: () async => await authService.handleGoogleSignIn(),
              )
            ],
          );
        }),
      ),
    ));
  }
}
