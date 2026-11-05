import 'package:flutter/material.dart';

import '../../scaffold/widgets/common_responsive_layout.dart';
import 'responsive_screens/stock_desktop.dart';
import 'responsive_screens/stock_mobile.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonResponsiveLayout(
      desktopScreen: StockDesktopScreen(),
      mobileScreen: StockMobileScreen(),
    );
  }
}