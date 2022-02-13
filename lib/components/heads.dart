import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'components.dart';

class AvatarHead extends StatelessWidget {
  final double radius;
  const AvatarHead({Key? key, required this.radius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).cardColor,
        child: Padding(padding: const EdgeInsets.all(8.0), child: Head(radius: radius)));
  }
}

class Head extends StatelessWidget {
  final double radius;
  const Head({Key? key, required this.radius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel? >(builder: (context, currentUser, child) {
      return SvgPicture.asset(
        currentUser?.headUri ?? "assets/default_male_head.svg",
      );
    });
  }
}
