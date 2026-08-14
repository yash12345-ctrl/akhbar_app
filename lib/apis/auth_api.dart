import 'dart:convert';

import 'package:akhbar/constants/app_constants.dart';
import 'package:akhbar/exceptions/http_exception.dart';
import 'package:akhbar/models/saved_auth_model.dart';
import 'package:akhbar/models/token_model.dart';
import 'package:http/http.dart' as http;
import 'package:akhbar/models/user_model.dart';

Future<User> otpLogin(String email, String otp) async {
  final response = await http.post(
    Uri.parse(AppConstants.apiUserOTPLoginUrl),
    body: jsonEncode({"email": email, "otp": otp}),
    headers: {"content-type": "application/json", "accept": "application/json"},
  );

  if (response.statusCode == 422) {
    var errorMsg = jsonDecode(response.body);
    throw HttpException(errorMsg["message"]);
  } else if (response.statusCode != 200) {
    throw HttpException("Failed to login");
  }

  final jsonData = jsonDecode(response.body);
  User user = User.fromJson(jsonData["user"]);

  // Store this token in the SD card
  Token token = Token.fromJson(jsonData["token"]);

  saveUserAuthInfo(user, token);

  return user;
}

Future<User> login(String email, String password) async {
  final response = await http.post(
    Uri.parse(AppConstants.apiUserLoginUrl),
    body: jsonEncode({"email": email, "password": password}),
    headers: {"content-type": "application/json", "accept": "application/json"},
  );

  if (response.statusCode == 422) {
    var errorMsg = jsonDecode(response.body);
    throw HttpException(errorMsg["message"]);
  } else if (response.statusCode >= 300) {
    throw HttpException("Failed to login");
  }

  final jsonData = jsonDecode(response.body);
  User user = User.fromJson(jsonData["user"]);

  // Store this token in the SD card
  Token token = Token.fromJson(jsonData["token"]);

  saveUserAuthInfo(user, token);

  return user;
}

Future<User> register(User user) async {
  final response = await http.post(
    Uri.parse(AppConstants.apiUserRegisterUrl),
    body: jsonEncode(user.toJson()),
    headers: {"content-type": "application/json", "accept": "application/json"},
  );

  if (response.statusCode == 422) {
    var errorMsg = jsonDecode(response.body);
    throw HttpException(errorMsg["message"]);
  } else if (response.statusCode != 201) {
    throw HttpException("Failed to register");
  }

  return userFromJson(response.body);
}

Future<void> forgotPasswordSendOtp(String email) async {
  final response = await http.post(
    Uri.parse(AppConstants.apiUserForgotPasswordSendOtpUrl),
    body: jsonEncode({"email": email}),
    headers: {"content-type": "application/json", "accept": "application/json"},
  );

  if (response.statusCode == 422) {
    var errorMsg = jsonDecode(response.body);
    throw HttpException(errorMsg["message"] ?? "Invalid email");
  } else if (response.statusCode >= 300) {
    throw HttpException("Failed to send OTP");
  }
}

Future<void> forgotPasswordVerifyOtp(String email, String otp) async {
  final response = await http.post(
    Uri.parse(AppConstants.apiUserForgotPasswordVerifyOtpUrl),
    body: jsonEncode({"email": email, "otp": otp}),
    headers: {"content-type": "application/json", "accept": "application/json"},
  );

  if (response.statusCode == 422) {
    var errorMsg = jsonDecode(response.body);
    throw HttpException(errorMsg["message"] ?? "Invalid OTP");
  } else if (response.statusCode >= 300) {
    throw HttpException("Failed to verify OTP");
  }
}

Future<void> forgotPasswordReset(String email, String otp, String password, String passwordConfirmation) async {
  final response = await http.post(
    Uri.parse(AppConstants.apiUserForgotPasswordResetUrl),
    body: jsonEncode({
      "email": email,
      "otp": otp,
      "password": password,
      "password_confirmation": passwordConfirmation
    }),
    headers: {"content-type": "application/json", "accept": "application/json"},
  );

  if (response.statusCode == 422) {
    var errorMsg = jsonDecode(response.body);
    throw HttpException(errorMsg["message"] ?? "Invalid data");
  } else if (response.statusCode >= 300) {
    throw HttpException("Failed to reset password");
  }
}

Future<bool> isLoggedIn() async {
  return await checkSavedUserAuthInfo();
}

Future<bool> logout() async {
  SavedAuth? authInfo;
  try {
    authInfo = await getSavedAuthInfo();
  } catch (error) {
    // @TODO Logout and redirect to login screen
  }

  final response = await http.post(
    Uri.parse(AppConstants.apiUserLogoutUrl),
    headers: {
      "Authorization": "Bearer ${authInfo!.token}",
      "content-type": "application/json",
      "accept": "application/json",
    },
  );

  // @NOTE Silently ignore the logout error response

  return deleteSavedUserAuthInfo();
}

Future<bool> deleteAccount() async {
  SavedAuth? authInfo;
  try {
    authInfo = await getSavedAuthInfo();
  } catch (error) {
    // @TODO Logout and redirect to login screen
  }

  final response = await http.delete(
    Uri.parse(AppConstants.apiUserAccountDeleteUrl),
    headers: {
      "Authorization": "Bearer ${authInfo!.token.plainTextToken}",
      "content-type": "application/json",
      "accept": "application/json",
    },
  );

  // @NOTE Silently ignore the logout error response

  return deleteSavedUserAuthInfo();
}