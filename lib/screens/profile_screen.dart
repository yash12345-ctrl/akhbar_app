import 'dart:convert';
import 'dart:io';
import 'package:akhbar/models/user_model.dart';
import 'package:http/http.dart' as http;

import 'package:akhbar/apis/auth_api.dart';
import 'package:akhbar/components/profile_image.dart';
import 'package:akhbar/constants/app_constants.dart';
import 'package:akhbar/constants/colors.dart';
import 'package:akhbar/models/saved_auth_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _ProfileScreen();
  }

}

class _ProfileScreen extends State<ProfileScreen> {

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _genderController = TextEditingController();
  String? profileImageUrl;
  bool _isLoggedIn = false;
  User? _user;

  void populateUserInfo() async {
    if (! await isLoggedIn()) {
      setState(() {
        _isLoggedIn = false;
      });
      return;
    }

    final userInfo = await getSavedAuthInfo();
    _user = userInfo.user;
    _firstNameController.text = userInfo.user.firstName;
    _lastNameController.text = userInfo.user.lastName;
    _phoneController.text = userInfo.user.phone;
    if (userInfo.user.photoUrl.isNotEmpty) {
      setState(() {
        profileImageUrl = userInfo.user.photoUrl;
        _isLoggedIn = true;
      });
    } else {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  /// Get from gallery
  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      _asyncFileUpload("test-image-name.jpg", imageFile);
    }
  }

  _asyncFileUpload(String text, File file) async {
    SavedAuth? authInfo;
    try {
      authInfo = await getSavedAuthInfo();
    } catch (error) {
      // @TODO Logout and redirect to login screen
    }

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("POST", Uri.parse("${AppConstants.apiProfileImageUploadUrl}/1/upload"));
    //add text fields
    request.fields["text_field"] = text;
    //create multipart using filepath, string or bytes
    var pic = await http.MultipartFile.fromPath("photo", file.path);
    //add multipart to request
    request.files.add(pic);
    request.headers.addAll({
      "Authorization": "Bearer ${authInfo!.token.plainTextToken}",
      "Accept": "application/json",
    });
    var response = await request.send();

    //Get the response from the server
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);

    // Update the saved user info
    final jsonData = jsonDecode(responseString);
    User user = User.fromJson(jsonData["data"]);
    final savedAuthInfo = await getSavedAuthInfo();
    saveUserAuthInfo(user, savedAuthInfo.token);

    setState(() {
      profileImageUrl = user.photoUrl;
    });
  }


  @override
  void initState() {
    populateUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return const _PremiumUnauthView();
    }

    final name = _user?.firstName ?? "";
    final lastName = _user?.lastName ?? "";
    final fullName = "$name $lastName".trim();
    final email = _user?.email ?? "";
    final phone = _user?.phone ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.only(bottom: 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(AppColors.PRIMARY), Color(0xFFFF8B45)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // Top App Bar Area
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: ElevatedButton(
                              onPressed: () => context.pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                padding: const EdgeInsets.all(0),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                "My Profile",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 36), // Balance the back button
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Avatar Section
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4), // White border
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: ProfileImage(imageUrl: profileImageUrl, width: 110, height: 110),
                            ),
                          ),
                          GestureDetector(
                            onTap: _getFromGallery,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 4, right: 4),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(AppColors.PRIMARY),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(AppColors.PRIMARY).withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Details Section
              Transform.translate(
                offset: const Offset(0, -32),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        fullName.isNotEmpty ? fullName : "User",
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 26,
                          letterSpacing: -0.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1D1E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Contact info badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (phone.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.phone_rounded, size: 14, color: Color(AppColors.PRIMARY)),
                                  const SizedBox(width: 8),
                                  Text(phone, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
                                ],
                              ),
                            ),
                          if (phone.isNotEmpty && email.isNotEmpty) const SizedBox(width: 12),
                          if (email.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.email_rounded, size: 14, color: Color(AppColors.PRIMARY)),
                                  const SizedBox(width: 8),
                                  Text(email, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
                                ],
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Settings Groups
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 8, bottom: 8),
                              child: Text("GENERAL", style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF888888), letterSpacing: 1.2)),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5)),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildSettingsTile(
                                    icon: Icons.description_rounded,
                                    iconColor: Colors.blue.shade600,
                                    iconBgColor: Colors.blue.shade50,
                                    title: "Terms and Conditions",
                                    onTap: () async {
                                      final url = Uri.parse("${AppConstants.baseUrl}/terms");
                                      try { await launchUrl(url); } catch (e) {}
                                    },
                                  ),
                                  Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1), indent: 64),
                                  _buildSettingsTile(
                                    icon: Icons.privacy_tip_rounded,
                                    iconColor: Colors.purple.shade600,
                                    iconBgColor: Colors.purple.shade50,
                                    title: "Privacy Policy",
                                    onTap: () async {
                                      final url = Uri.parse("${AppConstants.baseUrl}/privacy");
                                      try { await launchUrl(url); } catch (e) {}
                                    },
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            const Padding(
                              padding: EdgeInsets.only(left: 8, bottom: 8),
                              child: Text("ACCOUNT", style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF888888), letterSpacing: 1.2)),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5)),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildSettingsTile(
                                    icon: Icons.logout_rounded,
                                    iconColor: Colors.orange.shade700,
                                    iconBgColor: Colors.orange.shade50,
                                    title: "Log Out",
                                    onTap: () async {
                                      try {
                                        await logout();
                                      } finally {
                                        if (mounted) {
                                          context.goNamed("signin");
                                        }
                                      }
                                    },
                                  ),
                                  Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1), indent: 64),
                                  _buildSettingsTile(
                                    icon: Icons.person_remove_rounded,
                                    iconColor: Colors.red.shade600,
                                    iconBgColor: Colors.red.shade50,
                                    title: "Delete Account",
                                    isDestructive: true,
                                    onTap: () {
                                      _showDeleteAccountDialog(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Delete Account", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w800, fontSize: 20)),
        content: const Text(
          "Are you sure you want to delete your account? You will lose all your data permanently.",
          style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: Color(0xFF555555), height: 1.4),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'No'),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF888888), fontFamily: 'Inter', fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context, 'Yes');
              try {
                await deleteAccount();
              } finally {
                if (context.mounted) {
                  context.goNamed("signin");
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Delete", style: TextStyle(color: Colors.red.shade700, fontFamily: 'Inter', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDestructive ? Colors.red.shade700 : const Color(0xFF1A1D1E),
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}

class _PremiumUnauthView extends StatefulWidget {
  const _PremiumUnauthView();

  @override
  State<_PremiumUnauthView> createState() => _PremiumUnauthViewState();
}

class _PremiumUnauthViewState extends State<_PremiumUnauthView> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.1, 1.0, curve: Curves.easeOut)),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic)),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111111)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed("home");
            }
          },
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(flex: 2),
                      
                      // Hero Illustration
                      Center(
                        child: Hero(
                          tag: 'app_logo',
                          child: Image.asset(
                            "assets/img/a2-mobile.png",
                            height: MediaQuery.of(context).size.width * 0.7, 
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Clean, professional typography
                      const Text(
                        "Discover What\nMatters to You",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111111),
                          height: 1.15,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Sign in to personalize your news feed, save articles for offline reading, and stay updated.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF111111).withValues(alpha: 0.6),
                          height: 1.5,
                        ),
                      ),
                      const Spacer(flex: 2),
                      
                      // Professional action buttons
                      ElevatedButton(
                        onPressed: () => context.pushNamed("signin"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppColors.PRIMARY),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Log In to Account",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => context.pushNamed("signup"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF111111),
                          side: BorderSide(color: const Color(0xFF111111).withValues(alpha: 0.15), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Create an Account",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}