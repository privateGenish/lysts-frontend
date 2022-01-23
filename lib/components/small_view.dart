import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lysts/components/components.dart';
import 'package:lysts/pages/pages.dart';
import 'package:provider/provider.dart';

class SmallView extends StatefulWidget {
  const SmallView({
    Key? key,
  }) : super(key: key);

  @override
  _SmallViewState createState() => _SmallViewState();
}

class _SmallViewState extends State<SmallView> {
  @override
  Widget build(BuildContext context) {
    List<Lyst> lysts = Provider.of<UserModel>(context).lysts;
    switch (Platform.operatingSystem) {
      case "ios":
        if (lysts.isEmpty) {
          return const Scaffold(appBar: CupertinoNavigationBar(middle: Text("My lysts")), body: NoLystsPage());
        }
        return CupertinoSmallView();
      default:
        return const Scaffold();
    }
  }
}

class CupertinoSmallView extends StatelessWidget {
  CupertinoSmallView({
    Key? key,
  }) : super(key: key);

  final ScrollController _controller = ScrollController(initialScrollOffset: -30);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: CustomScrollView(
      controller: _controller,
      slivers: [
            const CupertinoSliverNavigationBar(largeTitle: Text("My Lists")),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                child: InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SearchPage())),
                  child: const AbsorbPointer(
                      child: Hero(tag: "searchHero", child: CupertinoSearchTextField(enabled: true))),
                ),
              ),
            ),
            Consumer<UserModel>(builder: (context, currentUser, child) {
              List<Lyst> lysts = currentUser.lysts;
              return SliverList(
                  delegate: SliverChildListDelegate(List.generate(lysts.length, (index) {
                Lyst _currentLyst = lysts[index];
                //!NeedsAttention dobius method to force an upate on the parent model `user model`.
                _currentLyst.addListener(() {
                  currentUser.refresh();
                });
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      CupertinoContextMenu(
                        actions: [
                          CupertinoContextMenuAction(
                            //TODO: Implement pin lyst
                            onPressed: () {},
                            isDefaultAction: true,
                            child: const Text("Pin Lyst"),
                            trailingIcon: Icons.push_pin,
                          ),
                          CupertinoContextMenuAction(
                            //TODO: Implement pin lyst
                            onPressed: () => showModalBottomSheet(
                                context: context,
                                builder: (context) => ChangeNotifierProvider<UserModel>.value(
                                    value: currentUser,
                                    builder: (context, snapshot) {
                                      return AddListMenu(
                                        lyst: _currentLyst,
                                      );
                                    })),
                            child: const Text("Edit Lyst"),
                            trailingIcon: Icons.edit,
                          ),
                          CupertinoContextMenuAction(
                            //TODO: Implement share lysts
                            onPressed: () {},
                            trailingIcon: Icons.share,
                            child: const Text("Share Lyst"),
                          ),
                          CupertinoContextMenuAction(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await Future.delayed(const Duration(milliseconds: 400))
                                  .then((v) => currentUser.deleteLyst(_currentLyst));
                            },
                            trailingIcon: Icons.delete,
                            isDestructiveAction: true,
                            child: const Text("delete"),
                          ),
                        ],
                        previewBuilder: (context, animation, child) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Material(
                              child: ListTile(
                                title: Text(_currentLyst.title),
                              ),
                            ),
                          );
                        },
                        child: Material(
                          child: ListTile(
                            iconColor: Colors.orangeAccent,
                            leading: CustomIcon(
                              assest: currentUser.avaialableLystTypes[_currentLyst.type]![0],
                            ),
                            subtitle: _currentLyst.description != null ? Text(_currentLyst.description!) : null,
                            title: Text(_currentLyst.title),
                            trailing: Text("(${_currentLyst.tasks.length - _currentLyst.doneCounter})"),
                            onTap: () async {
                              Navigator.of(context).push(CupertinoPageRoute(
                                  title: "list $index",
                                  builder: (context) {
                                    return MultiProvider(
                                        providers: [
                                          ChangeNotifierProvider<UserModel>.value(value: currentUser),
                                          ChangeNotifierProvider<Lyst>.value(value: _currentLyst),
                                        ],
                                        builder: (context, snapshot) {
                                          return const ListPage();
                                        });
                                  }));
                            },
                          ),
                        ),
                      ),
                      const Divider(
                        height: 2,
                        thickness: 0.6,
                      )
                    ],
                  ),
                );
              })));
            })
          ] +
          const [SliverPadding(padding: EdgeInsets.only(top: 125))],
    ));
  }
}
