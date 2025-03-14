import 'package:SafetyNet/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/verhoeff.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();


  // Page Controllers
  final PageController signInController = PageController();

  String selectedGender = '', aadhaarError = "", selectedBloodType = 'A', selectedRHFactor = '+';
  int mainPageIndex = 0, subPage1Index = 0, subPage2Index = 0, subPage3Index = 0, currentPage = 0;
  bool _obscurePassword = true, _obscureConfirmPassword = true;
  String? _passwordError;
  String? _confirmPasswordError;

  final List<Map<String, String>> contacts = [];
  final List<String> bloodType = [
    'A', 'B', 'O', 'AB'
  ];final List<String> bloodRHFactor = [
    '+', '-'
  ];

  //confirm pop up
  void _showConfirmation(){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Registration'),
        content: const Text('Are you sure you want to Submit you details?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => submitData(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff1b1725),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  void submitData(BuildContext context) async {
    final apiUrl = Uri.parse('${dotenv.env['API_URL']}/users/signup');

    final Map<String, dynamic> data = {
      "fullName": "${firstNameController.text}  ${middleNameController.text}  ${lastNameController.text}",
      "email": emailController.text,
      "dateOfBirth": "1967-12-11T00:00:00Z",
      "password": passwordController.text,
      "passwordConfirm": confirmPasswordController.text,
      "address": "${addressController.text}, ${cityController.text}, ${stateController.text}, ${countryController.text} ",
      "mobile": int.tryParse(contactController.text),
      "gender": selectedGender.toLowerCase(),
      "aadhaar": aadhaarController.text,
      "emergencyContacts": contacts,
      "bloodType": "$selectedBloodType$selectedRHFactor",
      "healthCondition": "Condition: ${healthCondition.text}\nAllergy: ${healthAllergy.text}\nSurgeries: ${healthSurgeries.text}\nMedication: ${healthMedications.text}",
    };

    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json",},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup successful!")),
        );
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

    signInController.nextPage(duration: const Duration(microseconds: 300), curve: Curves.easeIn);
    Navigator.pop(context);
  }

  //validator
  bool _isValid() {
    switch (currentPage) {
      case 0: // Page 1: Personal Details
        return firstNameController.text.isNotEmpty &&
            lastNameController.text.isNotEmpty &&
            dateController.text.isNotEmpty &&
            selectedGender.isNotEmpty;

      case 1: // Page 2: Contact Details
        return emailController.text.isNotEmpty &&
            contactController.text.isNotEmpty &&
            addressController.text.isNotEmpty &&
            countryController.text.isNotEmpty &&
            pinCodeController.text.isNotEmpty &&
            cityController.text.isNotEmpty &&
            stateController.text.isNotEmpty;

      case 2: // Page 3: Aadhaar & Emergency Contact
        return aadhaarController.text.isNotEmpty &&
            contacts.isNotEmpty &&
            aadhaarError.isEmpty;

      case 3: // Page 4: Blood Group
        return selectedBloodType.isNotEmpty &&
            selectedRHFactor.isNotEmpty;

      case 4: // Page 5: Password
        return passwordController.text.isNotEmpty &&
            confirmPasswordController.text.isNotEmpty &&
            passwordController.text == confirmPasswordController.text;

      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff1b1725),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("SignUp", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
              onPressed: (){
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()), (route) => false,
                );
              }, child: const Text("Already Registered?", style: TextStyle(color: Colors.white)))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: signInController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              children: [
                _basicInfo(),
                _contactDetails(),
                _identityDetails(),
                _healthDetails(),
                _securityDetails(),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1b1725),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Login()),
                          );
                        },
                        child: const Text("Go to Login Page", style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Button
                ElevatedButton(
                  onPressed: () {
                    signInController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1b1725),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, size: 18),
                        SizedBox(width: 8),
                        Text('Previous', style: TextStyle(color: Colors.white),),
                      ],
                    ),
                  ),

                  // Indicator
                  Row(
                    children: List.generate(
                      5, // Updated from 4 → 5 because there are 5 pages before confirmation
                          (index) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: dotIndicator(index == currentPage),
                      ),
                    ),
                  ),

                  // Next button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1b1725),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: () {
                      if (_isValid()) {
                        if (currentPage < 4) {
                          signInController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        } else {
                          _showConfirmation();
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please fill all required fields correctly"),
                            backgroundColor: Colors.red,
                            duration: Duration(milliseconds: 2500),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(currentPage == 4 ? 'Confirm' : 'Next', style: const TextStyle(color: Colors.white),),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
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
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Text(
            'Enter Your Basic Details...',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),

        // Main Content - Wrapped in Expanded
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  //Name fields
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

                  //DOB
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

                  //Age Field
                  TextField(
                    controller: ageController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),


                  //gender
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 12.0),
                        child: Text('Gender:', style: TextStyle(fontSize: 18)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [

                          Row(
                            children: [
                              Radio<String>(
                                value: "male",
                                groupValue: selectedGender,
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value!;
                                  });
                                },
                              ),
                              const Text('Male'),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Row(
                            children: [
                              Radio<String>(
                                value: "female",
                                groupValue: selectedGender,
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value!;
                                  });
                                },
                              ),
                              const Text('Female'),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Row(
                            children: [
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _contactDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Main Heading
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Text(
            'Enter Your Contact Details...',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),

        //content
        Expanded(
          child: SingleChildScrollView(
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
            builder: (context, setDialogState) {
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
                        setDialogState(() {
                          phoneError = RegExp(r'^[0-9]{10}$').hasMatch(value)
                              ? null
                              : "Enter a valid 10-digit number";
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
                      if (nameController.text.isNotEmpty &&
                          phoneController.text.isNotEmpty &&
                          phoneError == null) {
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Aadhaar Card Input
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
                      setState(() {
                        aadhaarError = value.length == 12 && !Verhoeff.validateAadhaar(value)
                            ? "❌ Invalid Aadhaar Number"
                            : "";
                      });
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
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
                                    " ${contacts[index]['phone'] ?? ''}",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton(
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.black),
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
                      icon: const Icon(Icons.add_circle_outline,
                          color: Colors.green),
                      label: const Text('Add Another Emergency Contact'),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          child: SingleChildScrollView(
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
        ),
      ],
    );
  }

  Widget _securityDetails() {
    void validatePasswords() {
      setState(() {
        // Reset error states first
        _passwordError = null;
        _confirmPasswordError = null;

        // Check if passwords are empty
        if (passwordController.text.isEmpty) {
          _passwordError = "Password is required";
        }
        if (confirmPasswordController.text.isEmpty) {
          _confirmPasswordError = "Confirm password is required";
        }

        // Check if passwords match only if both fields are filled
        if (passwordController.text.isNotEmpty &&
            confirmPasswordController.text.isNotEmpty) {
          if (passwordController.text != confirmPasswordController.text) {
            _passwordError = "Passwords do not match";
            _confirmPasswordError = "Passwords do not match";
          }
        }
      });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Text(
            'Enter Your Security Details...',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Password Field
                    const Text('Password', style: TextStyle(fontSize: 18)),
                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      onChanged: (_) => validatePasswords(),
                      decoration: InputDecoration(
                        errorText: _passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password Field
                    const Text('Confirm Password', style: TextStyle(fontSize: 18)),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      onChanged: (_) => validatePasswords(),
                      decoration: InputDecoration(
                        errorText: _confirmPasswordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  dotIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(microseconds: 300),
      height: isActive? 15 : 6,
      width: 4,
      decoration: isActive
          ?const BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(12))
      )
      :const BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(12))
      ),
    );
  }
}