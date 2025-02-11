import 'package:SafetyNet/screens/home_page.dart';
import 'package:SafetyNet/screens/login.dart';
import 'package:SafetyNet/screens/on_boarding.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //initializing shared preference
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
  bool? isFirstTime = prefs.getBool("isFirstTime") ?? true;

  runApp(MyApp(isLoggedIn: isLoggedIn, isFirstTime: isFirstTime));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn, isFirstTime;

  const MyApp({super.key, required this.isLoggedIn, required this.isFirstTime});
  // const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isFirstTime? const OnboardingScreen(): isLoggedIn ? const HomePage() : const Login(),
    );
  }
}