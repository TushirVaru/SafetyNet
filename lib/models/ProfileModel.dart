import 'dart:convert';

class ProfileModel {
  final String photo;
  final String id;
  final String fullName;
  final String email;
  final String dateOfBirth;
  final String address;
  final String mobile;
  final String gender;
  final String adhaar;
  final List<EmergencyContact> emergencyContact;
  final String blood;
  final String pastDisease;

  ProfileModel({
    required this.photo,
    required this.id,
    required this.fullName,
    required this.email,
    required this.dateOfBirth,
    required this.address,
    required this.mobile,
    required this.gender,
    required this.adhaar,
    required this.emergencyContact,
    required this.blood,
    required this.pastDisease,
  });

  // Convert JSON to ProfileModel Object
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final userData = json["data"]?["doc"];  // Extract user object

    if (userData == null) {
      throw Exception("Invalid response: Missing user data");
    }

    return ProfileModel(
      photo: userData["photo"] ?? "",
      id: userData["_id"] ?? "",
      fullName: userData["fullName"] ?? "",
      email: userData["email"] ?? "",
      dateOfBirth: userData["dateOfBirth"] ?? "",
      address: userData["address"] ?? "",
      mobile: userData["mobile"]?.toString() ?? "",
      gender: userData["gender"] ?? "",
      adhaar: userData["adhaar"]?.toString() ?? "",
      emergencyContact: (userData["emergencyContact"] as List<dynamic>?)
          ?.map((e) => EmergencyContact.fromJson(e))
          .toList() ??
          [],
      blood: userData["blood"] ?? "",
      pastDisease: userData["pastDisease"] ?? "",
    );
  }

  // Convert ProfileModel Object to JSON
  Map<String, dynamic> toJson() {
    return {
      "photo": photo,
      "_id": id,
      "fullName": fullName,
      "email": email,
      "dateOfBirth": dateOfBirth,
      "address": address,
      "mobile": mobile,
      "gender": gender,
      "adhaar": adhaar,
      "emergencyContact": emergencyContact.map((e) => e.toJson()).toList(),
      "blood": blood,
      "pastDisease": pastDisease,
    };
  }
}

// Emergency Contact Model
class EmergencyContact {
  final String name;
  final String mobile;

  EmergencyContact({
    required this.name,
    required this.mobile,
  });

  // Convert JSON to EmergencyContact Object
  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json["name"] ?? "",
      mobile: json["mobile"]?.toString() ?? "",
    );
  }

  // Convert EmergencyContact Object to JSON
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "mobile": mobile,
    };
  }
}

// Function to parse JSON response into a ProfileModel object
ProfileModel parseProfileModel(String responseBody) {
  final parsed = jsonDecode(responseBody);
  return ProfileModel.fromJson(parsed);
}
