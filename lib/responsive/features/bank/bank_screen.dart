import 'package:flutter/material.dart';

import '../../scaffold/widgets/common_responsive_layout.dart';
import 'responsive_screens/bank_desktop.dart';
import 'responsive_screens/bank_mobile.dart';

class BankScreen extends StatelessWidget {
  const BankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonResponsiveLayout(
      desktopScreen: BankDesktopScreen(),
      mobileScreen: BankMobileScreen(),
    );
  }
}