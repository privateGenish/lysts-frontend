import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
      case "android":
        //FIXME: create android view
        return const AndroidSmallView();
      default:
        return const Scaffold();
    }
  }
}

//FIXME: format the widget tree and the methods
//TODO: create platform specific methods instead of class and create class for layout diffs
class CupertinoSmallView extends StatelessWidget {
  CupertinoSmallView({
    Key? key,
  }) : super(key: key);

  final ScrollController _controller = ScrollController(initialScrollOffset: -30);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: CustomScrollView(controller: _controller, slivers: [
      const CupertinoSliverNavigationBar(largeTitle: Text("My Lists")),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SearchPage())),
            child: const AbsorbPointer(child: Hero(tag: "searchHero", child: CupertinoSearchTextField(enabled: true))),
          ),
        ),
      ),
//* pinned List
      Consumer<UserModel>(builder: (context, currentUser, child) {
        List<Lyst> lysts = currentUser.lysts;
        return SliverList(
            delegate: SliverChildListDelegate(
          List.generate(lysts.length, (index) {
            Lyst _currentLyst = lysts[index];
            if (!_currentLyst.pinned) {
              return const SizedBox();
            }
//! FIXME: NeedsAttention dubious method to force an update on the parent model `user model`.
            _currentLyst.addListener(() {
              currentUser.refresh();
            });
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  CupertinoMenuSmallTile(
                    pinnedMenu: true,
                    currentLyst: _currentLyst,
                    currentUser: currentUser,
                  ),
                  const Divider(
                    height: 2,
                    thickness: 0.6,
                  )
                ],
              ),
            );
          }),
        ));
      }),
      const SliverToBoxAdapter(
        child: Divider(
          thickness: 2,
          height: 1,
        ),
      ),
//* unPinnedList
      Consumer<UserModel>(builder: (context, currentUser, child) {
        List<Lyst> lysts = currentUser.lysts;
        return SliverList(
            delegate: SliverChildListDelegate(
          List.generate(lysts.length, (index) {
            Lyst _currentLyst = lysts[index];
            if (_currentLyst.pinned) {
              return const SizedBox();
            }
//!NeedsAttention dubious method to force an update on the parent model `user model`.
            _currentLyst.addListener(() {
              currentUser.refresh();
            });
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  CupertinoMenuSmallTile(currentLyst: _currentLyst, currentUser: currentUser),
                  const Divider(
                    height: 2,
                    thickness: 0.6,
                  )
                ],
              ),
            );
          }),
        ));
      }),
      const SliverPadding(padding: EdgeInsets.only(top: 125)),
    ]));
  }
}

class CupertinoMenuSmallTile extends StatelessWidget {
  const CupertinoMenuSmallTile({
    Key? key,
    required Lyst currentLyst,
    required this.currentUser,
    this.pinnedMenu = false,
  })  : _currentLyst = currentLyst,
        super(key: key);

  final UserModel currentUser;
  final Lyst _currentLyst;
  final bool pinnedMenu;

  @override
  Widget build(BuildContext context) {
    return CupertinoContextMenu(
      actions: [
        CupertinoContextMenuAction(
          onPressed: () async {
            Navigator.maybePop(context);
            await Future.delayed(const Duration(milliseconds: 400));
            _currentLyst.isPinned = !_currentLyst.isPinned;
          },
          isDefaultAction: true,
          child: pinnedMenu ? const Text("Unpin Lyst") : const Text("Pin Lyst"),
          trailingIcon: Icons.push_pin,
        ),
        CupertinoContextMenuAction(
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
            await Future.delayed(const Duration(milliseconds: 400)).then((v) => currentUser.deleteLyst(_currentLyst));
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
              title: Text(
                _currentLyst.title,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
      child: Material(
        child: SmallTile(
          currentLyst: _currentLyst,
          currentUser: currentUser,
          pinned: pinnedMenu,
        ),
      ),
    );
  }
}

class AndroidSmallView extends StatelessWidget {
  const AndroidSmallView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              pinned: true,
              elevation: 3,
              expandedHeight: 90,
              actions: [
                IconButton(
                    onPressed: () =>
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage())),
                    icon: const Hero(child: Icon(Icons.search), tag: "android-search",))
              ],
              flexibleSpace: const FlexibleSpaceBar(
                title: Text("My Lysts"),
              )),
//* pinned List
          Consumer<UserModel>(builder: (context, currentUser, child) {
            List<Lyst> lysts = currentUser.lysts;
            return SliverList(
                delegate: SliverChildListDelegate(
              List.generate(lysts.length, (index) {
                Lyst _currentLyst = lysts[index];
                if (!_currentLyst.pinned) {
                  return const SizedBox();
                }
//! FIXME: NeedsAttention dubious method to force an update on the parent model `user model`.
                _currentLyst.addListener(() {
                  currentUser.refresh();
                });
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      AndroidSmallTile(
                          currentLyst: _currentLyst,
                          currentUser: currentUser,
                          child: SmallTile(
                            currentLyst: _currentLyst,
                            currentUser: currentUser,
                            pinned: true,
                          )),
                      const Divider(
                        height: 2,
                        thickness: 0.6,
                      )
                    ],
                  ),
                );
              }),
            ));
          }),
          const SliverToBoxAdapter(
            child: Divider(
              thickness: 2,
              height: 1,
            ),
          ),
//* unPinnedList
          Consumer<UserModel>(builder: (context, currentUser, child) {
            List<Lyst> lysts = currentUser.lysts;
            return SliverList(
                delegate: SliverChildListDelegate(
              List.generate(lysts.length, (index) {
                Lyst _currentLyst = lysts[index];
                if (_currentLyst.pinned) {
                  return const SizedBox();
                }
//!NeedsAttention dubious method to force an update on the parent model `user model`.
                _currentLyst.addListener(() {
                  currentUser.refresh();
                });
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      AndroidSmallTile(
                          currentLyst: _currentLyst,
                          currentUser: currentUser,
                          child: SmallTile(currentLyst: _currentLyst, currentUser: currentUser)),
                      const Divider(
                        height: 2,
                        thickness: 0.6,
                      )
                    ],
                  ),
                );
              }),
            ));
          }),
          const SliverPadding(padding: EdgeInsets.only(top: 125)),
          const SliverFillRemaining()
        ],
      ),
    );
  }
}

class AndroidSmallTile extends StatelessWidget {
  const AndroidSmallTile({Key? key, required Lyst currentLyst, required this.currentUser, required this.child})
      : _currentLyst = currentLyst,
        super(key: key);
  final Widget child;
  final Lyst _currentLyst;
  final UserModel currentUser;
  @override
  Widget build(BuildContext context) {
    return Slidable(
        key: UniqueKey(),
        closeOnScroll: true,
        startActionPane: ActionPane(children: [
          Flexible(
            child: InkWell(
              child: Container(
                color: Colors.red,
                child: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    currentUser.deleteLyst(_currentLyst);
                  },
                ),
              ),
            ),
          )
        ], motion: const DrawerMotion()),
        endActionPane: ActionPane(
          children: [
            Flexible(
                child: Container(
              color: Colors.grey,
              child: IconButton(
                icon: const Icon(
                  Icons.share,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            )),
            Flexible(
                child: Container(
              color: Colors.blue,
              child: IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                onPressed: () => showModalBottomSheet(
                    context: context,
                    builder: (context) => ChangeNotifierProvider<UserModel>.value(
                        value: currentUser,
                        builder: (context, snapshot) {
                          return AddListMenu(
                            lyst: _currentLyst,
                          );
                        })),
              ),
            )),
            Flexible(
                child: Container(
              color: Colors.yellow,
              child: IconButton(
                  icon: const Icon(
                    Icons.push_pin,
                    color: Colors.black,
                  ),
                  onPressed: () => _currentLyst.isPinned = !_currentLyst.isPinned),
            ))
          ],
          motion: const DrawerMotion(),
        ),
        child: child);
  }
}

class SmallTile extends StatelessWidget {
  const SmallTile({Key? key, required Lyst currentLyst, required this.currentUser, this.pinned = false})
      : _currentLyst = currentLyst,
        super(key: key);
  final bool pinned;
  final Lyst _currentLyst;
  final UserModel currentUser;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      iconColor: Colors.orangeAccent[100],
      leading: SizedBox(
        height: 24,
        width: 24,
        child: CustomIcon(
          assets: currentUser.availableLystTypes[_currentLyst.type]![0],
        ),
      ),
      subtitle: _currentLyst.description != null ? Text(_currentLyst.description!) : null,
      title: Text(
        _currentLyst.title,
        style: pinned ? const TextStyle(fontWeight: FontWeight.bold) : null,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("(${_currentLyst.tasks.length - _currentLyst.doneCounter})"),
        ],
      ),
      onTap: () async {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
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
    );
  }
}
