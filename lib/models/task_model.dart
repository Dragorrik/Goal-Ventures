import 'package:hive_flutter/hive_flutter.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final DateTime? dueDate; // Optional field for task's due time.

  @HiveField(3)
  final String category;

  @HiveField(4)
  final DateTime createdTime; // Time when the task is created.

  Task({
    required this.title,
    required this.description,
    this.dueDate,
    required this.category,
    required this.createdTime,
  });
}
