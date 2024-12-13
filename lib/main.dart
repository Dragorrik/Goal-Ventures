import 'package:flutter/material.dart';
import 'package:goal_ventures/models/task_model.dart';
import 'package:goal_ventures/pages/splash_screen.dart';
import 'package:goal_ventures/providers/task_provider.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and register the Task adapter
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasks'); // Open a Hive box for tasks
  runApp(ChangeNotifierProvider(
    create: (_) => TaskProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Goal Ventures',
      theme: ThemeData(
        brightness: Brightness.dark, // Sets the app to dark mode
        scaffoldBackgroundColor: const Color(0XFF111A24),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0XFFDDD3A4)), // Default text color
          bodyMedium: TextStyle(color: Color(0XFFDDD3A4)), // Medium text color
          bodySmall: TextStyle(color: Color(0XFFDDD3A4)), // Small text color
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0XFF111A24), // AppBar background color
          iconTheme: IconThemeData(color: Colors.white), // AppBar icon color
          titleTextStyle:
              TextStyle(color: Color(0XFFDDD3A4), fontSize: 20), // Title color
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
