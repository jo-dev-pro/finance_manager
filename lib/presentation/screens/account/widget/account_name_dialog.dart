import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/account/account_name.dart';
import '../../../../providers/account/account_name_provider.dart';

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 타이틀 및 닫기
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? '계좌명 수정' : '계좌명 등록',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

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
              const SizedBox(height: 24),

              // 하단 버튼 (좌우 꽉 찬 버튼)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            _isEditing ? '수정하기' : '등록하기',
                            style: const TextStyle(fontSize: 16),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
