import 'package:flutter/material.dart';

class JText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool selectable;

  const JText(this.text, {super.key, this.style, this.selectable = true});

  @override
  Widget build(BuildContext context) {
    if (selectable) {
      // 일반적인 Text 위젯 대신 SelectableText 위젯을 사용하면, 사용자가 텍스트를 길게 눌렀을 때
      // 자동으로 텍스트 선택 툴바(복사, 전체 선택 등)가 나타납니다.
      // 사용법: Text('내용') 대신 JText('내용')
      return SelectableText(text, style: style);
    }
    return Text(text, style: style);
  }
}