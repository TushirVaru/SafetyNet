import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/card.dart';

class Emergency extends StatefulWidget {
  const Emergency({super.key});

  @override
  EmergencyState createState() => EmergencyState();
}

class EmergencyState extends State<Emergency> {
  late SharedPreferences prefs;
  List<CardModel> cards = [];
  String authToken = "";
  String userId = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializePreference();
  }

  Future<void> initializePreference() async {
    prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString("jwt") ?? "";
    userId = prefs.getString("uid") ?? "";
    await fetchAndSetCards();
  }

  Future<void> fetchAndSetCards() async {
    setState(() => isLoading = true);
    cards = [];

    try {
      final apiUrl = Uri.parse('${dotenv.env['API_URL']}/cards?user=$userId');
      final response = await http.get(
        apiUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
      );

      print("AuthToken: $authToken");
      print("user: $userId");

      if (response.statusCode == 200) {
        Map<String, dynamic> parsedResponse = jsonDecode(response.body);

        if (parsedResponse["data"] != null && parsedResponse["data"]["docs"] != null) {
          List<dynamic> cardsList = parsedResponse["data"]["docs"];

          for (var cardData in cardsList) {
            String cardId = cardData["_id"];

            setState(() {
              cards.add(
                CardModel(
                  cid: cardId,
                  name: cardData["name"],
                  desc: cardData["description"],
                  dept: List<dynamic>.from(cardData["department"]),
                  user: cardData["user"],
                ),
              );
            });
          }

          if (cards.isNotEmpty) {
            _showUserMessage("${cards.length} cards successfully loaded");
          } else {
            _showUserMessage("No cards available");
          }
        } else {
          _showUserMessage("No cards created yet");
        }
      } else {
        _showUserMessage("Server Error: ${response.statusCode}");
      }
    } catch (error) {
      _showUserMessage("Failed to load cards");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showUserMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> addCard(CardModel card) async {
    try {
      final apiUrl = Uri.parse('${dotenv.env['API_URL']}/cards');
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(card.toJson()),
      );

      if (response.statusCode == 201) {
        _showUserMessage("Card added successfully!");
        await fetchAndSetCards();
      } else {
        _showUserMessage("Failed to add card: ${response.statusCode}");
      }
    } catch (e) {
      _showUserMessage("Failed to add card! Try again.");
    }
  }

  //Function To Update Card
  Future<void> updateCard(CardModel card) async {
    try {
      final apiUrl = Uri.parse("${dotenv.env['API_URL']}/cards/${card.cid}");
      final response = await http.patch(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(card.toJson()),
      );

      if (response.statusCode == 200) {
        _showUserMessage("Card updated successfully!");
        await fetchAndSetCards();
      } else {
        _showUserMessage("Failed to update card: ${response.statusCode}");
      }
    } catch (e) {
      _showUserMessage("Failed to update card. Try again.");
    }
  }

  //To Delete Card
  Future<void> deleteCard(String cardId) async {
    try {
      final apiUrl = Uri.parse('${dotenv.env['API_URL']}/cards/$cardId');
      final response = await http.delete(
        apiUrl,
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 204) {
        _showUserMessage("Card deleted successfully!");
        await fetchAndSetCards();
      } else {
        _showUserMessage("Failed to delete card: ${response.statusCode}");
      }
    } catch (e) {
      _showUserMessage("Failed to delete card. Try again.");
    }
  }

  //To Add Or Edit Card
  void addOrEditCard({int? index}) {
    final isEditing = index != null && index >= 0 && index < cards.length;

    final TextEditingController nameController = TextEditingController(
        text: isEditing ? cards[index].name : ''
    );
    final TextEditingController descController = TextEditingController(
        text: isEditing ? cards[index].desc : ''
    );
    final TextEditingController deptController = TextEditingController(
        text: isEditing ? cards[index].dept.join(', ') : ''
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? "Edit Card" : "Add Card"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //Name
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                //Description
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                //Departments
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: deptController,
                    decoration: const InputDecoration(
                      labelText: "Departments",
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || deptController.text.isEmpty) {
                  _showUserMessage("Name and Department are required");
                  return;
                }

                List<dynamic> departments = ["police"];
                // deptController.text.split(',').map((e) => e.trim()).toList();


                CardModel card = CardModel(
                  cid: isEditing ? cards[index].cid : '',
                  name: nameController.text,
                  desc: descController.text,
                  dept: departments,
                  user: userId,
                );
                try {
                  if (isEditing) {
                    await updateCard(card);
                  } else {
                    await addCard(card);
                  }

                  Navigator.pop(context);
                } catch (e) {
                }
              },
              child: Text(isEditing ? "Update" : "Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Cards"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchAndSetCards,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cards.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No cards created yet!",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            Text(
              "Create one by clicking the + button",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                cards[index].name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (cards[index].desc.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(cards[index].desc),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Departments: ${cards[index].dept.join(', ')}",
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => addOrEditCard(index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteCard(cards[index].cid),
                  ),
                ],
              ),
              onTap: () => addOrEditCard(index: index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => addOrEditCard(),
      ),
    );
  }
}