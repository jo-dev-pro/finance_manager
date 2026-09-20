import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/utils/formatters.dart';
import '../../models/investment.dart';
import '../../providers/investment_provider.dart';

class InvestmentDialog extends ConsumerStatefulWidget {
  final Investment? initialData;

  const InvestmentDialog({super.key, this.initialData});

  @override
  ConsumerState<InvestmentDialog> createState() => _InvestmentDialogState();
}

class _InvestmentDialogState extends ConsumerState<InvestmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  bool _isSubmitting = false;

  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.initialData?.description ?? '',
    );

    // 수정 시 초기 금액에 콤마 포맷팅 적용
    final formatter = NumberFormat('#,###', 'ko_KR');
    final initialAmountText = widget.initialData != null
        ? formatter.format(widget.initialData!.amount.toInt())
        : '';

    _amountController = TextEditingController(
      text: initialAmountText,
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final description = _descriptionController.text.trim();
      // 콤마 제거 후 double 변환
      final rawAmountText = _amountController.text.replaceAll(',', '');
      final amount = double.parse(rawAmountText);

      final investment = Investment(
        id: widget.initialData?.id,
        description: description,
        amount: amount,
      );

      final notifier = ref.read(investmentNotifierProvider.notifier);
      if (_isEditing) {
        await notifier.updateInvestment(investment);
      } else {
        await notifier.addInvestment(investment);
      }

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
      title: Text(_isEditing ? '투자 내역 수정' : '투자 내역 등록'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '적요',
                hintText: '예: 정기 입금, 삼성전자 매수',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return '적요를 입력해 주세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(), // 콤마 포맷터 추가
              ],
              decoration: const InputDecoration(
                labelText: '투자금액',
                hintText: '0',
                suffixText: '원',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return '금액을 입력해 주세요.';
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