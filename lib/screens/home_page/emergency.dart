import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Emergency extends StatefulWidget {
  const Emergency({super.key});

  @override
  State<Emergency> createState() => EmergencyState();
}

class EmergencyState extends State<Emergency> {
  late SharedPreferences prefs;
  List<CardModel> forUsCards = [];
  List<CardModel> forOthersCards = [];

  @override
  void initState() {
    super.initState();
    initializeSharedPreference();
  }

  Future<void> initializeSharedPreference() async {
    prefs = await SharedPreferences.getInstance();
    loadforUsCards();
    loadforOthersCards();
  }

  void loadforUsCards() {
    final storedforUsCards = prefs.getStringList("forUsCards");
    if (storedforUsCards != null) {
      setState(() {
        forUsCards = storedforUsCards.map((e) => CardModel.fromJson(jsonDecode(e))).toList();
      });
    }
  }

  void loadforOthersCards() {
    final storedforUsCards = prefs.getStringList("forUsCards");
    if (storedforUsCards != null) {
      setState(() {
        forOthersCards = storedforUsCards.map((e) => CardModel.fromJson(jsonDecode(e))).toList();
      });
    }
  }

  void saveforUsCards() {
    prefs.setStringList("forUsCards", forUsCards.map((e) => jsonEncode(e.toJson())).toList());
  }

  void saveforOthersCards() {
    prefs.setStringList("forUsCards", forOthersCards.map((e) => jsonEncode(e.toJson())).toList());
  }

  void _addOrEditCard({int? index}) {
    String name = index != null ? forUsCards[index].name : '';
    String desc = index != null ? forUsCards[index].desc : '';
    String dept = index != null ? forUsCards[index].dept : '';

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
                      forUsCards.add(CardModel(name, desc, dept, true));
                    } else {
                      forUsCards[index] = CardModel(name, desc, dept, true);
                    }
                    saveforUsCards();
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
      forUsCards.removeAt(index);
      saveforUsCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xffF0F0F0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3 / 2,
              ),
              itemCount: forUsCards.length,
              itemBuilder: (context, index) {

                final card = forUsCards[index];

                return SizedBox(
                  child: GestureDetector(
                    onTap: () {
                      showConfirmDialog(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: SizedBox(
                        child: Card(
                          // elevation: 6,
                          color: const Color(0xFFFFFFFF),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Colors.black, width: 1.5)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
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
                                        style: const TextStyle(fontSize: 29, color: Colors.black, fontWeight: FontWeight.bold),
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
                                  style: const TextStyle(fontSize: 17, color: Colors.black),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: SizedBox(
          height: 80,
          width: 80,
          child: FloatingActionButton(
            onPressed: () => _addOrEditCard(),
            backgroundColor: const Color(0xff1b1725),
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 50,),
          ),
        ),
      ),
    );
  }

  void showConfirmDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xfff0f0f0),
        title: const Text("Confirmation", style: TextStyle(fontSize: 25)),
        content: const Text("Are you sure you want to proceed?", style: TextStyle(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Close dialog
            child: const Text("Cancel", style: TextStyle(fontSize: 19, color: Color(0xcf534b62))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirm action
            child: const Text("Confirm", style: TextStyle(fontSize: 19, color: Color(0xff226ce0))),
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
  bool isForUs;

  CardModel(this.name, this.desc, this.dept, this.isForUs);

  Map<String, dynamic> toJson() => {"name": name, "desc": desc, "dept": dept, "isForUs" : isForUs};

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(json["name"], json["desc"], json["dept"], json["isForUs"]);
  }
}