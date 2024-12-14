import 'package:flutter/material.dart';
import 'package:goal_ventures/providers/task_provider.dart';
import 'package:provider/provider.dart';

class CompletedTaskPage extends StatefulWidget {
  final String category;
  const CompletedTaskPage({super.key, required this.category});

  @override
  State<CompletedTaskPage> createState() => _CompletedTaskPageState();
}

class _CompletedTaskPageState extends State<CompletedTaskPage> {
  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider
        .getTasks(widget.category)
        .where((task) => task.isCompleted) // Show only completed tasks
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Completed tasks"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          tasks.isEmpty
              ? const Center(
                  child: Text("You haven't completed any tasks"),
                )
              : Expanded(
                  child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                            top: 5,
                            left: 10,
                            right: 10,
                            bottom: 10,
                          ),
                          child: Card(
                            elevation: 10,
                            color: //const Color.fromARGB(255, 34, 34, 34)
                                const Color.fromARGB(255, 27, 27, 27),
                            shape: const ContinuousRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                task.title,
                                textAlign: TextAlign.center,
                                style:
                                    const TextStyle(color: Color(0XFFDDD3A4)),
                              ),
                              subtitle: Column(
                                //crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      textAlign: TextAlign.center,
                                      task.description),
                                  if (task.dueDate != null)
                                    Text(
                                        textAlign: TextAlign.center,
                                        'Due: ${task.dueDate?.hour}:${task.dueDate?.minute}'),
                                  Text(
                                      textAlign: TextAlign.center,
                                      'Created: ${task.createdTime.year}-${task.createdTime.month}-${task.createdTime.day}'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Top-left corner image
                        Positioned(
                          top: 6,
                          left: 10,
                          child: Image.asset(
                            'assets/top_left.png',
                            width: 15,
                            height: 15,
                          ),
                        ),
                        // Top-right corner image
                        Positioned(
                          top: 6,
                          right: 10,
                          child: Image.asset(
                            'assets/top_right.png',
                            width: 15,
                            height: 15,
                          ),
                        ),
                        // Bottom-left corner image
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Image.asset(
                            'assets/bottom_left.png',
                            width: 15,
                            height: 15,
                          ),
                        ),
                        // Bottom-right corner image
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Image.asset(
                            'assets/bottom_right.png',
                            width: 15,
                            height: 15,
                          ),
                        ),
                      ],
                    );
                  },
                )),
        ],
      ),
    );
  }
}
