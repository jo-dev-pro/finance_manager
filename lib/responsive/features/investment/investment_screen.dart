// lib/responsive/features/investment/investment_screen.dart
import 'package:flutter/material.dart';

import '../../scaffold/widgets/common_responsive_layout.dart';
import 'responsive_screens/investment_desktop.dart';
import 'responsive_screens/investment_mobile.dart';

class InvestmentScreen extends StatelessWidget {
  const InvestmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonResponsiveLayout(
      desktopScreen: InvestmentDesktopScreen(),
      mobileScreen: InvestmentMobileScreen(),
    );
  }
}