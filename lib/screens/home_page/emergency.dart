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
  String uidId = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializePreference();
  }

  Future<void> initializePreference() async {
    prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString("jwt") ?? "";
    uidId = prefs.getString("uid") ?? "";
    await fetchAndSetCards();
  }

  Future<void> fetchAndSetCards() async {
    int? length;
    setState(() => isLoading = true);

    try {
      //67b01cb1ae66263db4629acf
      final apiUrl = Uri.parse('${dotenv.env['API_URL']}/cards/67b01cb1ae66263db4629acf');
      final response = await http.get(
        apiUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> parsedResponse = jsonDecode(response.body);

        if (parsedResponse["data"] != null && parsedResponse["data"]["doc"] != null) {
          print(""
              "---------------------------\n"
              "Id: ${parsedResponse["data"]["doc"]["_id"]},\n"
              "Name: ${parsedResponse["data"]["doc"]["name"]},\n"
              "Description: ${parsedResponse["data"]["doc"]["description"]},\n"
              "dept: ${parsedResponse["data"]["doc"]["department"]},\n"
              "uid: ${parsedResponse["data"]["doc"]["user"]}\n"
              "---------------------------"
          );
          length = parsedResponse["length"];
          if(length==null){
            setState(() {
              String newCardId = parsedResponse["data"]["doc"]["_id"];

              // Check if card already exists
              bool cardExists = cards.any((card) => card.cid == newCardId);

              if (!cardExists) {
                cards.add(
                  CardModel(
                    cid: newCardId,
                    name: parsedResponse["data"]["doc"]["name"],
                    desc: parsedResponse["data"]["doc"]["description"],
                    dept: parsedResponse["data"]["doc"]["department"],
                    uid: parsedResponse["data"]["doc"]["user"],
                  ),
                );
              }
            });
            isLoading = false;
          }
          else{
            while(length!<0){
              setState(() {
                String newCardId = parsedResponse["data"]["doc"]["_id"];

                // Check if card already exists
                bool cardExists = cards.any((card) => card.cid == newCardId);

                if (!cardExists) {
                  cards.add(
                    CardModel(
                      cid: newCardId,
                      name: parsedResponse["data"]["doc"]["name"],
                      desc: parsedResponse["data"]["doc"]["description"],
                      dept: parsedResponse["data"]["doc"]["department"],
                      uid: parsedResponse["data"]["doc"]["user"],
                    ),
                  );
                }
              });
              length--;
              isLoading = false;
            }
          }

          print("Card is: ${cards.isNotEmpty}");
          if (cards.isNotEmpty) {
            _showUserMessage("Cards successfully loaded");
          } else {
            _showUserMessage("No cards available");
          }
        } else {
          setState(() {
            cards = [];
            isLoading = false;
          });
          _showUserMessage("No cards created yet");
        }
      } else {
        setState(() => isLoading = false);
        _showUserMessage("Server Error: ${response.statusCode}");
      }
    } catch (error) {
      setState(() => isLoading = false);
      _showUserMessage("Failed to load cards");
      print("Error fetching cards: $error");
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
      print("Error adding card: $e");
    }
  }

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
      print("Error updating card: $e");
    }
  }

  Future<void> deleteCard(String cardId) async {
    try {
      final apiUrl = Uri.parse('${dotenv.env['API_URL']}/cards/$cardId');
      final response = await http.delete(
        apiUrl,
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        _showUserMessage("Card deleted successfully!");
        await fetchAndSetCards();
      } else {
        _showUserMessage("Failed to delete card: ${response.statusCode}");
      }
    } catch (e) {
      _showUserMessage("Failed to delete card. Try again.");
      print("Error deleting card: $e");
    }
  }

  void _addOrEditCard({int? index}) {
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
                _buildTextField(nameController, "Name", Icons.person),
                _buildTextField(descController, "Description", Icons.description),
                _buildTextField(
                    deptController,
                    "Departments (comma-separated)",
                    Icons.business
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

                List<dynamic> departments =
                deptController.text.split(',').map((e) => e.trim()).toList();

                CardModel card = CardModel(
                  cid: isEditing ? cards[index].cid : '',
                  name: nameController.text,
                  desc: descController.text,
                  dept: departments,
                  uid: uidId,
                );

                try {
                  if (isEditing) {
                    await updateCard(card);
                  } else {
                    await addCard(card);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  print("Error adding/updating card: $e");
                }
              },
              child: Text(isEditing ? "Update" : "Add"),
            ),
          ],
        );
      },
    ).then((_) {
      // Dispose controllers when dialog is closed
      nameController.dispose();
      descController.dispose();
      deptController.dispose();
    });
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
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
                    onPressed: () => _addOrEditCard(index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteCard(cards[index].cid),
                  ),
                ],
              ),
              onTap: () => _addOrEditCard(index: index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _addOrEditCard(),
      ),
    );
  }
}