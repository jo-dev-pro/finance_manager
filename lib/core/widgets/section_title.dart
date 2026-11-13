import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final double topSpacing;
  final double bottomSpacing;

  const SectionTitle(
    this.title, {
    super.key,
    this.topSpacing = 24.0,
    this.bottomSpacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topSpacing, bottom: bottomSpacing, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}