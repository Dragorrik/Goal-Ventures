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

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.getTasks(widget.category);

    final highlightedDays = _generateHighlightedDays(tasks);

    List<String> _getEventsForDay(DateTime day) {
      return highlightedDays[DateTime(day.year, day.month, day.day)] ?? [];
    }

    return Scaffold(
        body: Column(
      children: [
        TableCalendar(
          firstDay: DateTime(2020, 1, 1),
          lastDay: DateTime(2100, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay; // Update the focused day
            });
          },
          eventLoader: _getEventsForDay, // Load tasks as events
          calendarStyle: const CalendarStyle(
            isTodayHighlighted: true,
            markerDecoration: BoxDecoration(
              color: Colors.red, // Highlight color for events
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Color.fromARGB(255, 114, 114, 112),
              shape: BoxShape.circle,
            ),
          ),
        ),
        //   if (_selectedDay != null) ...[
        //     const SizedBox(height: 10),
        //     Text(
        //       'Tasks on ${_selectedDay!.toLocal().toString().split(' ')[0]}:',
        //       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        //     ),
        //     const SizedBox(height: 10),
        //     Expanded(
        //       child: ListView(
        //         children: _getEventsForDay(_selectedDay!).map((event) {
        //           return ListTile(
        //             title: Text(event),
        //           );
        //         }).toList(),
        //       ),
        //     ),
        //   ],
      ],
    ));
  }
}
