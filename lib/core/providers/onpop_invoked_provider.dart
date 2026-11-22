import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onpop_invoked_provider.g.dart';

@Riverpod(keepAlive: true)
class JOnPopInvoked extends _$JOnPopInvoked {
  DateTime? _backButtonPressedTime;

  @override
  bool build() {
    return false;
  }

  Future<void> handlePopInvoked(BuildContext context) async {
    final now = DateTime.now();

    if (_backButtonPressedTime == null ||
        now.difference(_backButtonPressedTime!) > const Duration(seconds: 2)) {
      _backButtonPressedTime = now;

      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text("'뒤로' 버튼을 한 번 더 누르면 앱이 종료됩니다."),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }

    _backButtonPressedTime = null;
    await SystemNavigator.pop();
  }
}