class CardModel {
  String cid;
  String name;
  String desc;
  List<String> dept;
  String user;

  static const List<String> validDepartments = [
    'police',
    'medical',
    'fire',
    'women-safety',
    'animal-safety'
  ];

  CardModel({
    required this.cid,
    required this.name,
    required this.desc,
    required List<String> dept, // Ensure it's a List<String>
    required this.user,
  }) : dept = dept.where((d) => validDepartments.contains(d)).toList(); // Filter invalid departments

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      cid: json["_id"] ?? '',
      name: json["name"],
      desc: json["description"],
      dept: List<String>.from(json["department"] ?? [])
          .where((d) => validDepartments.contains(d))
          .toList(),
      user: json["user"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": desc,
      "department": dept, // Already validated in constructor
      "user": user,
    };
  }
}
