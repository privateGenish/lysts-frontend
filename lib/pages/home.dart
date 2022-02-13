import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lysts/components/components.dart';
import 'package:lysts/pages/pages.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final User user;
  const Home(this.user, {Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserModel?>(
      lazy: false,
      create: (context) => UserModel(uid: widget.user.uid),
      child: const HomePage(),
      builder: (context, child) {
        UserModel currentUser = Provider.of<UserModel>(context);
        if (currentUser.registerd != null) {
          if (!currentUser.registerd!) {
            return const RegisterPage();
          }
          return child!;
        }
        return const WaitingSplashScreen();
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: const [
          SmallView(),
          MediumView(),
          LargeView(),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: const [
          //* add button
          AddButton(),
          Padding(padding: EdgeInsets.all(8)),
          //* avatar menu
          AvatarMenuButton(),
        ],
      ),
    );
  }
}

class WaitingSplashScreen extends StatelessWidget {
  const WaitingSplashScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Head(radius: 50),
          SizedBox(
            height: 100,
          ),
          CircularProgressIndicator()
        ],
      ),
    );
  }
}

class AvatarMenuButton extends StatelessWidget {
  const AvatarMenuButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Consumer<UserModel>(builder: (context, userModel, child) {
        return Card(
          shape: const CircleBorder(),
          elevation: 8.0,
          child: InkWell(
              // heroTag: "menu_button",
              child: const AvatarHead(radius: 35),
              onTap: () => showModalBottomSheet(
                  useRootNavigator: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) => MultiProvider(
                      providers: [ChangeNotifierProvider<UserModel>.value(value: userModel)],
                      builder: (context, _) => const AvatarModalSheet()))),
        );
      }),
    );
  }
}

class AddButton extends StatelessWidget {
  const AddButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Consumer<UserModel>(builder: (context, currentUser, child) {
        return FloatingActionButton.extended(
            heroTag: "new_list_button",
            backgroundColor: Colors.redAccent,
            isExtended: false,
            icon: const Icon(
              Icons.add,
            ),
            onPressed: () => showModalBottomSheet(
                context: context,
                builder: (context) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider<UserModel>.value(
                            value: currentUser,
                          ),
                        ],
                        builder: (context, child) {
                          return const AddListMenu();
                        })),
            label: const Text(
              "New List",
              style: TextStyle(fontSize: 16),
            ));
      }),
    );
  }
}

class AvatarModalSheet extends StatelessWidget {
  const AvatarModalSheet({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        minChildSize: 0.0,
        initialChildSize: 0.4,
        snap: true,
        expand: false,
        builder: (context, controller) {
          return LayoutBuilder(builder: (context, cnst) {
            if (cnst.maxHeight <= 0.1) {
              Navigator.maybeOf(context)?.maybePop();
            }
            return CustomScrollView(
              controller: controller,
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: cnst.maxHeight > 300 ? 160 : 130),
                      child: AnimatedContainer(
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(cnst.maxHeight > 300 ? 0.0 : 15.0)),
                        duration: const Duration(milliseconds: 100),
                        height: 5,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: cnst.maxHeight > 300 ? const Radius.circular(0) : const Radius.circular(15.0),
                        topRight: cnst.maxHeight > 300 ? const Radius.circular(0) : const Radius.circular(15.0)),
                    child: Container(
                      color: Colors.white,
                      child: AvatarMenuContent(
                        controller: controller,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 40.0),
                    color: Colors.white,
                    child: Center(
                      child: Text(
                        "created by mbtrg",
                        style: Theme.of(context).textTheme.overline,
                      ),
                    ),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    color: Colors.white,
                  ),
                ),
              ],
            );
          });
        });
  }
}
