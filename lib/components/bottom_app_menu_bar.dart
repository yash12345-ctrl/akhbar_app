
import 'package:akhbar/constants/colors.dart';
import 'package:flutter/material.dart';

// @NOTE(muktar): A very good article on how to create custom icon for flutter
// apps like built in android icons
// https://medium.com/codechai/how-to-use-custom-icons-in-flutter-834a079d977

class BottomAppMenuBar extends StatefulWidget {
  final int activeIndex;
  final ValueChanged<int> onTabSelected;
  final PageController? pageController;

  const BottomAppMenuBar({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
    this.pageController,
  });

  @override
  State<BottomAppMenuBar> createState() => _BottomAppMenuBarState();
}

class _BottomAppMenuBarState extends State<BottomAppMenuBar> {

  @override
  Widget build(BuildContext context) {
    // return BottomNavigationBar(
    //   type: BottomNavigationBarType.fixed,
    //   items: const <BottomNavigationBarItem>[
    //     BottomNavigationBarItem(
    //         icon: Icon(Icons.add),
    //       label: "Home",
    //     ),
    //     BottomNavigationBarItem(
    //       icon: Icon(Icons.access_alarm_outlined),
    //       label: "Search",
    //     ),
    //     BottomNavigationBarItem(
    //       icon: Icon(Icons.access_alarm_outlined),
    //       label: "My Courses",
    //     ),
    //     BottomNavigationBarItem(
    //       icon: Icon(Icons.access_alarm_outlined),
    //       label: "Refer",
    //     ),
    //     BottomNavigationBarItem(
    //       icon: Icon(Icons.access_alarm_outlined),
    //       label: "Cart",
    //     ),
    //   ],
    // );
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: widget.pageController ?? AlwaysStoppedAnimation(widget.activeIndex.toDouble()),
                builder: (context, child) {
                  double page = widget.activeIndex.toDouble();
                  if (widget.pageController != null && widget.pageController!.hasClients && widget.pageController!.position.haveDimensions) {
                    page = widget.pageController!.page ?? widget.activeIndex.toDouble();
                  }
                  
                  return Align(
                    alignment: Alignment(-1.0 + (page * 0.5), 0),
                    child: FractionallySizedBox(
                      widthFactor: 0.2,
                      child: Center(
                        child: Container(
                          width: 66,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(AppColors.PRIMARY).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, "Home", 0, () => widget.onTabSelected(0), customIconAsset: "assets/icons/home.png"),
                _buildNavItem(context, "My Feed", 1, () => widget.onTabSelected(1), customIconAsset: "assets/icons/category.png"),
                _buildNavItem(context, "Top Stories", 2, () => widget.onTabSelected(2), customIconAsset: "assets/icons/story.png"),
                _buildNavItem(context, "Video", 3, () => widget.onTabSelected(3), customIconAsset: "assets/icons/video.png"),
                _buildNavItem(context, "E-Papers", 4, () => widget.onTabSelected(4), customIconAsset: "assets/icons/contract.png"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String label, int index, VoidCallback onTap, {IconData? activeIcon, IconData? inactiveIcon, String? customIconAsset}) {
    final isActive = widget.activeIndex == index;
    final activeColor = const Color(AppColors.PRIMARY);
    final inactiveColor = const Color(0xFF999999);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 38,
              alignment: Alignment.center,
              child: customIconAsset != null 
                ? Opacity(
                    opacity: isActive ? 1.0 : 0.4,
                    child: Image.asset(customIconAsset, width: 26, height: 26),
                  )
                : Icon(
                    isActive ? activeIcon : inactiveIcon, 
                    size: 26.0, 
                    color: isActive ? activeColor : inactiveColor,
                  ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontFamily: "BarlowCondensed",
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? activeColor : inactiveColor,
                letterSpacing: 0.5,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}