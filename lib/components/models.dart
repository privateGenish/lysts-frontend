import 'dart:async';
import 'package:flutter/material.dart';
import 'components.dart';

class Lyst extends ChangeNotifier {
  String title;
  final String lystId;
  String? description;
  final List<Task> tasks;
  String type;
  bool pinned;

  Lyst(
      {required this.title,
      required this.tasks,
      required this.lystId,
      this.description,
      this.type = "coding",
      this.pinned = false});

  set isPinned(bool pin) {
//NeedsAttention: figure out if you need to sync this w/ backend
    pinned = pin;
    notifyListeners();
  }

  bool get isPinned => pinned;

  static fromJson(json) => Lyst(
      description: json["description"],
      lystId: json["lystId"],
      title: json["title"],
      tasks: List.generate(json["tasks"]?.length ?? 0, (index) => Task.fromJson(json["tasks"][index])));

  get doneCounter {
    int _cntr = 0;
    for (var task in tasks) {
      if (task.done) {
        _cntr++;
      } else {
        if (task.taskTitle.isEmpty) {
          for (Task nestedTask in task.nestedTask ?? []) {
            if (nestedTask.taskTitle.isNotEmpty) {
              return _cntr++;
            }
          }
          _cntr++;
        }
      }
    }
    return _cntr;
  }

  Map toJson() {
    Map json = {};
    json["title"] = title;
    json["lystId"] = lystId;
    json["description"] = description;
    json["tasks"] = List.generate(tasks.length, (index) => tasks[index].toJson());
    return json;
  }

  void setDone(Task task) {
    var index = tasks.indexOf(task);
    tasks[index].done = !tasks[index].done;
    notifyListeners();
  }

  Future<void> newTask(String taskTitle) async {
    if (taskTitle.trim().isNotEmpty) {
      tasks.add(Task(taskTitle: taskTitle, done: false));
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) async {
    var index = tasks.indexOf(task);
    if (index < 0) return;
    tasks.replaceRange(index, ++index, [task]);
  }

  removeTask(Task task) {
    try {
      tasks.removeWhere((element) => element == task);
      notifyListeners();
    } catch (e) {
      throw AppFailLogs.internalError(err: e);
    }
  }

  Future<void> addNestedTask(Task task) async {
    if ((task.nestedTask ?? []).isEmpty) {
      task.nestedTask = [Task(taskTitle: "", done: false)];
      notifyListeners();
    } else {
      task.nestedTask!.add(Task(taskTitle: "", done: false));
      notifyListeners();
    }
  }

  Future<void> updateNestedTask(Task task, Task currentNestedTask, Task updatedNestedTask) async {
    int index = task.nestedTask!.indexWhere((element) => element == currentNestedTask);
    if (index < 0) return;
    task.nestedTask!.replaceRange(index, ++index, [updatedNestedTask]);
  }

  Future<void> setNestedTaskDone(Task nestedTask, Task parentTask) async {
    int index = parentTask.nestedTask!.indexWhere((element) => element == nestedTask);
    parentTask.nestedTask![index].done = !(nestedTask.done);
    notifyListeners();
  }

  Future<void> removeNestedTask(Task nestedTask, Task parentTask) async {
    try {
      parentTask.nestedTask?.removeWhere((element) => element == nestedTask);
      notifyListeners();
    } catch (e) {
      throw AppFailLogs.internalError(err: e);
    }
  }
}

class Task {
  String taskTitle;
  bool done;
  List<Task>? nestedTask;

  Task({required this.taskTitle, required this.done, this.nestedTask});

  static fromJson(json) => Task(
      taskTitle: json["taskTitle"],
      done: json["done"],
      nestedTask:
          List.generate(json["nestedTasks"]?.length ?? 0, (index) => Task.fromJson(json["nestedTasks"][index])));

  toJson() {
    var json = {};
    json["taskTitle"] = taskTitle;
    json["done"] = done;
    json["nestedTasks"] = List.generate(nestedTask?.length ?? 0, (index) => nestedTask?[index].toJson());

    return json;
  }
}
