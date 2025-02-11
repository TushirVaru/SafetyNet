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
        title: const Text("Login"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.blue
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              _buildWelcomeBanner(),
              const SizedBox(height: 30),
              _buildEmailField(),
              const SizedBox(height: 15),
              _buildPasswordField(),
              const SizedBox(height: 30),
              _buildLoginButton(),
              const SizedBox(height: 20),
              _buildForgetPasswordButton(),
              const SizedBox(height: 20),
              _buildSignInButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Welcome banner text
  Widget _buildWelcomeBanner() {
    return const Text(
      "Welcome Back!",
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  // Email text field
  Widget _buildEmailField() {
    return TextField(
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
    );
  }

  // Password text field
  Widget _buildPasswordField() {
    return TextField(
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
    );
  }

  // Login button
  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30), backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ), // Button color
      ),
      child: const Text(
        'Login',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  // Forget Password Button
  Widget _buildForgetPasswordButton() {
    return TextButton(
      onPressed: () {
        // Add functionality to reset password
        print("Forget password pressed");
      },
      child: const Text(
        "Forget your password?",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  // Sign In button (for users who don't have an account)
  Widget _buildSignInButton() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => SignIn()),
        );
        print("Sign In button pressed");
      },
      child: const Text(
        "Don't have an account? Sign In",
        style: TextStyle(color: Colors.white, fontSize: 16),
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
