// lib/responsive/scaffold/widgets/desktop_container.dart
import 'package:flutter/material.dart';

import '../../../core/utils/screen_size.dart'; // desktopWidthSize 상수 임포트

/// 데스크톱/태블릿 화면에서 중앙 정렬 및 최대 너비(desktopWidthSize)를 제한해 주는 공통 래퍼 위젯
class DesktopContainer extends StatelessWidget {
  const DesktopContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? desktopWidthSize, // 기본값은 screen_size.dart의 desktopWidthSize
        ),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}