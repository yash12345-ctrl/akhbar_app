import 'package:akhbar/apis/auth_api.dart';
import 'package:akhbar/components/app_input_box.dart';
import 'package:akhbar/components/app_password_box.dart';
import 'package:akhbar/constants/colors.dart';
import 'package:akhbar/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SigninScreen extends StatefulWidget {
  final String title;
  const SigninScreen({super.key, required this.title});

  @override
  State<StatefulWidget> createState() => _SigninScreen();
}

class _SigninScreen extends State<SigninScreen> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isProcessing = false;
  User? user;
  String? _errorMessage;

  void _attemptLogin() async {
    try {
      setState(() {
        isProcessing = true;
      });
      user = await login(_emailController.text, _passwordController.text);
      if (!mounted) return;
      context.goNamed("home");
    } catch (error) {
      // @TODO Report exception
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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              context.goNamed("profile");
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
                    // Hero Illustration
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

                    // Header Typography
                    const Text(
                      "Welcome Back",
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
                      "Sign in to your account to continue.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF111111).withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Form Elements
                    AppInputBox(
                      hintText: "Email address",
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    AppPasswordBox(
                      hintText: "Password",
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.pushNamed("forgot-password"),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(AppColors.PRIMARY),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
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

                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isProcessing ? null : _attemptLogin,
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
                                "Log In",
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
                          "Don't have an account? ",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: const Color(0xFF111111).withValues(alpha: 0.6),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.goNamed("signup"),
                          child: const Text(
                            "Sign up",
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
