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
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();
  final stateController = TextEditingController();
  final pinCodeController = TextEditingController();

  // Page Controllers
  final PageController signInController = PageController();
  final PageController signInSub1Controller = PageController();
  final PageController signInSub2Controller = PageController();
  final PageController signInSub3Controller = PageController();

  String selectedGender = '';
  int isLastPage = 0, isLastSub1Page = 0, isLastSub2Page = 0, isLastSub3Page = 0;

  @override
  void dispose() {
    signInController.dispose();
    signInSub1Controller.dispose();
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
            isLastPage = index;
          });
        },
        children: [

          // Basic Info Page
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: _basicInfo(),
          ),

          // Contact Info Page
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: _contactDetails(),
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
                controller: signInSub1Controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    isLastSub1Page = index; // Check last sub-page
                  });
                },
                children: [

                  //Name Inputs
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          //first Name
                          TextField(
                            controller: firstNameController,
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 15),

                          //Middle Name
                          TextField(
                            controller: middleNameController,
                            decoration: InputDecoration(
                              labelText: 'Middle Name',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 15),

                          //Last Name
                          TextField(
                            controller: lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 15),
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
                          const SizedBox(height: 8),
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
                  ),
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
                      signInSub1Controller.previousPage(
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
                    if (isLastSub1Page == 1) {
                      signInController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    } else {
                      signInSub1Controller.nextPage(
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

  Widget _contactDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Main Heading (Left aligned)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Text(
            'Enter Your Contact Details...',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),

        // Nested PageView inside Center
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: PageView(
                controller: signInSub2Controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    isLastSub2Page = index; // Check last sub-page
                  });
                },
                children: [

                  //Name Inputs
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          //Email
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 15),

                          //Contact details
                          TextField(
                            controller: contactController,
                            decoration: InputDecoration(
                              labelText: 'Contact',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),

                          //Address hading
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Address', ),
                            ],
                          ),
                          Divider(),
                          //Address
                          // Address Field
                          TextField(
                            controller: addressController,
                            minLines: 3,
                            maxLines: null,
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Country and PinCode Fields
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: countryController,
                                  decoration: const InputDecoration(
                                    labelText: 'Country',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: pinCodeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Pincode',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // City and State Fields
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: cityController,
                                  decoration: const InputDecoration(
                                    labelText: 'City',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: stateController,
                                  decoration: const InputDecoration(
                                    labelText: 'State',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),

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
                  ),
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
                      if(isLastSub2Page == 0){
                        signInController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                        signInSub1Controller.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }else {
                        signInSub2Controller.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
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
                    signInController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
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
}