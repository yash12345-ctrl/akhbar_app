import 'dart:convert';

import 'package:akhbar/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'token_model.dart';
import 'user_model.dart';

class SavedAuth {
  final User user;
  final Token token;

  SavedAuth({
    required this.user,
    required this.token,
  });

  factory SavedAuth.fromJson(Map<String, dynamic> json) {
    return SavedAuth(
      user: User.fromJson(json["user"]),
      token: Token.fromJson(json["token"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user": user.toJson(),
      "token": token.toJson(),
    };
  }

  @override
  String toString() {
    return "SavedAuth{${user.toString()}, ${token.toString()}}";
  }
}

SavedAuth savedAuthFromJsonString(String json) {
  var jsonData = jsonDecode(json);

  return SavedAuth.fromJson(jsonData);
}

void saveUserAuthInfo(User user, Token token) async {
  SavedAuth savedAuth = SavedAuth(user: user, token: token);
  String stringSavedAuth = jsonEncode(savedAuth.toJson());

  final perf = await SharedPreferences.getInstance();
  final String? old = perf.getString(AppConstants.savedAuthKey);
  if (old != null) {
    perf.remove(AppConstants.savedAuthKey);
  }
  await perf.setString(AppConstants.savedAuthKey, stringSavedAuth);
}

Future<bool> checkSavedUserAuthInfo() async {
  final perf = await SharedPreferences.getInstance();
  final String? savedAuthStr = perf.getString(AppConstants.savedAuthKey);
  if (savedAuthStr == null) {
    return false;
  }
  // @TODO Inspect savedAuthData to ensure the token is right and user is loggedin
  final savedAuthData = savedAuthFromJsonString(savedAuthStr);
  return true;
}

Future<bool> deleteSavedUserAuthInfo() async {
  final perf = await SharedPreferences.getInstance();
  try {
    perf.remove(AppConstants.savedAuthKey);
  } catch (error) {
    // @TODO Report / Log error
    return false;
  }

  return true;
}

Future<SavedAuth> getSavedAuthInfo() async {
  final perf = await SharedPreferences.getInstance();
  final String? savedAuthStr = perf.getString(AppConstants.savedAuthKey);
  if (savedAuthStr == null) {
    throw Exception("Not logged in");
  }
  final savedAuthData = savedAuthFromJsonString(savedAuthStr);

  return savedAuthData;
}