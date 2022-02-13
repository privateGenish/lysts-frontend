import 'package:flutter/material.dart';
import 'package:lysts/components/components.dart';
import 'package:provider/provider.dart';

class AvatarMenuContent extends StatefulWidget {
  final ScrollController controller;
  const AvatarMenuContent({Key? key, required this.controller}) : super(key: key);

  @override
  State<AvatarMenuContent> createState() => _AvatarMenuContentState();
}

class _AvatarMenuContentState extends State<AvatarMenuContent> {
  bool _isFavoriteOpen = false;

  @override
  Widget build(BuildContext context) {
    UserModel userModel = Provider.of<UserModel>(context, listen: false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Head(
            radius: 50,
          ),
          title: Text("Hey There ${userModel.name}!"),
          subtitle: const Text("it's always nice to have a productive day!"),
          isThreeLine: true,
        ),
        ListTile(
          selected: _isFavoriteOpen,
          onTap: () => setState(() {
            if (widget.controller.position.viewportDimension >= 400) {
              _isFavoriteOpen = !_isFavoriteOpen;
              widget.controller.animateTo(100, duration: const Duration(milliseconds: 120), curve: Curves.easeIn);
            }
          }),
          title: const Text("My favourite lists"),
          leading: const Icon(Icons.favorite),
        ),
        AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isFavoriteOpen ? null : 0,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: const [
                  ListTile(
                    title: Text("friends list"),
                    subtitle: Text("mbtrg"),
                  ),
                  ListTile(
                    title: Text("friends list"),
                    subtitle: Text("mbtrg"),
                  ),
                  ListTile(
                    title: Text("friends list"),
                    subtitle: Text("mbtrg"),
                  ),
                  ListTile(
                    title: Text("friends list"),
                    subtitle: Text("mbtrg"),
                  ),
                  ListTile(
                    title: Text("friends list"),
                    subtitle: Text("mbtrg"),
                  )
                ],
              ),
            )),
        const ListTile(
          title: Text("Settings"),
          leading: Icon(Icons.settings),
        ),
        ListTile(
          onTap: () async {},
          title: const Text("Log out"),
          leading: const Icon(Icons.logout),
        )
      ],
    );
  }
}
