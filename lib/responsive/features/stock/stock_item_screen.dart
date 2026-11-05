import 'package:flutter/material.dart';

import '../../scaffold/widgets/common_responsive_layout.dart';
import 'responsive_screens/stock_item_desktop.dart';
import 'responsive_screens/stock_item_mobile.dart';

class StockItemScreen extends StatelessWidget {
  const StockItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonResponsiveLayout(
      desktopScreen: StockItemDesktopScreen(),
      mobileScreen: StockItemMobileScreen(),
    );
  }
}