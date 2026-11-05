// lib/responsive/features/all_menu/all_menu_screen.dart
import 'package:flutter/material.dart';

import '../../scaffold/widgets/common_responsive_layout.dart';
import 'responsive_screens/all_menu_desktop.dart';
import 'responsive_screens/all_menu_mobile.dart';

class AllMenuScreen extends StatelessWidget {
  const AllMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonResponsiveLayout(
      desktopScreen: AllMenuDesktopScreen(),
      mobileScreen: AllMenuMobileScreen(),
    );
  }
}