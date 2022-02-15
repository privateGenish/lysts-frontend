import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomIcon extends StatelessWidget {
  final dynamic assets;
  const CustomIcon({this.assets, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (assets is String) {
      return SvgPicture.asset(
        assets,
        width: 24,
        height: 24,
      );
    }
    if (assets is FontAwesomeIcons) {
      return FaIcon(assets);
    }
    if (assets is IconData) {
      return Icon(assets);
    }
    return const Icon(Icons.tab);
  }
}
