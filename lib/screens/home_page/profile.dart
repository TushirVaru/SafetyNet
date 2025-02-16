import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic> userData = {
    "fullName": "John William Smith",
    "email": "john.smith@gmail.com",
    "dateOfBirth": "1995-02-14",
    "address": "Delhi, India",
    "mobile": "9876656566",
    "gender": "Male",
    "aadhaar": "652347893145",
    "emergencyContact": [
      {"name": "Jane Smith", "mobile": "9876656568"}
    ],
    "blood": "A+",
    "pastDisease": "None",
    "role": "User",
    "department": "Fire",
    "age": 30
  };

  bool isEditing = false;
  Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    userData.forEach((key, value) {
      controllers[key] = TextEditingController(text: value.toString());
    });
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  // Function to update user data in the database
  void updateProfileData() async {
    final url = Uri.parse('https://safetynet-phi.vercel.app/api/v1/users/update-info');

    try {
      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": userData["email"],
          "fullName": controllers["fullName"]?.text ?? "",
          "dateOfBirth": controllers["dateOfBirth"]?.text ?? "",
          "address": controllers["address"]?.text ?? "",
          "mobile": controllers["mobile"]?.text ?? "",
          "gender": controllers["gender"]?.text ?? "",
          "aadhaar": controllers["aadhaar"]?.text ?? "",
          "emergencyContacts": userData["emergencyContact"],
          "bloodType": controllers["blood"]?.text ?? "",
          "healthCondition": controllers["pastDisease"]?.text ?? "",
          "role": controllers["role"]?.text ?? "",
          "department": controllers["department"]?.text ?? ""
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully!")),
        );
        setState(() {
          isEditing = false;
        });
      } else {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData["message"] ?? "Update failed!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        elevation: 6,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                updateProfileData(); // Save updated data
              }
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                      'https://safetynet-phi.vercel.app/img/users/default.jpg'),
                ),
              ),
              const SizedBox(height: 16),
              buildProfileItem("Full Name", "fullName"),
              buildProfileItem("Email", "email", isEditable: false), // Email should not be editable
              buildProfileItem("Date of Birth", "dateOfBirth"),
              buildProfileItem("Age", "age", isEditable: false),
              buildProfileItem("Address", "address"),
              buildProfileItem("Mobile", "mobile"),
              buildProfileItem("Gender", "gender"),
              buildProfileItem("Aadhaar", "aadhaar"),
              buildProfileItem("Blood Type", "blood"),
              buildProfileItem("Past Disease", "pastDisease"),
              buildProfileItem("Role", "role"),
              buildProfileItem("Department", "department"),
              const SizedBox(height: 16),
              const Text("Emergency Contacts:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Column(
                children: List.generate(
                  userData["emergencyContact"].length,
                      (index) => buildEmergencyContactItem(index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileItem(String title, String key, {bool isEditable = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          isEditing && isEditable
              ? SizedBox(
            width: 150,
            child: TextField(
              controller: controllers[key],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  userData[key] = value;
                });
              },
            ),
          )
              : Text(userData[key].toString(), style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget buildEmergencyContactItem(int index) {
    TextEditingController nameController =
    TextEditingController(text: userData["emergencyContact"][index]["name"]);
    TextEditingController mobileController =
    TextEditingController(text: userData["emergencyContact"][index]["mobile"]);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isEditing
              ? Expanded(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: "Name",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      userData["emergencyContact"][index]["name"] = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: mobileController,
                  decoration: const InputDecoration(
                    hintText: "Mobile",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      userData["emergencyContact"][index]["mobile"] = value;
                    });
                  },
                ),
              ],
            ),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userData["emergencyContact"][index]["name"], style: const TextStyle(fontSize: 16)),
              Text(userData["emergencyContact"][index]["mobile"], style: const TextStyle(fontSize: 16)),
            ],
          ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () {
                setState(() {
                  userData["emergencyContact"].removeAt(index);
                });
              },
            ),
        ],
      ),
    );
  }
}
