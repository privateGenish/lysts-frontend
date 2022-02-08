
import 'package:flutter/material.dart';
import 'package:lysts/components/components.dart';

class ListPage extends StatefulWidget {
  const ListPage({
    Key? key,
  }) : super(key: key);

  static const String routeName = "/listPage";

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  @override
  Widget build(BuildContext context) {
    return const Material(child:  PlatformBuildLyst());
  }
}
