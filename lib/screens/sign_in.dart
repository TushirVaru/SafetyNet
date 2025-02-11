import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // Controllers for input fields
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dateController = TextEditingController();
  final ageController = TextEditingController();

  // Page Controllers
  final PageController signInController = PageController();
  final PageController signInSubController = PageController();

  String selectedGender = '';
  bool isLastPage = false;
  bool isLastSubPage = false;

  @override
  void dispose() {
    signInController.dispose();
    signInSubController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: signInController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            isLastPage = (index == 1); // Checking if last main page
          });
        },
        children: [

          // Basic Info Page
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: _basicInfo(),
          ),

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
                const Text('You are now Registered.', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Go to Login Page"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _basicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Main Heading (Left aligned)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Text(
            'Enter Your Basic Details...',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),

        // Nested PageView inside Center
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: PageView(
                controller: signInSubController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    isLastSubPage = (index == 1); // Check last sub-page
                  });
                },
                children: [

                  //Name Inputs
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _customTextField(firstNameController, 'First Name'),
                          const SizedBox(height: 15),
                          _customTextField(middleNameController, 'Middle Name'),
                          const SizedBox(height: 15),
                          _customTextField(lastNameController, 'Last Name'),
                        ],
                      ),
                    ),
                  ),

                  // First Sub Page - DOB, Gender
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Date of Birth Field
                          TextField(
                            controller: dateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Date of Birth',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );

                                  if (pickedDate != null) {
                                    setState(() {
                                      dateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";

                                      // Calculate Age
                                      DateTime today = DateTime.now();
                                      int age = today.year - pickedDate.year;
                                      if (today.month < pickedDate.month ||
                                          (today.month == pickedDate.month && today.day < pickedDate.day)) {
                                        age--;
                                      }
                                      ageController.text = age.toString();
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Age Field
                          TextField(
                            controller: ageController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Gender Selection
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Gender:', style: TextStyle(fontSize: 16)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Radio<String>(
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
                        ],
                      ),
                    ),
                  ), // Second Sub Page
                ],
              ),
            ),
          ),
        ),

        //Previous Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Align(
                  child: ElevatedButton(
                    onPressed: () {
                      signInSubController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    child: const Text('Previous'),
                  ),
                ),
              ),
            ),

            // Next Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Align(
                child: ElevatedButton(
                  onPressed: () {
                    if (isLastSubPage) {
                      signInController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    } else {
                      signInSubController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  child: const Text('Next'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Custom Input Field Widget
  Widget _customTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
