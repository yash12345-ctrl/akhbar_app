import 'package:akhbar/components/app_input_box.dart';
import 'package:akhbar/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:akhbar/apis/auth_api.dart';

class SignupVerificationScreen extends StatefulWidget {
  final String title;
  final String email;

  const SignupVerificationScreen({
    super.key,
    required this.title,
    required this.email,
  });

  @override
  State<SignupVerificationScreen> createState() => _SignupVerificationScreen();
}

class _SignupVerificationScreen extends State<SignupVerificationScreen> {
  final _otpController = TextEditingController();
  String? _errorMessage;
  bool isProcessing = false;

  void _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      setState(() => _errorMessage = "Please enter the OTP.");
      return;
    }

    try {
      setState(() {
        isProcessing = true;
        _errorMessage = null;
      });

      await otpLogin(widget.email, _otpController.text.trim());

      // If successful, navigate to home screen
      if (mounted) {
        context.goNamed("home");
      }

    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
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
  void dispose() {
    _otpController.dispose();
    super.dispose();
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
                      "Verify Email",
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
                      "We've sent an email with an activation code to ${widget.email}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        color: const Color(0xFF111111).withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Form Elements
                    AppInputBox(
                      hintText: "Enter 6-digit code",
                      controller: _otpController,
                      prefixIcon: Icons.lock_outline_rounded,
                      keyboardType: TextInputType.number,
                    ),

                    if (_errorMessage != null)
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
                                  _errorMessage ?? "",
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

                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isProcessing ? null : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppColors.PRIMARY),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(AppColors.PRIMARY).withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(vertical: 20),
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
                                "Verify Code",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the code? ",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: const Color(0xFF111111).withValues(alpha: 0.6),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.pop(); // Go back to resend
                          },
                          child: const Text(
                            "Resend",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(AppColors.PRIMARY),
                            ),
                          ),
                        ),
                      ],
                    ),
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