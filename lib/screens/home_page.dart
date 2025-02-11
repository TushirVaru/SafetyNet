import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initializeSharedPreference();
  }

  Future<void> initializeSharedPreference() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HomePage"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: logOut,
          child: const Text("LogOut"),
        ),
      ),
    );
  }

  void logOut() async {
    await prefs.setBool("isLoggedIn", false);
    print("User logged out!");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }
}
