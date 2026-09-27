import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/account_name.dart';
import '../../providers/account_name_provider.dart';

class AccountNameDialog extends ConsumerStatefulWidget {
  final AccountName? accountName;

  const AccountNameDialog({super.key, this.accountName});

  @override
  ConsumerState<AccountNameDialog> createState() => _AccountNameDialogState();
}

class _AccountNameDialogState extends ConsumerState<AccountNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isSubmitting = false;

  bool get _isEditing => widget.accountName != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.accountName?.accountName ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant AccountNameDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 전달받은 accountName 객체가 변경되었을 때 컨트롤러 텍스트 동기화
    if (oldWidget.accountName != widget.accountName) {
      _nameController.text = widget.accountName?.accountName ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final accountName = _nameController.text.trim();
    final newAccountName = AccountName(
      id: widget.accountName?.id,
      accountName: accountName,
    );

    try {
      await ref
          .read(accountNameNotifierProvider.notifier)
          .saveAccountName(newAccountName);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? '계좌명 수정' : '계좌명 등록'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '계좌명',
                hintText: '예: 정기예금, 자유적금',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return '계좌명을 입력해주세요.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? '수정' : '등록'),
        ),
      ],
    );
  }
}