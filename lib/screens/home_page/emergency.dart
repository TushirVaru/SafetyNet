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
  bool isActionLoading = false; // New variable for action-specific loading

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

      if (response.statusCode == 200) {
        Map<String, dynamic> parsedResponse = jsonDecode(response.body);

        if (parsedResponse["data"] != null && (parsedResponse["data"]["docs"] != null || parsedResponse["data"]["doc"] != null)) {
          List<dynamic> cardsList = parsedResponse.length > 1? parsedResponse["data"]["docs"] : parsedResponse["data"]["doc"];

          setState(() {
            cards = cardsList.map((cardData) => CardModel.fromJson(cardData)).toList();
          });

          _showUserMessage("${cards.length} cards successfully loaded");
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
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white, // Text color
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xff1b1725), // Custom background color
          behavior: SnackBarBehavior.floating, // Floating snackbar
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          margin: const EdgeInsets.all(16), // Margin for floating effect
          duration: const Duration(seconds: 3), // Display duration
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white, // Action button color
            onPressed: () {ScaffoldMessenger.of(context).hideCurrentSnackBar();},
          ),
        ),
      );
    }
  }

  Future<void> addCard(CardModel card) async {
    setState(() => isActionLoading = true);

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
    } finally {
      setState(() => isActionLoading = false);
    }
  }

  Future<void> deleteCard(String cardId) async {
    setState(() => isActionLoading = true);

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
    } finally {
      setState(() => isActionLoading = false);
    }
  }

  Future<void> updateCard(CardModel card) async {
    setState(() => isActionLoading = true);

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
    } finally {
      setState(() => isActionLoading = false);
    }
  }

  void addOrEditCard({int? index}) {
    final isEditing = index != null && index >= 0 && index < cards.length;

    final TextEditingController nameController = TextEditingController(
        text: isEditing ? cards[index].name : ''
    );
    final TextEditingController descController = TextEditingController(
        text: isEditing ? cards[index].desc : ''
    );
    String selectedDept = isEditing ? cards[index].dept.first : CardModel.validDepartments.first;
    bool isProcessing = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while processing
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(isEditing ? "Edit Card" : "Add Card"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Name",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        enabled: !isProcessing,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: "Description",
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                        enabled: !isProcessing,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedDept,
                        decoration: const InputDecoration(
                          labelText: "Department",
                          prefixIcon: Icon(Icons.business),
                          border: OutlineInputBorder(),
                        ),
                        items: CardModel.validDepartments.map((String department) {
                          return DropdownMenuItem<String>(
                            value: department,
                            child: Text(department.split('-').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')),
                          );
                        }).toList(),
                        onChanged: isProcessing ? null : (String? newValue) {
                          if (newValue != null) {
                            setDialogState(() => selectedDept = newValue);
                          }
                        },
                      ),
                      if (isProcessing)
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isProcessing ? null : () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () async {
                      if (nameController.text.isEmpty) {
                        _showUserMessage("Name is required");
                        return;
                      }

                      setDialogState(() => isProcessing = true);

                      CardModel card = CardModel(
                        cid: isEditing ? cards[index].cid : '',
                        name: nameController.text,
                        desc: descController.text,
                        dept: [selectedDept],
                        user: userId,
                      );

                      if (isEditing) {
                        await updateCard(card);
                      } else {
                        await addCard(card);
                      }

                      Navigator.pop(dialogContext);
                    },
                    child: Text(isEditing ? "Update" : "Add"),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  void showDeleteConfirmation(String cardId, String cardName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: Text("Are you sure you want to delete the card '$cardName'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                deleteCard(cardId);
              },
              child: const Text("Delete"),
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
            onPressed: isLoading || isActionLoading ? null : fetchAndSetCards,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (cards.isEmpty)
            const Center(
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
          else
            ListView.builder(
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      cards[index].name[0].toUpperCase() + cards[index].name.substring(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (cards[index].desc.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(cards[index].desc[0].toUpperCase() + cards[index].desc.substring(1)),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "Department: ${cards[index].dept.join(', ').split('-').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')}",
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
                          onPressed: isActionLoading ? null : () => addOrEditCard(index: index),
                          tooltip: "Edit",
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: isActionLoading ? null : () => showDeleteConfirmation(cards[index].cid, cards[index].name),
                          tooltip: "Delete",
                        ),
                      ],
                    ),
                    onTap: () => {},
                  ),
                );
              },
            ),

          // Overlay loading indicator for actions
          if (isActionLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading || isActionLoading ? null : () => addOrEditCard(),
        disabledElevation: 0,
        child: const Icon(Icons.add),
      ),
    );
  }

}