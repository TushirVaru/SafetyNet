import 'package:SafetyNet/screens/login.dart'; // Make sure this path is correct
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dateController = TextEditingController();
  final ageController = TextEditingController();
  final contactController = TextEditingController();

  final signInController = PageController();

  String selectedGender = '';
  bool isLastPage = false;

  @override
  void dispose() {
    signInController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView(
          controller: signInController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              isLastPage = index == 1;
            });
          },
          children: [
            // Sign-In Pages
            _basicInfo(),

            // Success Page
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 100, color: Colors.green),
                  const SizedBox(height: 20),
                  const Text(
                    'Sign In Successful!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'You are now Registered.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    child: const Text("Go to Login Page"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _basicInfo(){
    bool _isValidPage(BuildContext context) {
      bool isValid = true;

      // Helper function to show snack bars
      void showSnackBar(String message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 1), // Short duration
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        );
      }

      // Validation conditions
      if (firstNameController.text.isEmpty) {
        showSnackBar("Name cannot be empty");
        isValid = false;
      }if (middleNameController.text.isEmpty) {
        showSnackBar("Name cannot be empty");
        isValid = false;
      }if (lastNameController.text.isEmpty) {
        showSnackBar("Name cannot be empty");
        isValid = false;
      }
      if (dateController.text.isEmpty) {
        showSnackBar("Please select a valid Date of Birth");
        isValid = false;
      }
      if (ageController.text.isEmpty || int.tryParse(ageController.text) == null) {
        showSnackBar("Invalid age");
        isValid = false;
      }
      if (emailController.text.isEmpty || !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(emailController.text)) {
        showSnackBar("Enter a valid email address");
        isValid = false;
      }
      if (selectedGender.isEmpty) {
        showSnackBar("Please select a gender");
        isValid = false;
      }

      return isValid;
    }

    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // const Icon(Icons.lock, size: 100, color: Colors.blue),
          // const SizedBox(height: 20),
          // const Text(
          //   'Sign In',
          //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          // ),
          // const SizedBox(height: 10),

          //Name
          const Text("Name", style: TextStyle(fontSize: 20)),
          const SizedBox(height: 5),
          //First Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                  labelText: 'First Name', border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(height: 20),
          //Middle Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: middleNameController,
              decoration: const InputDecoration(
                  labelText: 'Middle Name', border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(height: 20),
          //Last Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                  labelText: 'Last Name', border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(height: 20),

          //Username
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: emailController,
              decoration: const InputDecoration(
                  labelText: 'Username', border: OutlineInputBorder()),
            ),
          ),
          const Text("It should only contain small case alphabet without any special symbol or sign", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),

          //DOB
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'DOB:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'DD/MM/YYYY',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today, size: 20),
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null) {
                            setState(() {
                              // Update DOB field
                              dateController.text =
                              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";

                              // Calculate age
                              DateTime today = DateTime.now();
                              int age = today.year - pickedDate.year;
                              if (today.month < pickedDate.month ||(today.month == pickedDate.month && today.day < pickedDate.day)) {
                                age--;
                              }

                              // Update Age field
                              ageController.text = age.toString();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          //Age
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: ageController,
              readOnly: true, // Make age field read-only
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          //Gender
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gender:',
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    Radio<String>(
                      //male
                      value: "Male",
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value!;
                        });
                      },
                    ),
                    const Text('Male'),
                    const SizedBox(width: 20),

                    //female
                    Radio<String>(
                      value: "Female",
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value!;
                        });
                      },
                    ),
                    const Text('Female'),
                    const SizedBox(width: 20),

                    //Others
                    Radio<String>(
                      value: "Other",
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value!;
                        });
                      },
                    ),
                    const Text('Other'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),


          //SignIn Button
          ElevatedButton(
            onPressed: () {
              if (_isValidPage(context)) {
                // Navigate to Success Page
                signInController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              }
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
