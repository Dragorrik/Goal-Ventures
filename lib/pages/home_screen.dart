import 'package:flutter/material.dart';

import 'package:goal_ventures/pages/task_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'G o a l    V e n t u r e s',
            style: TextStyle(),
          ),
          bottom: const TabBar(
            dividerHeight: 0,
            labelColor: Color(0XFFDDD3A4),
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Monthly'),
              Tab(text: 'Yearly'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TaskScreen(category: 'Daily'),
            TaskScreen(category: 'Monthly'),
            TaskScreen(category: 'Yearly'),
          ],
        ),
      ),
    );
  }
}
