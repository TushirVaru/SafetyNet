import 'package:SafetyNet/screens/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

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
        backgroundColor: Colors.blue,
      ),

      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.blue
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),

            //Welcome Banner
            Text(
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
                prefixIcon: Icon(Icons.email),
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
                prefixIcon: Icon(Icons.lock),
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
                style: TextStyle(color: Colors.blue, fontSize: 18),
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
                  MaterialPageRoute(builder: (context) => SignIn()),
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
  void onPressed() {
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      // Save user login state in SharedPreferences
      prefs.setBool("isLoggedIn", true);

      // Navigate to HomePage after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // Show error if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
    }
  }
}
