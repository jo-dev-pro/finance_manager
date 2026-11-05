import 'package:flutter/material.dart';

import '../../scaffold/widgets/common_responsive_layout.dart';
import 'responsive_screens/stock_holding_item_desktop.dart';
import 'responsive_screens/stock_holding_item_mobile.dart';

class StockHoldingItemScreen extends StatelessWidget {
  const StockHoldingItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonResponsiveLayout(
      desktopScreen: StockHoldingItemDesktopScreen(),
      mobileScreen: StockHoldingItemMobileScreen(),
    );
  }
}