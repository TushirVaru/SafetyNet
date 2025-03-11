class CardModel {
  String cid;
  String name;
  String desc;
  List<dynamic> dept; // Changed from String to List<String>
  String user;

  CardModel({
    required this.cid,
    required this.name,
    required this.desc,
    required this.dept,
    required this.user,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      cid: json["_cid"] ?? '',
      name: json["name"],
      desc: json["description"],
      dept: List<dynamic>.from(json["department"] ?? []),
      user: json["user"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": desc,
      "department": dept,
      "user": user,
    };
  }
}
