import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late SharedPreferences prefs;
  int currentIndex = 1;

  void getMe() async{
    final url = Uri.parse('https://safetynet-phi.vercel.app/api/v1/users/me');

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json", "Authorization" : "Bearer ${prefs.get('jwt')}"},
      );

      final parsedResponse = jsonDecode(response.body);
      print("Parsed Body: ${parsedResponse}");
      if (parsedResponse["status"] == "success") {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data Fetched successful!")),
        );
        print("_---------------------------------------");
        print("Data Fetched Successfully");
        print("_---------------------------------------");
      } else {
        // Failure
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData["message"] ?? "Signup failed!")),
        );
        print("_---------------------------------------");
        print(responseData["message"] ?? "Signup failed!");
        print("_---------------------------------------");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      print("_---------------------------------------");
      print("Error: $e");
      print("_---------------------------------------");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadSharedPreference();
    getMe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: const Column(
          children: [
            Text("Profile", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
            Divider(height: 10, thickness: 2, color: Colors.black,),
          ],
        ),
      ),
    );
  }

  void loadSharedPreference() async{
    prefs = await SharedPreferences.getInstance();
  }
}
