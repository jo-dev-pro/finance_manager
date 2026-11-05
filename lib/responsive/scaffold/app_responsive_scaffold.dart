// lib/presentation/responsive/responsive_scaffold.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'layout/desktop_scaffold_layout.dart';
import 'layout/mobile_scaffold_layout.dart';

class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 예: 768px 미만(일반적인 모바일 스마트폰 세로 크기)만 모바일로 처리
        // 768px 이상인 태블릿 및 데스크톱은 모두 데스크톱 레이아웃(NavigationRail) 적용
        if (constraints.maxWidth < 768) {
          return MobileScaffoldLayout(navigationShell: navigationShell);
        } else {
          return DesktopScaffoldLayout(navigationShell: navigationShell);
        }
      },
    );
  }
}