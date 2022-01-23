import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:lysts/components/components.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _pressed = false;
  bool _error = false;
  @override
  Widget build(BuildContext context) {
    if (_error) {
      Future.delayed(const Duration(milliseconds: 3000)).then((value) {
        setState(() {
          _pressed = false;
          _error = false;
        });
      });
    }
    return IgnorePointer(
      ignoring: false,
      // ignoring: _pressed || _error,
      child: Material(
          child: Center(
              child: AnimatedCrossFade(
        crossFadeState:
            _error ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 200),
        secondChild: const Text("error"),
        firstChild: AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState:
              _pressed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          secondChild: PlatformCircularProgressIndicator(),
          firstChild:
              Consumer<UserModel>(builder: (context, currentUser, child) {
            return ElevatedButton(
              onPressed: () async {
                setState(() {
                  _pressed = true;
                });
                await currentUser
                    .register({"name": "therealgenish"}).then((e) async {
                  if (e is AppFailLogs) {
                    setState(() {
                      _error = true;
                    });
                  }
                });
              },
              child: const Text(
                "register",
                style: TextStyle(fontSize: 24),
              ),
            );
          }),
        ),
      ))),
    );
  }
}
