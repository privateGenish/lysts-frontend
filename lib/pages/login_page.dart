import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lysts/components/components.dart';
import 'package:provider/provider.dart';
import 'package:social_login_buttons/social_login_buttons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser;
    try {
      googleUser = await GoogleSignIn().signIn();
    } catch (e) {
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(const SnackBar(content: Text("Hey there, you didn't logged in!")));
      return null;
    }
    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    print(FirebaseAuth.instance.currentUser);
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AvatarHead(
            radius: 100,
          ),
          const SizedBox(
            height: 50,
          ),
          SizedBox(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SocialLoginButton(buttonType: SocialLoginButtonType.google, onPressed: () => signInWithGoogle()),
                const SizedBox(
                  height: 20,
                ),
                SocialLoginButton(buttonType: SocialLoginButtonType.appleBlack, onPressed: () {}),
                const SizedBox(
                  height: 20,
                ),
                TextButton(onPressed: () async => signOut(), child: const Text("logout"))
              ],
            ),
          ),
        ]
      ),
    ));
  }
}
