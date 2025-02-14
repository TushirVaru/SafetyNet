import 'package:SafetyNet/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:SafetyNet/screens/login.dart';
import 'package:SafetyNet/screens/on_boarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
  bool? isFirstTime = prefs.getBool("isFirstTime") ?? true;

  runApp(MyApp(isLoggedIn: isLoggedIn, isFirstTime: isFirstTime));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn, isFirstTime;

  const MyApp({super.key, required this.isLoggedIn, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafetyNet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: isFirstTime ? const OnboardingScreen() : isLoggedIn ? const HomePage() : const Login(),
    );
  }
}