import 'package:flutter/material.dart';

import '../utils/responsive_extension.dart';

class MainConstrainedBox extends StatelessWidget {
  const MainConstrainedBox({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.desktopWidthSize),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: child,
        ),
      ),
    );
  }
}