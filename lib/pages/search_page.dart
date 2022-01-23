import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    switch (Platform.operatingSystem) {
      case "ios":
        return const CupertinoSearchPage();
      default:
        return const Scaffold();
    }
  }
}

class CupertinoSearchPage extends StatelessWidget {
  const CupertinoSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: const CupertinoNavigationBar(
        middle: CupertinoSearchTextField(),
      ),
      child: Material(
        child: Column(
          children: const [Text("first"), Text("second")],
        ),
      ),
    );
  }
}
