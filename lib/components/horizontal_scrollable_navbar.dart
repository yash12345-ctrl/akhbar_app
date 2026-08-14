import 'package:akhbar/constants/colors.dart';
import 'package:flutter/material.dart';

class HorizontalScrollableNavbar extends StatefulWidget {
  final List<String> menuList;
  void Function(int)? onMenuChange;
  HorizontalScrollableNavbar({super.key, required this.menuList, this.onMenuChange});

  @override
  State<StatefulWidget> createState() => _HorizontalScrollableNavbar();
}

class _HorizontalScrollableNavbar extends State<HorizontalScrollableNavbar> {
  int activeItemIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          const SizedBox(width: 24),
          // Fixed 3-dot Sidebar / More Button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: const Color(0xFFEEEEEE), width: 1.0),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_horiz_rounded, size: 22, color: Color(0xFF111111)),
              onPressed: () {
                try {
                  Scaffold.of(context).openDrawer();
                } catch (e) {
                  // Ignore if no drawer is available yet
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          // Scrollable Category Pills
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 24),
              itemBuilder: (BuildContext context, int index) {
                final isActive = activeItemIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      activeItemIndex = index;
                    });
                    if (widget.onMenuChange != null) {
                      widget.onMenuChange!(index);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(AppColors.PRIMARY) : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      widget.menuList[index],
                      style: TextStyle(
                        color: isActive ? Colors.white : const Color(0xFF666666),
                        fontSize: 15,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                        fontFamily: "BarlowCondensed",
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 8),
              itemCount: widget.menuList.length,
            ),
          ),
        ],
      ),
    );
  }
}