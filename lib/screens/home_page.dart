import 'package:SafetyNet/screens/home_page/emergency.dart';
import 'package:SafetyNet/screens/home_page/profile.dart';
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
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const Emergency(),
    const Profile(),
  ];

  @override
  void initState() {
    super.initState();
    initializeSharedPreference();
  }

  initializeSharedPreference() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        title: const Padding(
          padding: EdgeInsets.only(bottom: 13.0),
          child: Text("SafetyNet", style: TextStyle(fontSize: 35, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: const Color(0xff1b1725),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white,),
            onPressed: () async {
              await prefs.setBool("isLoggedIn", false);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Login()), (route) => false,
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: SizedBox(
        height: 80,
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: const Color(0xff1b1725),
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.white,
          selectedLabelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 16),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard, size: 30),
              label: "Emergency",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 30),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  void showConfirmDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xfff0f0f0),
        title: const Text("Confirmation", style: TextStyle(fontSize: 25)),
        content: const Text("Are you sure you want to proceed?", style: TextStyle(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Close dialog
            child: const Text("Cancel", style: TextStyle(fontSize: 19, color: Color(0xcf534b62))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirm action
            child: const Text("Confirm", style: TextStyle(fontSize: 19, color: Color(0xff226ce0))),
          ),
        ],
      ),
    );
  }
}

// Model class for Card
class CardModel {
  String name;
  String desc;
  String dept;

  CardModel(this.name, this.desc, this.dept);

  Map<String, dynamic> toJson() => {"name": name, "desc": desc, "dept": dept};

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(json["name"], json["desc"], json["dept"]);
  }
}



