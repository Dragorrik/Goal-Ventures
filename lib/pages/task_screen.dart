import 'package:flutter/material.dart';
import 'package:goal_ventures/pages/calender_page.dart';
import 'package:goal_ventures/pages/completed_task_page.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskScreen extends StatefulWidget {
  final String category;

  const TaskScreen({super.key, required this.category});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  //Animation part
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addTask(TaskProvider taskProvider) {
    // Check if fields are empty
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          elevation: 5,
          content: Text(
            "Please fill in all fields to add a task.",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0XFFB75B48),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Create the new task
    final newTask = Task(
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _selectedDate,
      category: widget.category,
      createdTime: DateTime.now(),
    );

    // Use handleNewDayTask to add the task and handle new day logic
    taskProvider.handleNewDayTask(newTask, widget.category);

    // Clear fields
    _titleController.clear();
    _descriptionController.clear();
    _selectedDate = null;

    // Show a success Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        elevation: 5,
        content: Text(
          "Task added successfully!",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color.fromARGB(255, 2, 163, 7),
        behavior: SnackBarBehavior.floating,
      ),
    );
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

  Future<void> _pickDateTime(String category) async {
    DateTime now = DateTime.now(); // Current date and time
    DateTime startOfMonth =
        DateTime(now.year, now.month, 1); // First day of the current month
    DateTime endOfMonth =
        DateTime(now.year, now.month + 1, 0); // Last day of the current month

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: startOfMonth, // Restrict to the start of the current month
      lastDate: category == 'Weekly'
          ? endOfMonth
          : DateTime(2100), // End of the current month or 2100
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
    final tasks = taskProvider
        .getTasks(widget.category)
        .where((task) => !task.isCompleted) // Show only incomplete tasks
        .toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(10),
                height: MediaQuery.of(context).size.height * 0.14,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: Color.fromARGB(255, 23, 39, 58),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.category} Tasks',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    CircularPercentIndicator(
                      radius: 30.0,
                      lineWidth: 6.0,
                      percent: taskProvider
                              .calculateCompletionPercentage(widget.category) /
                          100,
                      center: Text(
                        '${taskProvider.calculateCompletionPercentage(widget.category).toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 11),
                      ),
                      progressColor: Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              tasks.isEmpty
                  ? SingleChildScrollView(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.35,
                        child: const Center(
                          child: Text(
                            'No tasks available.\nCreate tasks from below.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  :
                  // Show either the task list or calendar based on category
                  SizedBox(
                      height: widget.category == 'Daily'
                          ? MediaQuery.of(context).size.height * 0.35
                          : MediaQuery.of(context).size.height * 0.68,
                      child: widget.category == 'Daily'
                          ? ListView.builder(
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
                                            const Color.fromARGB(
                                                255, 27, 27, 27),
                                        shape: const ContinuousRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15),
                                          ),
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            textAlign: TextAlign.center,
                                            task.title,
                                            style: const TextStyle(
                                                color: Color(0XFFDDD3A4)),
                                          ),
                                          subtitle: Column(
                                            // crossAxisAlignment:
                                            //     CrossAxisAlignment.start,
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
                                              InkWell(
                                                onTap: () => taskProvider
                                                    .markTaskAsCompleted(task),
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 15),
                                                  width: double.infinity,
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color.fromARGB(
                                                              255, 219, 82, 73),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10))),
                                                  child: const Text(
                                                    textAlign: TextAlign.center,
                                                    'Done',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
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
                            )
                          : HighlightedCalendar(
                              category: widget.category,
                            ), // Show calendar for "Monthly" and "Yearly"
                    ),
              // Input fields and buttons
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CompletedTaskPage(
                                      category: widget.category,
                                    )));
                      },
                      child: Container(
                        //margin: const EdgeInsets.all(15),
                        //padding: const EdgeInsets.all(5),
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Color.fromARGB(255, 2, 163, 7),
                          border: Border(
                            top: BorderSide(
                              color: Colors.white,
                              //width: 1.2,
                            ),
                            left: BorderSide(
                              color: Colors.white,
                              //width: 1.2,
                            ),
                            bottom: BorderSide(
                              color: Colors.white,
                              //width: 1.2,
                            ),
                            right: BorderSide(
                              color: Colors.white,
                              // width: 1.2,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${widget.category} Completed Tasks',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                //fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 23, 39, 58),
                        labelText: 'Task Title',
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(
                        color:
                            Colors.white, // Change this to your desired color
                        fontSize: 16, // Optional: Change font size
                        fontWeight:
                            FontWeight.bold, // Optional: Change font weight
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      maxLines: 2,
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 23, 39, 58),
                        labelText: 'Task Description',
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(
                        color:
                            Colors.white, // Change this to your desired color
                        fontSize: 16, // Optional: Change font size
                        fontWeight:
                            FontWeight.bold, // Optional: Change font weight
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
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            shape: const ContinuousRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            backgroundColor:
                                const Color.fromARGB(255, 23, 39, 58),
                          ),
                          onPressed: () async {
                            if (widget.category == 'Daily') {
                              await _pickTime();
                            } else {
                              await _pickDateTime(widget.category);
                            }
                          },
                          child: Text(
                            widget.category == 'Daily'
                                ? 'Pick Time'
                                : 'Pick Date & Time',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        shape: const ContinuousRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        backgroundColor: const Color.fromARGB(255, 23, 39, 58),
                      ),
                      onPressed: () {
                        //debugPrint("TASK IS ${tasks.isEmpty}");
                        _addTask(taskProvider);
                        //debugPrint("TASK IS $tasks");
                      },
                      child: const Text(
                        'Add Task',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
