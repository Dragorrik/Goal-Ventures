import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  final Box<Task> _taskBox = Hive.box<Task>('tasks');

  List<Task> getTasks(String category) {
    return _taskBox.values.where((task) => task.category == category).toList();
  }

  void addTask(Task task) {
    _taskBox.add(task);
    notifyListeners();
  }

  void deleteTaskAtIndex(int index) {
    _taskBox.deleteAt(index);
    notifyListeners();
  }

  void deleteSpecificTask(Task task) {
    final key = _taskBox.keys.firstWhere(
      (k) => _taskBox.get(k) == task,
      orElse: () => null,
    );

    if (key != null) {
      _taskBox.delete(key);
      notifyListeners();
    }
  }
}
