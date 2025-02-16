import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(EmergencyApp());

class EmergencyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Emergency(),
    );
  }
}

class CardModel {
  String id;
  String name;
  String desc;
  String dept;
  String uid;

  CardModel({required this.id, required this.name, required this.desc, required this.dept, required this.uid});

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json["_id"] ?? '',
      name: json["name"],
      desc: json["description"],
      dept: json["department"].isNotEmpty ? json["department"][0] : '',
      uid: json["user"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": desc,
      "department": [dept],
      "user": uid,
    };
  }
}

class Emergency extends StatefulWidget {
  @override
  _EmergencyState createState() => _EmergencyState();
}

class _EmergencyState extends State<Emergency> {
  late SharedPreferences prefs;
  List<CardModel> forUsCards = [];
  String authToken = "";
  String userId = "";
  final String apiUrl = "https://safetynet-phi.vercel.app/api/v1/users/cards";

  @override
  void initState() {
    super.initState();
    initializePreference();
    fetchAndSetCards();
  }

  void initializePreference() async{
    prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString("jwt")!;
    userId = prefs.getString("uid")!;

  }

  Future<void> fetchAndSetCards() async {
    try {
      print("------------------------------------------In Try");
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json", 'Authorization': 'Bearer $authToken'},
      );

      final paresedResponce = jsonDecode(response.body);
      print("------------------------------------------parsedResponce: ${paresedResponce}");
      if (paresedResponce["status"]=="success") {
        print("------------------------------------------In success");
        List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          forUsCards = jsonData.map((item) => CardModel.fromJson(item)).toList();
        });
      } else {
        throw Exception("Failed to load cards");
      }
    } catch (error) {
      print("Error fetching cards: $error");
    }
  }

  Future<void> addCard(CardModel card) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(card.toJson()),
    );

    if (response.statusCode == 201) {
      fetchAndSetCards();
    } else {
      throw Exception("Failed to add card");
    }
  }

  Future<void> deleteCard(String cardId) async {
    final response = await http.delete(
      Uri.parse("$apiUrl/$cardId"),
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 200) {
      fetchAndSetCards();
    } else {
      throw Exception("Failed to delete card");
    }
  }

  void _addOrEditCard({int? index}) {
    TextEditingController nameController = TextEditingController(text: index != null ? forUsCards[index].name : '');
    TextEditingController descController = TextEditingController(text: index != null ? forUsCards[index].desc : '');
    TextEditingController deptController = TextEditingController(text: index != null ? forUsCards[index].dept : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? "Add Card" : "Edit Card"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, "Name", Icons.person),
              _buildTextField(descController, "Description", Icons.description),
              _buildTextField(deptController, "Department", Icons.business),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && deptController.text.isNotEmpty) {
                  CardModel newCard = CardModel(
                    id: index != null ? forUsCards[index].id : '',
                    name: nameController.text,
                    desc: descController.text,
                    dept: deptController.text,
                    uid: userId,
                  );

                  try {
                    if (index == null) {
                      await addCard(newCard);
                    } else {
                      await deleteCard(forUsCards[index].id);
                      await addCard(newCard);
                    }
                    Navigator.pop(context);
                  } catch (e) {
                    print("Error adding/updating card: $e");
                  }
                }
              },
              child: Text(index == null ? "Add" : "Update"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void _deleteCard(int index) async {
    try {
      await deleteCard(forUsCards[index].id);
    } catch (e) {
      print("Error deleting card: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Emergency Contacts")),
      body: ListView.builder(
        itemCount: forUsCards.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(forUsCards[index].name),
            subtitle: Text(forUsCards[index].desc),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteCard(index),
            ),
            onTap: () => _addOrEditCard(index: index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addOrEditCard(),
      ),
    );
  }

}
