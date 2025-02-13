import 'package:flutter/material.dart';
import '../services/verhoeff.dart';

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
  final aadhaarController = TextEditingController();
  final healthCondition = TextEditingController();
  final healthAllergy = TextEditingController();
  final healthSurgeries = TextEditingController();
  final healthMedications = TextEditingController();


  // Page Controllers
  final PageController signInController = PageController();
  final PageController signInSub1Controller = PageController();
  final PageController signInSub2Controller = PageController();
  final PageController signInSub3Controller = PageController();
  final PageController signInSub4Controller = PageController();

  String selectedGender = '', aadhaarError = "", selectedBloodType = 'A', selectedRHFactor = '+';
  int mainPageIndex = 0, subPage1Index = 0, subPage2Index = 0, subPage3Index = 0;

  final List<String> bloodType = [
    'A', 'B', 'O', 'AB'
  ];final List<String> bloodRHFactor = [
    '+', '-'
  ];
  final List<Map<String, String>> contacts = [];
  final List<Map<String, String>> health = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SignUp", style: TextStyle(),),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: signInController,
              // physics: const NeverScrollableScrollPhysics(),
              children: [

                // Basic Info Page
                _basicInfo(),

                // Contact Info Page
                _contactDetails(),

                // Identity Info Page
                _identityDetails(),

                // Health Info Page
                _healthDetails(),

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

        // PageView
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: PageView(
                controller: signInSub1Controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [

                  // Name Inputs
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          TextField(
                            controller: firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 15),

                          TextField(
                            controller: middleNameController,
                            decoration: const InputDecoration(
                              labelText: 'Middle Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 15),

                          TextField(
                            controller: lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),

                  // DOB, Gender & Age field
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          // DOB Field
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

        // Previous & Next Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  signInSub1Controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                },
                child: const Text('Previous'),
              ),
            ),

            // Next Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  if (signInSub1Controller.hasClients && signInSub1Controller.page != null && signInSub1Controller.page! >= 1) {
                    signInController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                  } else {
                    signInSub1Controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                  }
                },
                child: const Text('Next'),
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
                children: [

                  //Email, Contact and address Inputs
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          //Email
                          TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 15),

                          //Contact details
                          TextField(
                            controller: contactController,
                            decoration: const InputDecoration(
                              labelText: 'Contact',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
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
                                    labelText: 'Pin Code',
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
                ],
              ),
            ),
          ),
        ),



        // Previous & Next Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  signInController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                },
                child: const Text('Previous'),
              ),
            ),

            // Next Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  signInController.nextPage(duration: const Duration(microseconds: 300), curve: Curves.easeIn);
                },
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _identityDetails() {
    String? phoneError;
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    void showAddContactDialog() {

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Add Emergency Contact'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: const OutlineInputBorder(),
                        errorText: phoneError,
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                            phoneError = null; // Valid input
                          } else {
                            phoneError = "Enter a valid 10-digit number"; // Error message
                          }
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty && phoneError == null) {
                        setState(() {
                          contacts.add({
                            'name': nameController.text,
                            'phone': phoneController.text,
                          });
                        });
                        nameController.clear();
                        phoneController.clear();
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    void showDeleteDialog(int index) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Contact'),
          content: const Text('Are you sure you want to delete this emergency contact?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  contacts.removeAt(index);
                });
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Text(
            'Enter Your Identity Details...',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: PageView(
                controller: signInSub3Controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // Aadhaar
                          TextField(
                            controller: aadhaarController,
                            keyboardType: TextInputType.number,
                            maxLength: 12,
                            decoration: InputDecoration(
                              labelText: 'Aadhaar Card Number',
                              border: const OutlineInputBorder(),
                              errorText: aadhaarError.isNotEmpty ? aadhaarError : null,
                            ),
                            onChanged: (value) {
                              if (value.length == 12) {
                                setState(() {
                                  aadhaarError = Verhoeff.validateAadhaar(value) ? "" : "❌ Invalid Aadhaar Number";
                                });
                              } else {
                                setState(() {
                                  aadhaarError = "";
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 20),

                          // Emergency Contacts Section
                          const Text(
                            'Emergency Contact',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: contacts.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            contacts[index]['name'] ?? '',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            " ${contacts[index]['phone'] ?? ''}", // Default to an empty string
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton(
                                      icon: const Icon(Icons.more_vert, color: Colors.black), // Fixed color issue
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          showDeleteDialog(index);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          // Add button
                          Center(
                            child: TextButton.icon(
                              onPressed: showAddContactDialog,
                              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                              label: const Text('Add Another Emergency Contact'),
                            ),
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

        // Previous & Next Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  signInController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
                child: const Text('Previous'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
          ],
        ),
      ],
    );
  }

  Widget _healthDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Text(
            'Enter Your Health Details...',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: PageView(
                controller: signInSub3Controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Text(
                            'Blood Group',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),

                          //Blood Group
                          Row(
                            children: [

                              // Blood Type Dropdown
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedBloodType,
                                  decoration: const InputDecoration(
                                    labelText: 'Blood Type',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: bloodType.map((String type) {
                                    return DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedBloodType = newValue ?? 'A';
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),

                              // RH Factor Dropdown
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedRHFactor,
                                  decoration: const InputDecoration(
                                    labelText: 'RH Factor',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: bloodRHFactor.map((String factor) {
                                    return DropdownMenuItem<String>(
                                      value: factor,
                                      child: Text(factor),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedRHFactor = newValue ?? '+';
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Emergency Contacts Section
                          const Text(
                            'Health History',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),

                          //Condition
                          const Text('Condition', style: TextStyle(fontSize: 18)),
                          TextField(
                            controller: healthCondition,
                            decoration: const InputDecoration(
                              hintText: 'If any?',
                            ),
                          ),
                          const SizedBox(height: 20),

                          //Condition
                          const Text('Allergies', style: TextStyle(fontSize: 18)),
                          TextField(
                            controller: healthAllergy,
                            decoration: const InputDecoration(
                              hintText: 'If any?',
                            ),
                          ),
                          const SizedBox(height: 20),

                          //Condition
                          const Text('Surgeries', style: TextStyle(fontSize: 18)),
                          TextField(
                            controller: healthSurgeries,
                            decoration: const InputDecoration(
                              hintText: 'If any?',
                            ),
                          ),
                          const SizedBox(height: 20),

                          //Condition
                          const Text('Medications', style: TextStyle(fontSize: 18)),
                          TextField(
                            controller: healthMedications,
                            decoration: const InputDecoration(
                              hintText: 'If any?',
                            ),
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

        // Previous & Next Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  signInController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
                child: const Text('Previous'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
          ],
        ),
      ],
    );
  }
}