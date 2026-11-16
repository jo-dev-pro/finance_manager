import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
  // 화면 너비와 높이
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  // 💡 데스크톱 기준 너비 값 설정
  double get desktopWidthSize => 1200;

  // 기기 타입 판별 브레이크포인트 (ResponsiveScaffold 기준 통일)
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1000;
  bool get isDesktop => screenWidth >= 1000;
  
// 💡 키보드 및 시스템 하단 인셋 관련 편의 기능 추가
  double get bottomInset => MediaQuery.of(this).viewInsets.bottom;
  bool get isKeyboardOpen => bottomInset > 0;

  // 💡 컬러 및 테마 관련 단축키 (Theme Shortcuts)
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  Color get primaryColor => colorScheme.primary;
  Color get onPrimaryColor => colorScheme.onPrimary;
  Color get surfaceColor => colorScheme.surface;
  Color get onSurfaceColor => colorScheme.onSurface;
  Color get unselectedColor => colorScheme.onSurfaceVariant;
  Color get errorColor => colorScheme.error;

  Color get backgroundColor => Colors.grey.shade100;
  Color get borderGreyColor => Colors.grey.shade300;
  
}
