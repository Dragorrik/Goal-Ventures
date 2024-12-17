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

  void markTaskAsCompleted(Task task) {
    task.isCompleted = true; // Mark the task as completed
    task.save(); // Save the changes in Hive
    notifyListeners(); // Notify listeners to refresh the UI
  }

  double calculateCompletionPercentage(String category) {
    final tasks = getTasks(category);
    if (tasks.isEmpty) return 0.0;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    return (completedTasks / tasks.length) * 100;
  }

  Task? getLastCompletedTask(String category) {
    final completedTasks = _taskBox.values
        .where((task) => task.category == category && task.isCompleted)
        .toList();

    if (completedTasks.isEmpty) return null;

    // Sort by createdTime in descending order and return the first
    completedTasks.sort((a, b) => b.createdTime.compareTo(a.createdTime));
    return completedTasks.first;
  }

  void handleNewDayTask(Task newTask, String category) {
    final lastCompletedTask = getLastCompletedTask(category);

    if (lastCompletedTask != null) {
      // Extract dates for comparison
      final lastCompletedDate = DateTime(
        lastCompletedTask.createdTime.year,
        lastCompletedTask.createdTime.month,
        lastCompletedTask.createdTime.day,
      );

      final newTaskDate = DateTime(
        newTask.createdTime.year,
        newTask.createdTime.month,
        newTask.createdTime.day,
      );

      if (category == 'Daily') {
        // Clear completed tasks only if the new task is for the next consecutive day
        if (newTaskDate.difference(lastCompletedDate).inDays == 1) {
          clearCompletedTasks(category);
          resetPercentageBar(category);
        }
      } else if (category == 'Weekly') {
        // Clear tasks when entering a new month
        if (lastCompletedTask.createdTime.month != newTask.createdTime.month) {
          clearCompletedTasks(category);
          resetPercentageBar(category);
        }
      } else if (category == 'Monthly') {
        // No clearing for monthly tasks
        // Tasks are retained in the completed list.
      }
    }

    // Add the new task to the task box
    addTask(newTask);
  }

  void clearCompletedTasks(String category) {
    final completedTasksKeys = _taskBox.keys
        .where((key) =>
            _taskBox.get(key)?.category == category &&
            (_taskBox.get(key)?.isCompleted ?? false))
        .toList();

    for (var key in completedTasksKeys) {
      _taskBox.delete(key);
    }

    notifyListeners();
  }

  void resetPercentageBar(String category) {
    // Logic to reset percentage can be implemented here
    notifyListeners();
  }
}
