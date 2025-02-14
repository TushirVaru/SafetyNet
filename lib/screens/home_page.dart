import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late SharedPreferences prefs;
  List<CardModel> cards = [];

  @override
  void initState() {
    super.initState();
    initializeSharedPreference();
  }

  Future<void> initializeSharedPreference() async {
    prefs = await SharedPreferences.getInstance();
    loadCards();
  }

  void loadCards() {
    final storedCards = prefs.getStringList("cards");
    if (storedCards != null) {
      setState(() {
        cards = storedCards.map((e) => CardModel.fromJson(jsonDecode(e))).toList();
      });
    }
  }

  void saveCards() {
    prefs.setStringList("cards", cards.map((e) => jsonEncode(e.toJson())).toList());
  }

  void _addOrEditCard({int? index}) {
    String name = index != null ? cards[index].name : '';
    String desc = index != null ? cards[index].desc : '';
    String dept = index != null ? cards[index].dept : '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? "Add Card" : "Edit Card"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: name),
                onChanged: (value) => name = value,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: TextEditingController(text: desc),
                onChanged: (value) => desc = value,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: TextEditingController(text: dept),
                onChanged: (value) => dept = value,
                decoration: const InputDecoration(labelText: "Department"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty && dept.isNotEmpty) {
                  setState(() {
                    if (index == null) {
                      cards.add(CardModel(name, desc, dept));
                    } else {
                      cards[index] = CardModel(name, desc, dept);
                    }
                    saveCards();
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(index == null ? "Add" : "Update"),
            ),
          ],
        );
      },
    );
  }

  void _deleteCard(int index) {
    setState(() {
      cards.removeAt(index);
      saveCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HomePage"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await prefs.setBool("isLoggedIn", false);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Login()), (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3 / 2,
          ),
          itemCount: cards.length + 1,
          itemBuilder: (context, index) {

            //add icon
            if (index == cards.length) {
              return GestureDetector(
                onTap: () => _addOrEditCard(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.add, size: 40, color: Colors.black54),
                  ),
                ),
              );
            }

            final card = cards[index];

            return GestureDetector(
              onTap: () {
                showConfirmDialog(context);
              },
              child: Card(
                color: const Color(0xFFE3F2FD),
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              card.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 29, fontWeight: FontWeight.bold),
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _addOrEditCard(index: index);
                              } else if (value == 'delete') {
                                _deleteCard(index);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text("Edit"),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text("Delete"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        "Dept: ${card.dept}",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void showConfirmDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Are you sure you want to proceed?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Close dialog
            child: const Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirm action
            child: const Text("Confirm", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

}

// Model class for Card
class CardModel {
  String name;
  String desc;
  String dept;

  CardModel(this.name, this.desc, this.dept);

  Map<String, dynamic> toJson() => {"name": name, "desc": desc, "dept": dept};

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(json["name"], json["desc"], json["dept"]);
  }
}



