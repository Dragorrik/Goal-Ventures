import 'package:flutter/material.dart';
import 'package:goal_ventures/models/task_model.dart';
import 'package:goal_ventures/providers/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HighlightedCalendar extends StatefulWidget {
  final String category;
  const HighlightedCalendar({super.key, required this.category});

  @override
  _HighlightedCalendarState createState() => _HighlightedCalendarState();
}

class _HighlightedCalendarState extends State<HighlightedCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<String>> _generateHighlightedDays(List<Task> tasks) {
    final Map<DateTime, List<String>> highlightedDays = {};

    for (var task in tasks) {
      if (task.dueDate != null) {
        final taskDate = DateTime(
            task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
        if (highlightedDays.containsKey(taskDate)) {
          highlightedDays[taskDate]!.add(task.title);
        } else {
          highlightedDays[taskDate] = [task.title];
        }
      }
    }

    return highlightedDays;
  }

  // Show tasks for the selected day in a dialog
  void _showTaskDialog(List<Task> tasks) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0XFF111A24),
          content: tasks.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: tasks.map((task) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              task.title,
                              style: const TextStyle(
                                color: Color(0XFFDDD3A4),
                                fontSize: 20,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                Text('Description: \n${task.description}'),
                                const SizedBox(height: 5),
                                Text('Created: \n${task.createdTime}'),
                                const SizedBox(height: 5),
                                if (task.dueDate != null)
                                  Text('Due: \n${task.dueDate}'),
                                const Divider(color: Colors.grey),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 219, 82, 73),
                                  elevation: 5,
                                ),
                                onPressed: () {
                                  final taskProvider =
                                      Provider.of<TaskProvider>(context,
                                          listen: false);
                                  taskProvider.deleteSpecificTask(task);
                                  Navigator.of(context).pop(); // Close dialog
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0XFF111A24),
                                  elevation: 5,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close dialog
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                )
              : const Text(
                  textAlign: TextAlign.center,
                  'No tasks for this date\nAdd new task or find your\nremaining tasks under the\nred dotted date',
                  style: TextStyle(color: Color(0XFFDDD3A4)),
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.getTasks(widget.category);

    final highlightedDays = _generateHighlightedDays(tasks);

    List<String> getEventsForDay(DateTime day) {
      return highlightedDays[DateTime(day.year, day.month, day.day)] ?? [];
    }

    // Define the start and end of the current month
    final currentMonthStart = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final currentMonthEnd = DateTime(_focusedDay.year, _focusedDay.month + 1,
        0); // Last day of current month
    final lastYear = DateTime(_focusedDay.year + 100, 12, 31);

    return Scaffold(
        body: Column(
      children: [
        TableCalendar(
          firstDay: currentMonthStart,
          lastDay: widget.category == 'Monthly' ? currentMonthEnd : lastYear,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay; // Update the focused day
            });

            // Show tasks for the selected day
            final tasksForDay = tasks.where((task) {
              final taskDate = DateTime(
                  task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
              return isSameDay(taskDate, selectedDay);
            }).toList();

            _showTaskDialog(tasksForDay);
          },
          eventLoader: getEventsForDay, // Load tasks as events
          calendarStyle: const CalendarStyle(
            isTodayHighlighted: true,
            markerDecoration: BoxDecoration(
              color: Colors.red, // Highlight color for events
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Color.fromARGB(255, 179, 149, 60),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Color.fromARGB(255, 114, 114, 112),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    ));
  }
}
