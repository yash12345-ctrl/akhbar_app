import 'package:akhbar/components/app_password_box.dart';
import 'package:akhbar/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:akhbar/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String title;
  final String phone;
  final String firstName;

  const CreatePasswordScreen({
    super.key,
    required this.title,
    required this.phone,
    required this.firstName,
  });

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreen();
}

class _CreatePasswordScreen extends State<CreatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? errorMessage;
  bool isProcessing = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (_passwordController.text.length < 8) {
      setState(() => errorMessage = "Password must be at least 8 characters.");
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => errorMessage = "Passwords do not match.");
      return;
    }

    setState(() {
      isProcessing = true;
      errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/register-phone'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'first_name': widget.firstName,
          'phone': widget.phone.replaceAll('+91', ''), // Ensure standard format if needed
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        // Save token & user details
        if (data['token'] != null && data['token']['token'] != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString("auth_token", data['token']['token']);
            await prefs.setBool("is_logged_in", true);
        }
        
        if (mounted) {
          context.goNamed("home");
        }
      } else {
        final data = json.decode(response.body);
        setState(() {
          errorMessage = data['message'] ?? "Registration failed. Phone number may already exist.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Network error. Please try again.";
      });
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111111)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),

                    // Header Typography
                    const Text(
                      "Create Password",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111111),
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Secure your account to continue.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF111111).withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Form fields
                    AppPasswordBox(
                      hintText: "New Password",
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    AppPasswordBox(
                      hintText: "Confirm Password",
                      controller: _confirmPasswordController,
                      prefixIcon: Icons.lock_outline_rounded,
                    ),

                    // Error message
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(AppColors.RED_01).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(AppColors.RED_01).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(AppColors.RED_01), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage ?? "",
                                  style: const TextStyle(
                                    color: Color(AppColors.RED_01),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const Spacer(),

                    // Sign Up button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isProcessing ? null : _createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppColors.PRIMARY),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(AppColors.PRIMARY).withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isProcessing
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                "Complete Registration",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
