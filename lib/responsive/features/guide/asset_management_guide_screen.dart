import 'package:flutter/material.dart';

import '../../scaffold/widgets/common_responsive_layout.dart';
import 'responsive_screens/guide_desktop.dart';
import 'responsive_screens/guide_mobile.dart';

class AssetManagementGuideScreen extends StatelessWidget {
  const AssetManagementGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonResponsiveLayout(
      desktopScreen: GuideDesktopScreen(),
      mobileScreen: GuideMobileScreen(),
    );
  }
}