import 'package:SafetyNet/screens/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late SharedPreferences prefs;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeSharedPreference();
  }

  initializeSharedPreference() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff1b1725)
      ),

      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xff1b1725)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),

            //Welcome Banner
            const Text(
              "Welcome Back!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),

            //Email Field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                prefixIcon: const Icon(Icons.email),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 15),

            //Password Field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 30),

            //Login Button
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 30),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ), // Button color
              ),
              child: const Text(
                'Login',
                style: TextStyle(color: Color(0xff1b1725), fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),

            //Forget Button
            TextButton(
              onPressed: () {},
              child: const Text(
                "Forget your password?",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            // const SizedBox(height: 10),

            //SignIn Button
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SignIn()),
                );
              },
              child: const Text(
                "Don't have an account? Sign In",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Handle Login Logic
  void onPressed() async{
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      // Save user login state in SharedPreferences
      prefs.setBool("isLoggedIn", true);

      final url = Uri.parse('https://safetynet-phi.vercel.app/api/v1/users/login');

      final Map<String, dynamic> data = {
        "email": _emailController.text,
        "password": _passwordController.text,
      };

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        );

        print("_---------------------------------------");
        print("Responce ${jsonDecode(response.body)["status"]}");
        print("_---------------------------------------");

        if (jsonDecode(response.body)["status"] == "success") {
          // Success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login successful!")),
          );
          prefs.setString("jwt", jsonDecode(response.body)["token"]);

          // Navigate to HomePage after successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          // Failure
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData["message"] ?? "Signup failed!")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
        print("_---------------------------------------");
        print("Error: $e");
        print("_---------------------------------------");
      }

      // // Navigate to HomePage after successful login
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const HomePage()),
      // );
    } else {
      // Show error if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
    }
  }
}
