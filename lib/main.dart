import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lysts/pages/pages.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  // // sample information
  // Box sampleUserBox = await Hive.openBox("ls-therealgenish");
  // Map sampleUser = userJsonModel("therealgenish");
  // await sampleUserBox
  //     .putAll({"name": sampleUser["name"], "myLysts": sampleUser["myLysts"]});
  // await sampleUserBox.close();
  // await Hive.deleteBoxFromDisk("ls-therealgenish");
  runApp(Lysts());
}

class Lysts extends StatelessWidget {
  Lysts({Key? key}) : super(key: key);

  final ThemeData orangeTheme = ThemeData(
      primaryColor: Colors.orange,
      checkboxTheme: CheckboxThemeData(fillColor: MaterialStateProperty.all(Colors.orange)));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: orangeTheme,
      initialRoute: "/",
      routes: {
        "/": (context) => const Auth(),
        "/newList": (context) => const NewListPage(),
      },
    );
  }
}

class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return Home(snapshot.data!);
          }
          return const LoginPage();
        });
  }
}
