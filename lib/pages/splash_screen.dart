import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:goal_ventures/pages/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to the home screen after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color(0XFF111A24), // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Colorize Animated Text for "Goal Ventures"
            AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  'Goal Ventures',
                  textStyle: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  colors: [
                    const Color(0XFFDDD3A4),
                    const Color.fromARGB(255, 240, 223, 150),
                    Colors.white,
                    Colors.white70,
                  ],
                ),
              ],
              totalRepeatCount: 1,
            ),
            const SizedBox(height: 20),
            // Colorize Animated Text for tagline
            AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  'Conquer Your Goals!',
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                  ),
                  colors: [
                    Colors.white,
                    Colors.white70,
                    const Color(0XFFDDD3A4),
                    const Color.fromARGB(255, 240, 223, 150),
                  ],
                ),
              ],
              isRepeatingAnimation: true,
            ),
          ],
        ),
      ),
    );
  }
}
