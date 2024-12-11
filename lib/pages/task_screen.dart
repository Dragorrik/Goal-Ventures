import 'package:flutter/material.dart';
import 'package:goal_ventures/pages/calender_page.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskScreen extends StatefulWidget {
  final String category;

  const TaskScreen({super.key, required this.category});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  void _addTask(TaskProvider taskProvider) {
    final newTask = Task(
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _selectedDate,
      category: widget.category,
      createdTime: DateTime.now(),
    );
    taskProvider.addTask(newTask);
    _titleController.clear();
    _descriptionController.clear();
    _selectedDate = null;
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDate = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.getTasks(widget.category);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Tasks'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Show either the task list or calendar based on category
            SizedBox(
              height: widget.category == 'Daily'
                  ? MediaQuery.of(context).size.height * 0.25
                  : MediaQuery.of(context).size.height * 0.6,
              child: widget.category == 'Daily'
                  ? ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return ListTile(
                          leading: Text(
                            "${index + 1} .",
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          title: Text(task.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.description),
                              if (task.dueDate != null)
                                Text(
                                    'Due: ${task.dueDate?.hour}:${task.dueDate?.minute}'),
                              Text(
                                  'Created: ${task.createdTime.year}-${task.createdTime.month}-${task.createdTime.day}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => taskProvider.deleteTask(index),
                          ),
                        );
                      },
                    )
                  : HighlightedCalendar(
                      category: widget.category,
                    ), // Show calendar for "Monthly" and "Yearly"
            ),
            // Input fields and buttons

            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Task Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'No Due ${widget.category == "Daily" ? "Time" : "Date & Time"} Set'
                            : 'Due: ${_selectedDate?.year.toString()}-${_selectedDate?.month.toString()}-${_selectedDate?.day.toString()}\n${_selectedDate?.hour.toString()}:${_selectedDate?.minute.toString()}',
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (widget.category == 'Daily') {
                            await _pickTime();
                          } else {
                            await _pickDateTime();
                          }
                        },
                        child: Text(widget.category == 'Daily'
                            ? 'Pick Time'
                            : 'Pick Date & Time'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _addTask(taskProvider),
                    child: const Text('Add Task'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
