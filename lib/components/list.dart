import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lysts/components/components.dart';
import 'package:provider/provider.dart';

class PlatformBuildLyst extends StatefulWidget {
  const PlatformBuildLyst({
    Key? key,
  }) : super(key: key);
  @override
  State<PlatformBuildLyst> createState() => _PlatformBuildLystState();
}

class _PlatformBuildLystState extends State<PlatformBuildLyst> with WidgetsBindingObserver {
  ///
  ///? this values are nullable because they needed to be inialized and then valued
  //? dutring the runtime because they are used at the dispose/paused stage
  UserModel? currentUser;
  Lyst? lyst;

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        if (lyst != null && currentUser != null) {
          currentUser!.syncLystWithResources();
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    if (lyst != null && currentUser != null) {
      currentUser!.syncLystWithResources();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    lyst = Provider.of<Lyst>(context);
    currentUser = Provider.of<UserModel>(context);
    return CupertinoPageScaffold(child: CustomScrollView(slivers: [_platformHeader(lyst!), const TaskTilesView()]));
  }

  dynamic _platformHeader(Lyst currentLyst) {
    switch (Platform.operatingSystem) {
      case 'ios':
        return CupertinoSliverNavigationBar(
            heroTag: currentLyst.lystId,
            previousPageTitle: "My Lists",
            largeTitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentLyst.title,
                ),
                const SizedBox(width: 10),
              ],
            ),
            trailing: const Icon(
              Icons.wifi,
              size: 24,
            ));
      case 'android':
        return SliverAppBar(
          expandedHeight: 90,
          forceElevated: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(lyst!.title),
          ),
        );
      default:
    }
  }
}

//NeedsAttention: if needed create a sliver toggle,
class TaskTilesView extends StatefulWidget {
  const TaskTilesView({Key? key}) : super(key: key);

  @override
  State<TaskTilesView> createState() => _TaskTilesViewState();
}

class _TaskTilesViewState extends State<TaskTilesView> {
  final TextEditingController newTaskController = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildListDelegate([
      Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 10.0, bottom: 0.0),
        child: TextField(
          controller: newTaskController,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(0.0),
              isDense: true,
              border: InputBorder.none,
              hintText: "New Task",
              suffix: Consumer<Lyst>(builder: (context, currentLyst, child) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () =>
                      currentLyst.newTask(newTaskController.text).then((value) => newTaskController.clear()),
                );
              })),
        ),
      ),
      Consumer<Lyst>(builder: (context, currentLyst, child) {
        return ReorderableListView.builder(
            reverse: true,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              Task _currentTask = currentLyst.tasks[index];
              if (!_currentTask.done) {
                Key pseudoUniqeuKey = Key("task-${_currentTask.hashCode}");
                return ChangeNotifierProvider.value(
                    key: pseudoUniqeuKey,
                    value: currentLyst,
                    builder: (context, child) {
                      return TaskTile(key: pseudoUniqeuKey, task: _currentTask);
                    });
              }
              return SizedBox(
                // height: 50,
                key: ValueKey("${currentLyst.lystId}-empty-$index"),
              );
            },
            itemCount: currentLyst.tasks.length,
            onReorder: (oldIndex, newIndex) => setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  Task _task = currentLyst.tasks.removeAt(oldIndex);
                  currentLyst.tasks.insert(newIndex, _task);
                }));
      }),

      //* done button
      Consumer<Lyst>(builder: (context, currentLyst, child) {
        return TextButton(
          child: Text("Done tasks (${currentLyst.doneCounter})"),
          onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) {
                return ChangeNotifierProvider<Lyst>.value(
                    value: currentLyst,
                    builder: (context, snapshot) {
                      return NestedScrollView(
                        headerSliverBuilder: (context, _) => [
                          SliverAppBar(
                            automaticallyImplyLeading: false,
                            pinned: true,
                            backgroundColor: Theme.of(context).canvasColor,
                            actions: [
                              IconButton(
                                  onPressed: () => Navigator.of(context).pop,
                                  icon: const CloseButton(
                                    color: Colors.black,
                                  ))
                            ],
                            title: Consumer<Lyst>(builder: (context, currentLyst, child) {
                              return Text(
                                "Done tasks (${currentLyst.doneCounter})",
                                style: const TextStyle(color: Colors.black),
                              );
                            }),
                          )
                        ],
                        //* disabled tasks
                        body: Consumer<Lyst>(builder: (context, currentLyst, child) {
                          return ListView.builder(
                              itemCount: currentLyst.tasks.length,
                              itemBuilder: (context, index) {
                                Task _currentTask = currentLyst.tasks[index];
                                if (_currentTask.done) {
                                  return Column(
                                    children: [
                                      TaskTile(
                                        key: UniqueKey(),
                                        enabled: false,
                                        task: _currentTask,
                                      )
                                    ],
                                  );
                                }
                                return const SizedBox(
                                  height: 0,
                                );
                              });
                        }),
                      );
                    });
              }),
        );
      }),
    ]));
  }
}

class TaskTile extends StatefulWidget {
  final Task task;
  final bool enabled;
  final bool nested;
  final Task? parentTask;
  const TaskTile({
    required Key? key,
    this.parentTask,
    this.nested = false,
    this.enabled = true,
    required this.task,
  })  : assert(nested == (parentTask != null)),
        super(key: key);

  @override
  _TaskTileState createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool _isOpen = false;
  late bool _check;
  TextEditingController? taskController;

  @override
  void initState() {
    taskController = TextEditingController(
      text: widget.task.taskTitle,
    );
    taskController!.addListener(() {
      widget.task.taskTitle = taskController!.text;
    });
    _check = widget.task.done;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      behavior: HitTestBehavior.deferToChild,
      background: Container(
        color: Colors.red.withAlpha(200),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      key: widget.key!,
      onDismissed: (direction) => widget.enabled
          ? widget.nested
              ? Provider.of<Lyst>(context, listen: false).removeNestedTask(widget.task, widget.parentTask!)
              : Provider.of<Lyst>(context, listen: false).removeTask(widget.task)
          : null,
      child: IgnorePointer(
        ignoring: !widget.nested ? !(_check ^ widget.enabled) : false,
        child: Column(key: widget.key, children: <Widget>[
          ///Divider
          const Divider(
            height: 0.0,
          ),

          /// Task List Tile
          Consumer<Lyst>(builder: (context, currentLyst, child) {
            return ListTile(
                trailing: widget.enabled && !widget.nested
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _isOpen = true;
                          });
                          currentLyst.addNestedTask(widget.task);
                        },
                        icon: const Icon(Icons.add))
                    : null,
                visualDensity: widget.nested ? VisualDensity.compact : VisualDensity.adaptivePlatformDensity,
                dense: !widget.enabled || widget.nested,
                onTap: !widget.enabled
                    ? () async {
                        setState(() {
                          _check = !_check;
                        });
                        !widget.nested
                            ? await Future.delayed(const Duration(milliseconds: 400))
                                .then((value) => currentLyst.setDone(widget.task))
                            : null;
                      }
                    : null,

                /// Checkbox
                leading: Transform.scale(
                  scale: widget.enabled && !widget.nested ? 1.2 : 0.9,
                  child: Checkbox(
                    fillColor: widget.enabled ? null : MaterialStateProperty.all(Colors.grey),
                    onChanged: (val) async {
                      setState(() {
                        _check = !_check;
                      });
                      !widget.nested
                          ? await Future.delayed(const Duration(milliseconds: 400))
                              .then((value) => currentLyst.setDone(widget.task))
                          : await Future.delayed(const Duration(milliseconds: 400))
                              .then((value) => currentLyst.setNestedTaskDone(widget.task, widget.parentTask!));
                    },
                    shape: const CircleBorder(),
                    value: _check,
                  ),
                ),
                title: TextField(
                    enabled: widget.enabled,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    controller: taskController,
                    style: TextStyle(
                      decoration: _check ? TextDecoration.lineThrough : TextDecoration.none,
                    )));
          }),
          // Nested Task Tiles
          if (widget.enabled)
            AnimatedContainer(
              height: _isOpen
                  ? 60.0 * widget.task.nestedTask!.length + 35
                  : (widget.task.nestedTask?.length ?? 0) > 0
                      ? 35
                      : 0.0,
              duration: const Duration(milliseconds: 150),
              child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(0),
                  shrinkWrap: true,

                  /// generate a widget under the task only if there are nested tasks.
                  itemCount: widget.task.nestedTask != null && widget.task.nestedTask!.isNotEmpty
                      ? widget.task.nestedTask!.length + 1
                      : 0,

                  /// take first index is the button
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return InkWell(
                        onTap: () => setState(() {
                          _isOpen = !_isOpen;
                        }),
                        child: AnimatedCrossFade(
                          firstCurve: Curves.easeIn,
                          crossFadeState: _isOpen ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 50),
                          firstChild: SizedBox(
                            height: 35.0,
                            child: Row(
                              children: const [
                                Padding(padding: EdgeInsets.only(left: 25)),
                                Icon(
                                  Icons.close,
                                  size: 18,
                                ),
                                Padding(padding: EdgeInsets.only(left: 25)),
                                Text("hide tasks")
                              ],
                            ),
                          ),
                          secondChild: Row(
                            children: [
                              const Padding(padding: EdgeInsets.only(left: 25)),
                              const Icon(
                                Icons.menu_open,
                                size: 18,
                              ),
                              const Padding(padding: EdgeInsets.only(left: 25)),
                              Text("${widget.task.nestedTask!.length} more tasks")
                            ],
                          ),
                        ),
                      );
                    }
                    if (!_isOpen) {
                      return const SizedBox();
                    }
                    index -= 1;
                    Task _currentNestedTask = widget.task.nestedTask![index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: TaskTile(
                        key: Key(widget.key.toString() + _currentNestedTask.hashCode.toString()),
                        task: _currentNestedTask,
                        parentTask: widget.task,
                        nested: true,
                      ),
                    );
                  }),
            )
        ]),
      ),
    );
  }
}

final List jsons = [list, list_2];

Map list = {
  "lystId": "lysts-01",
  "title": "Some List",
  "tasks": [
    {"taskTitle": "Get the money", "done": true},
    {
      "taskTitle": "Get the bitches",
      "done": false,
      "nestedTasks": [
        {"taskTitle": "white bitches", "done": true},
        {"taskTitle": "brown bitches", "done": true},
        {"taskTitle": "fine bitches", "done": false}
      ]
    },
    {"taskTitle": "fuck them bitches", "done": false}
  ]
};

Map list_2 = {
  "lystId": "lysts-02",
  "title": "Some other list",
  "tasks": [
    {"taskTitle": "the real genish", "done": true},
    {
      "taskTitle": "Get the bitches",
      "done": false,
      "nestedTasks": [
        {"taskTitle": "white bitches", "done": true},
        {"taskTitle": "brown bitches", "done": true},
        {"taskTitle": "fine bitches", "done": false}
      ]
    },
    {"taskTitle": "fuck them bitches", "done": false}
  ]
};
