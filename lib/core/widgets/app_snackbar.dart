import 'package:flutter/material.dart';

class AppSnackBar {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static SnackBar _buildSnackBar({
    required String message,
    required Color backgroundColor,
    required Color textColor,
    required Duration duration,
    SnackBarAction? action,
    bool bold = false,
  }) {
    return SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: textColor,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      action: action,
    );
  }

  static void _showWithMessenger(
    ScaffoldMessengerState? messenger,
    SnackBar snackBar,
  ) {
    if (messenger == null) return;
    messenger
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// 에러 메시지 (빨간색 배경, 흰색 텍스트)
  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;
    _showWithMessenger(
      ScaffoldMessenger.of(context),
      _buildSnackBar(
        message: message,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
        duration: const Duration(seconds: 4),
        bold: true,
        action: SnackBarAction(
          label: '확인',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// 경고 메시지 (노란색 배경, 가독성을 위해 어두운 텍스트)
  static void showWarning(BuildContext context, String message) {
    if (!context.mounted) return;
    _showWithMessenger(
      ScaffoldMessenger.of(context),
      _buildSnackBar(
        message: message,
        backgroundColor: Colors.amber.shade400,
        textColor: Colors.black87,
        duration: const Duration(seconds: 3),
        bold: true,
      ),
    );
  }

  /// 일반 안내 메시지 (검은색 계열 배경, 흰색 텍스트)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;
    _showWithMessenger(
      ScaffoldMessenger.of(context),
      _buildSnackBar(
        message: message,
        backgroundColor: Colors.grey.shade900,
        textColor: Colors.white,
        duration: duration,
      ),
    );
  }

  /// BuildContext 없이 전역 messengerKey로 경고 스낵바 표시
  static void showWarningGlobal(String message) {
    _showWithMessenger(
      messengerKey.currentState,
      _buildSnackBar(
        message: message,
        backgroundColor: Colors.amber.shade400,
        textColor: Colors.black87,
        duration: const Duration(seconds: 3),
        bold: true,
      ),
    );
  }

  /// BuildContext 없이 전역 messengerKey로 일반 안내 스낵바 표시
  static void showInfoGlobal(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _showWithMessenger(
      messengerKey.currentState,
      _buildSnackBar(
        message: message,
        backgroundColor: Colors.grey.shade900,
        textColor: Colors.white,
        duration: duration,
      ),
    );
  }
}