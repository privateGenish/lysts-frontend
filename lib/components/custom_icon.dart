import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomIcon extends StatelessWidget {
  final dynamic assest;
  const CustomIcon({this.assest, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (assest is String) {
      return SvgPicture.asset(
        assest,
        width: 24,
        height: 24,
      );
    }
    if (assest is FontAwesomeIcons) {
      return FaIcon(assest);
    }
    if (assest is IconData) {
      return Icon(assest);
    }
    return const Icon(Icons.tab);
  }
}
