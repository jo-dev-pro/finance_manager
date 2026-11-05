import 'package:flutter/material.dart';

import '../../scaffold/widgets/common_responsive_layout.dart';
import 'responsive_screens/pension_product_desktop.dart';
import 'responsive_screens/pension_product_mobile.dart';

class PensionProductScreen extends StatelessWidget {
  const PensionProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonResponsiveLayout(
      desktopScreen: PensionProductDesktopScreen(),
      mobileScreen: PensionProductMobileScreen(),
    );
  }
}