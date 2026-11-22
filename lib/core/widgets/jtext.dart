import 'package:flutter/material.dart';

class JText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool selectable;
  final int? maxLines;
  final bool overflow;

  const JText(
    this.text, {
    super.key,
    this.style,
    this.selectable = true,
    this.maxLines, // 값을 넘기지 않으면 자동으로 null
    this.overflow = false,
  });

  @override
  Widget build(BuildContext context) {
    final TextOverflow? textOverflow = overflow ? TextOverflow.ellipsis : null;

    // 일반적인 Text 위젯 대신 SelectableText 위젯을 사용하면, 사용자가 텍스트를 길게 눌렀을 때
    // 자동으로 텍스트 선택 툴바(복사, 전체 선택 등)가 나타납니다.
    // 사용법: Text('내용') 대신 JText('내용')
    return FittedBox(
      fit: BoxFit.scaleDown, // 공간이 부족할 때만 글씨 크기를 줄임
      // alignment: Alignment.centerLeft,
      child: SelectableText(
        text,
        maxLines: maxLines,
        style: (style ?? const TextStyle()).copyWith(overflow: textOverflow),
      ),
    );
  }
}
