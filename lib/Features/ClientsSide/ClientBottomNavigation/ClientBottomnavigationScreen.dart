import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/Clientmyjobssection/Clientmyjobscreen.dart';
import 'package:helper_app2/Features/SharedScreen/ChatSection/chatlistscreensection/ChatListScreen.dart';

import '../../../Core/Widgets/MediaqueryHelperfile.dart';
import 'clientProfilesection/clientProfilescreensection/clientProfileScreen.dart';
import 'clienthomesection/ClientHomeScreen.dart';
import 'clintpostjobsection/clientpostjobscreen.dart';

class Clientbottomnavigationscreen extends StatefulWidget {
  const Clientbottomnavigationscreen({super.key});

  @override
  State<Clientbottomnavigationscreen> createState() =>
      _ClientbottomnavigationscreenState();
}

class _ClientbottomnavigationscreenState
    extends State<Clientbottomnavigationscreen> {
  int currentIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      Clienthomescreen(
        onNavigateToPostJob: () {
          if (mounted) setState(() => currentIndex = 4);
        },
      ),
      ChatListScreen(),
      ClientMyJobScreen(),
      Clientprofilescreen(),
      Clientpostjobscreen(
        onBack: () {
          if (mounted) setState(() => currentIndex = 0);
        },
      ), // index 4 — Post Job, isay Clienthomescreen ke FAB se navigate karwaya jata hai
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
        theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        statusBarBrightness:
        theme.brightness == Brightness.dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness:
        theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        extendBody: true,
        extendBodyBehindAppBar: true,

        body: IndexedStack(index: currentIndex, children: pages),

        // ── Notched navbar — corners peak UPWARD, dip in the middle ──
        bottomNavigationBar: _NotchedTopNavBar(
          theme: theme,
          currentIndex: currentIndex,
          onTap: (i) => setState(() => currentIndex = i),
        ),
      ),
    );
  }
}

/// A bottom nav bar whose top edge curves UP into a peak at each corner
/// (instead of the usual rounded corner that curves down/in).
class _NotchedTopNavBar extends StatelessWidget {
  final ThemeData theme;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NotchedTopNavBar({
    required this.theme,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic system navigation padding for safe area (Android/iOS)
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    final double flatHeight = AppSize.height * 0.055;
    final double peakHeight = AppSize.height * 0.021;
    final double curveWidth = AppSize.width * 0.05;

    // Added bottomPadding to ensure background extends under system bar
    final double totalHeight = flatHeight + peakHeight + bottomPadding;

    return Container(
      color: Colors.transparent,
      height: totalHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipPath(
              clipper: _TopPeakClipper(
                peakHeight: peakHeight,
                curveWidth: curveWidth,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: theme.canvasColor.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding, // Icons ko system buttons ke upar adjust kar diya
            height: flatHeight-AppSize.height*0.005,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(icon: Icons.home_filled, label: 'client_bottom_nav_home'.tr, index: 0),
                _navItem(icon: Icons.chat_bubble, label: 'client_bottom_nav_chat'.tr, index: 1),
                _navItem(icon: Icons.history_outlined, label: 'client_bottom_nav_my_jobs'.tr, index: 2),
                _navItem(icon: Icons.person_outline, label: 'client_bottom_nav_profile'.tr, index: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = currentIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(50),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => onTap(index),
      child: SizedBox(
        width: 70,
        height: 55,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: AppSize.height * 0.011,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopPeakClipper extends CustomClipper<Path> {
  final double peakHeight;
  final double curveWidth;

  _TopPeakClipper({required this.peakHeight, required this.curveWidth});

  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, size.height);
    path.lineTo(0, 0);

    path.cubicTo(
      curveWidth * 0.55, 0,
      curveWidth * 0.55, peakHeight,
      curveWidth, peakHeight,
    );

    path.lineTo(size.width - curveWidth, peakHeight);

    path.cubicTo(
      size.width - curveWidth * 0.55, peakHeight,
      size.width - curveWidth * 0.55, 0,
      size.width, 0,
    );

    path.lineTo(size.width, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant _TopPeakClipper oldClipper) {
    return oldClipper.peakHeight != peakHeight ||
        oldClipper.curveWidth != curveWidth;
  }
}