import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/ProfileModel.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  late SharedPreferences prefs;
  bool isEditing = false;
  String authToken = "";
  String userId = "";
  ProfileModel? userProfile; // Store user profile data
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;  // Add loading state
  String? errorMessage;   // Add error message state

  // Controllers for text fields
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController adhaarController = TextEditingController();
  final TextEditingController bloodController = TextEditingController();
  final TextEditingController pastDiseaseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializePreference();
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    fullNameController.dispose();
    emailController.dispose();
    addressController.dispose();
    mobileController.dispose();
    genderController.dispose();
    adhaarController.dispose();
    bloodController.dispose();
    pastDiseaseController.dispose();
    super.dispose();
  }

  Future<void> initializePreference() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      prefs = await SharedPreferences.getInstance();
      authToken = prefs.getString("jwt") ?? "";
      userId = prefs.getString("uid") ?? "";

      if (authToken.isEmpty || userId.isEmpty) {
        setState(() {
          errorMessage = "Authentication failed. Please log in again.";
          isLoading = false;
        });
        return;
      }

      await fetchProfile();
    } catch (e) {
      setState(() {
        errorMessage = "Failed to initialize: $e";
        isLoading = false;
      });
    }
  }

  Future<void> fetchProfile() async {
    try {
      final apiUrl = Uri.parse("${dotenv.env['API_URL']}/users/me");
      final response = await http.get(
        apiUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody["data"] != null && responseBody["data"]["user"] != null) {
          final data = responseBody["data"]["user"];
          setState(() {
            userProfile = ProfileModel.fromJson(data);
            fullNameController.text = userProfile?.fullName ?? "";
            emailController.text = userProfile?.email ?? "";
            addressController.text = userProfile?.address ?? "";
            mobileController.text = userProfile?.mobile?.toString() ?? "";
            genderController.text = userProfile?.gender ?? "";
            adhaarController.text = userProfile?.adhaar?.toString() ?? "";
            bloodController.text = userProfile?.blood ?? "";
            pastDiseaseController.text = userProfile?.pastDisease ?? "";
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "Invalid data format from server";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Error ${response.statusCode}: ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to fetch profile: $e";
        isLoading = false;
      });
    }
  }

  Future<void> updateProfile() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final apiUrl = Uri.parse("${dotenv.env['API_URL']}/users/$userId");
      final response = await http.patch(
        apiUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode({
          "fullName": fullNameController.text,
          "email": emailController.text,
          "address": addressController.text,
          "mobile": int.tryParse(mobileController.text) ?? 0,
          "gender": genderController.text,
          "adhaar": int.tryParse(adhaarController.text) ?? 0,
          "blood": bloodController.text,
          "pastDisease": pastDiseaseController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          isEditing = false;
        });
        await fetchProfile();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
      } else {
        setState(() {
          errorMessage = "Error updating profile: ${response.statusCode}, ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to update profile: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0x151b1725),
        actions: [
          if (!isLoading && userProfile != null)
            IconButton(
              icon: Icon(isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (isEditing) {
                  if (_formKey.currentState!.validate()) {
                    updateProfile();
                  }
                } else {
                  setState(() {
                    isEditing = true;
                  });
                }
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: initializePreference,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (userProfile == null) {
      return const Center(
        child: Text("No profile data available"),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isEditing ? buildEditForm() : buildProfileView(),
    );
  }

  Widget buildProfileView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profileItem("Full Name", userProfile!.fullName),
          profileItem("Email", userProfile!.email),
          profileItem("Address", userProfile!.address),
          profileItem("Mobile", userProfile!.mobile?.toString() ?? "Not available"),
          profileItem("Gender", userProfile!.gender),
          profileItem("Adhaar", userProfile!.adhaar?.toString() ?? "Not available"),
          profileItem("Blood Group", userProfile!.blood),
          profileItem("Past Disease", userProfile!.pastDisease),
          const SizedBox(height: 16),
          const Text("Emergency Contacts:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          if (userProfile!.emergencyContact.isEmpty)
            const Text("No emergency contacts added", style: TextStyle(fontStyle: FontStyle.italic)),
          for (var contact in userProfile!.emergencyContact)
            profileItem("${contact.name}", "Mobile: ${contact.mobile}"),
        ],
      ),
    );
  }

  Widget buildEditForm() {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          buildTextField("Full Name", fullNameController),
          buildTextField("Email", emailController),
          buildTextField("Address", addressController),
          buildTextField("Mobile", mobileController, isNumeric: true),
          buildTextField("Gender", genderController),
          buildTextField("Adhaar", adhaarController, isNumeric: true),
          buildTextField("Blood Group", bloodController),
          buildTextField("Past Disease", pastDiseaseController),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                updateProfile();
              }
            },
            child: const Text("Update Profile"),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label cannot be empty";
          }
          return null;
        },
      ),
    );
  }

  Widget profileItem(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? "Not available")),
        ],
      ),
    );
  }
}