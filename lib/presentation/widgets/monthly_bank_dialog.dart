import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/monthly_bank_balance.dart';
import '../../providers/monthly_bank_balance_provider.dart';

class MonthlyBankDialog extends ConsumerStatefulWidget {
  final String yearMonth;
  final MonthlyBankBalance? initialData;

  const MonthlyBankDialog({
    super.key,
    required this.yearMonth,
    this.initialData,
  });

  @override
  ConsumerState<MonthlyBankDialog> createState() => _MonthlyBankDialogState();
}

class _MonthlyBankDialogState extends ConsumerState<MonthlyBankDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _institutionController;
  late TextEditingController _accountNameController;
  late TextEditingController _balanceController;
  bool _isSubmitting = false;

  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    _institutionController = TextEditingController(
      text: widget.initialData?.financialInstitution ?? '',
    );
    _accountNameController = TextEditingController(
      text: widget.initialData?.accountName ?? '',
    );
    _balanceController = TextEditingController(
      text: widget.initialData != null
          ? widget.initialData!.balance.toInt().toString()
          : '',
    );
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _accountNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final balance = MonthlyBankBalance(
        id: widget.initialData?.id,
        yearMonth: widget.yearMonth,
        financialInstitution: _institutionController.text.trim(),
        accountName: _accountNameController.text.trim(),
        balance: double.parse(_balanceController.text.replaceAll(',', '')),
      );

      await ref
          .read(monthlyBankBalanceNotifierProvider(widget.yearMonth).notifier)
          .saveBalance(balance);

      if (mounted) Navigator.of(context).pop();
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
      title: Text(_isEditing
          ? '월말 은행 잔액 수정 (${widget.yearMonth})'
          : '월말 은행 잔액 등록 (${widget.yearMonth})'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _institutionController,
                decoration: const InputDecoration(
                  labelText: '금융기관',
                  hintText: '예: KB국민은행, 카카오뱅크, 신한은행',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '금융기관을 입력해 주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _accountNameController,
                decoration: const InputDecoration(
                  labelText: '계좌명',
                  hintText: '예: 주거래 통장, 비상금 적금',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '계좌명을 입력해 주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: '잔액 (원)',
                  hintText: '0',
                  suffixText: '원',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '잔액을 입력해 주세요.';
                  }
                  if (double.tryParse(val) == null) {
                    return '올바른 숫자를 입력해 주세요.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? '수정' : '등록'),
        ),
      ],
    );
  }
}