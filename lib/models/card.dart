class CardModel {
  String cid;
  String name;
  String desc;
  List<dynamic> dept; // Changed from String to List<String>
  String uid;

  CardModel({
    required this.cid,
    required this.name,
    required this.desc,
    required this.dept,
    required this.uid,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      cid: json["_cid"] ?? '',
      name: json["name"],
      desc: json["description"],
      dept: List<dynamic>.from(json["department"] ?? []),
      uid: json["uid"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": desc,
      "department": dept,
      "uid": uid,
    };
  }
}
