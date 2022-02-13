import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

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
        return const AndroidSearchPage();
    }
  }
}

class AndroidSearchPage extends StatelessWidget {
  const AndroidSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FloatingSearchBar(
        leadingActions: [
          BackButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          )
        ],
        closeOnBackdropTap: false,
        automaticallyImplyBackButton: false,
        transition: ExpandingFloatingSearchBarTransition(),
        builder: (context, trans) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Column(
              children: List.generate(
                  10,
                  (index) => Column(
                        children: [
                          Container(
                            color: Colors.white,
                            child: ListTile(
                              title: Text(index.toString()),
                            ),
                          ),
                        ],
                      )),
            ),
          ),
        ),
      ),
    );
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
