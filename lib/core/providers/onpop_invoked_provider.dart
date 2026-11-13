import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onpop_invoked_provider.g.dart';

@riverpod
class JOnPopInvoked extends _$JOnPopInvoked {
  // 뒤로가기 기록을 저장할 변수
  DateTime? _backButtonPressedTime;

  @override
  bool build() {
    return false;
  }

  void handlePopInvoked(BuildContext context) {
    final now = DateTime.now();

    if (_backButtonPressedTime == null ||
        now.difference(_backButtonPressedTime!) > const Duration(seconds: 2)) {
      // 첫 번째 누름: 시간 기록 및 스낵바 표시
      _backButtonPressedTime = now;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('뒤로가기 버튼을 한 번 더 누르면 종료됩니다.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // 두 번째 누름: 곧바로 앱 종료 시스템 호출
      SystemNavigator.pop();
    }
  }
}