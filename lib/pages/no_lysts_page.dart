import 'package:flutter/material.dart';
import 'package:lysts/components/components.dart';

class NoLystsPage extends StatefulWidget {
  const NoLystsPage({Key? key}) : super(key: key);

  @override
  _NoLystsPageState createState() => _NoLystsPageState();
}

class _NoLystsPageState extends State<NoLystsPage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Padding(
              padding: EdgeInsets.only(bottom: 30.0),
              child: Head(radius: 50),
            ),
            Text("No lysts yet... more lysts = more fun!"),
          ],
        ),
      ),
    );
  }
}
