import 'dart:convert';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String photoUrl;
  String? password;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.photoUrl,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      firstName: json["first_name"],
      lastName: json["last_name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      photoUrl: json["photo"] ?? "",
      password: json["password"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "photo": photoUrl,
      "password": password ?? "",
    };
  }

  @override
  String toString() {
    return 'User{id: $id, firstName: $firstName, lastName: $lastName, email: $email, phone: $phone, photo: $photoUrl}';
  }
}

User userFromJson(String jsonData) {
  var data = jsonDecode(jsonData);

  return User.fromJson(data["data"]);
}