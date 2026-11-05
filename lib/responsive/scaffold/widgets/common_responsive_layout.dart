import 'package:flutter/material.dart';

class CommonResponsiveLayout extends StatelessWidget {
  const CommonResponsiveLayout({
    super.key,
    required this.desktopScreen,
    required this.mobileScreen,
  });

  final Widget desktopScreen;
  final Widget mobileScreen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 768px 이상은 데스크톱 화면, 그 미만은 모바일 화면 반환
        if (constraints.maxWidth >= 768) {
          return desktopScreen;
        } else {
          return mobileScreen;
        }
      },
    );
  }
}