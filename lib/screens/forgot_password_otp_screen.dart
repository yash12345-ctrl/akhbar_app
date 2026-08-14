import 'package:akhbar/apis/auth_api.dart';
import 'package:akhbar/components/app_input_box.dart';
import 'package:akhbar/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final String title;
  final String email;
  const ForgotPasswordOtpScreen({super.key, required this.title, required this.email});

  @override
  State<StatefulWidget> createState() => _ForgotPasswordOtpScreen();
}

class _ForgotPasswordOtpScreen extends State<ForgotPasswordOtpScreen> {
  final _otpController = TextEditingController();
  bool isProcessing = false;
  String? _errorMessage;

  void _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Please enter the OTP.";
      });
      return;
    }
    
    try {
      setState(() {
        isProcessing = true;
        _errorMessage = null;
      });
      
      await forgotPasswordVerifyOtp(
        widget.email,
        _otpController.text.trim(),
      );
      
      if (!mounted) return;
      
      context.pushNamed(
        "forgot-password-create-password", 
        queryParameters: {
          "email": widget.email,
          "otp": _otpController.text.trim()
        }
      );
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111111)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed("forgot-password");
            }
          },
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
                    Center(
                      child: Hero(
                        tag: 'app_logo',
                        child: Image.asset(
                          "assets/img/a2-mobile.png",
                          height: size.height * 0.14, 
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      "Verify OTP",
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
                      "Enter the 6-digit OTP sent to ${widget.email}. Please check your spam folder as well.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF111111).withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 48),

                    AppInputBox(
                      hintText: "6-Digit OTP",
                      controller: _otpController,
                      prefixIcon: Icons.pin_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(AppColors.RED_01).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(AppColors.RED_01).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(AppColors.RED_01), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage ?? "",
                                  style: const TextStyle(
                                    color: Color(AppColors.RED_01),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const Spacer(),

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
                                "Verify OTP",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
