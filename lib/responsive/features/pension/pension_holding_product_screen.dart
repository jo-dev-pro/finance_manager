import 'package:flutter/material.dart';

import '../../scaffold/widgets/common_responsive_layout.dart';
import 'responsive_screens/pension_holding_product_desktop.dart';
import 'responsive_screens/pension_holding_product_mobile.dart';

class PensionHoldingProductScreen extends StatelessWidget {
  const PensionHoldingProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonResponsiveLayout(
      desktopScreen: PensionHoldingProductDesktopScreen(),
      mobileScreen: PensionHoldingProductMobileScreen(),
    );
  }
}