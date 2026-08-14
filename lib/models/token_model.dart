import 'dart:convert';

class Token {
  final String plainTextToken;

  Token({
    required this.plainTextToken,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      plainTextToken: json["token"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "token": plainTextToken,
    };
  }

  @override
  String toString() {
    return 'Token{plainTextToken: $plainTextToken}';
  }
}

List<Token> tokensFromJson(String jsonData) {
  var data = jsonDecode(jsonData);

  return List<Token>.from(data.map((item) => Token.fromJson(item)));
}