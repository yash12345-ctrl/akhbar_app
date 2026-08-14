import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:akhbar/models/saved_auth_model.dart';
import 'package:akhbar/components/profile_image.dart';

class TopAppMenuBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget title;
  bool showBackButton;
  TopAppMenuBar({super.key, required this.title, this.showBackButton = false}) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize; // default is 56.0

  @override
  State<StatefulWidget> createState() => _TopAppMenuBar();
}

class _TopAppMenuBar extends State<TopAppMenuBar> {
  bool _isLoggedIn = false;
  String _profileImageUrl = "";
  String _initials = "";

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    final isLoggedIn = await checkSavedUserAuthInfo();
    if (isLoggedIn) {
      try {
        final authInfo = await getSavedAuthInfo();
        final user = authInfo.user;
        final name = user.firstName ?? "";
        final lastName = user.lastName ?? "";
        
        String initials = "";
        if (name.isNotEmpty) initials += name[0].toUpperCase();
        if (lastName.isNotEmpty) initials += lastName[0].toUpperCase();

        if (mounted) {
          setState(() {
            _isLoggedIn = true;
            _profileImageUrl = user.photoUrl ?? "";
            _initials = initials;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoggedIn = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFF0F0F0), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      if (widget.showBackButton) {
                        if (context.canPop()) {
                          context.pop();
                        }
                      } else {
                        Scaffold.of(context).openDrawer();
                      }
                    },
                    padding: const EdgeInsets.all(0),
                    iconSize: 18,
                    icon: Icon(widget.showBackButton ? Icons.arrow_back_ios_new : Icons.segment_rounded),
                    color: const Color(0xFF111111),
                  ),
                ),

              Expanded(
                child: Center(
                  child: widget.title is Text
                      ? RichText(
                          text: TextSpan(
                            text: (widget.title as Text).data ?? "",
                            style: (widget.title as Text).style ?? const TextStyle(
                              fontFamily: "BarlowCondensed",
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F141E),
                              letterSpacing: 1.5,
                            ),
                            children: const [
                              TextSpan(
                                text: ".",
                                style: TextStyle(
                                  color: Color(0xFFD32F2F), // Brand red accent
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        )
                      : widget.title,
                ),
              ),

              GestureDetector(
                onTap: () { context.goNamed("profile"); },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isLoggedIn && _profileImageUrl.isEmpty && _initials.isNotEmpty 
                        ? const Color(0xFFFF8B45) 
                        : Colors.white,
                    border: Border.all(color: const Color(0xFFF0F0F0), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _buildProfileContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    if (!_isLoggedIn) {
      return const Icon(
        Icons.person_outline_rounded,
        size: 20,
        color: Color(0xFF111111),
      );
    }

    if (_profileImageUrl.isNotEmpty) {
      return ProfileImage(imageUrl: _profileImageUrl, width: 40, height: 40);
    }

    if (_initials.isNotEmpty) {
      return Center(
        child: Text(
          _initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
      );
    }

    return const Icon(
      Icons.person,
      size: 20,
      color: Color(0xFF111111),
    );
  }
}