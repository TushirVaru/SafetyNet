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
    TextEditingController nameController = TextEditingController(
        text: index != null ? forUsCards[index].name : '');
    TextEditingController descController = TextEditingController(
        text: index != null ? forUsCards[index].desc : '');
    TextEditingController deptController = TextEditingController(
        text: index != null ? forUsCards[index].dept : '');
    bool isForUs = index != null ? forUsCards[index].isForUs : true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Center(
            child: Text(
              index == null ? "Add Card" : "Edit Card",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, "Name", Icons.person),
                _buildTextField(descController, "Description", Icons.description),
                _buildTextField(deptController, "Department", Icons.business),
                const SizedBox(height: 10),
                DropdownButtonFormField<bool>(
                  value: isForUs,
                  onChanged: (value) {
                    if (value != null) {
                      isForUs = value;
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: true, child: Text("For You")),
                    DropdownMenuItem(value: false, child: Text("For Others")),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1b1725),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                if (nameController.text.isNotEmpty && deptController.text.isNotEmpty) {
                  setState(() {
                    CardModel card = CardModel(
                        nameController.text, descController.text, deptController.text, isForUs);
                    if (index == null) {
                      if (isForUs) {
                        forUsCards.add(card);
                      } else {
                        forOthersCards.add(card);
                      }
                    } else {
                      if (isForUs) {
                        forUsCards[index] = card;
                      } else {
                        forOthersCards[index] = card;
                      }
                    }
                    saveforUsCards();
                    saveforOthersCards();
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(index == null ? "Add" : "Update", style: const TextStyle(color: Colors.white),),
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
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
      ),
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
          child: PageView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("For You", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
                    const Divider(height: 10, thickness: 2, color: Colors.black,),
                    Expanded(
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

                                              //PopUp for edit and delete options of card
                                              PopupMenuButton<String>(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                elevation: 8,
                                                color: Colors.white,
                                                onSelected: (value) {
                                                  if (value == 'edit') {
                                                    _addOrEditCard(index: index);
                                                  } else if (value == 'delete') {
                                                    _deleteCard(index);
                                                  }
                                                },
                                                itemBuilder: (context) => [
                                                  //Edit Option
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit, color: Colors.blue),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          "Edit",
                                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                        ),
                                                      ],
                                                    )
                                                  ),
                                                  //Delete Option
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete, color: Colors.red),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          "Delete",
                                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                        ),
                                                      ],
                                                    )
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
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("For Others", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
                    const Divider(height: 10, thickness: 2, color: Colors.black,),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 3 / 2,
                        ),
                        itemCount: forOthersCards.length,
                        itemBuilder: (context, index) {

                          final card = forOthersCards[index];

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
                  ],
                )
              ]
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