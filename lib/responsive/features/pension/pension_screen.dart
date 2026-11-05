import 'package:flutter/material.dart';

import '../../scaffold/widgets/common_responsive_layout.dart';
import 'responsive_screens/pension_desktop.dart';
import 'responsive_screens/pension_mobile.dart';

class PensionScreen extends StatelessWidget {
  const PensionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonResponsiveLayout(
      desktopScreen: PensionDesktopScreen(),
      mobileScreen: PensionMobileScreen(),
    );
  }
}