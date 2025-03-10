import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:SafetyNet/screens/emergency_pop_up.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:SafetyNet/screens/home_page.dart';
import 'package:SafetyNet/screens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await dotenv.load(fileName: "config.env");
  runApp(MyApp(
    isLoggedIn: prefs.getBool("isLoggedIn") ?? false,
    isFirstTime: prefs.getBool("isFirstTime") ?? true,
    isEmergency: prefs.getBool("isEmergency") ?? false,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn, isFirstTime, isEmergency;

  const MyApp({super.key, required this.isLoggedIn, required this.isFirstTime, required this.isEmergency});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafetyNet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: isEmergency
        ? const EmergencyPopUp()
        : isLoggedIn
          ? const HomePage()
          : const Login(),
      // home: const Placeholder()
    );
  }
}