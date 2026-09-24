import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/utils/date_helper.dart'; // DateHelper 경로 확인 필요
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
  late TextEditingController _dateController;

  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.initialData?.description ?? '',
    );

    final formatter = NumberFormat('#,###', 'ko_KR');
    final initialAmountText =
        widget.initialData != null
            ? formatter.format(widget.initialData!.amount.toInt())
            : '';

    _amountController = TextEditingController(text: initialAmountText);

    // 날짜 초기값 설정
    if (widget.initialData?.createdAt != null) {
      _selectedDate = widget.initialData!.createdAt!;
    }
    _dateController = TextEditingController(
      text: DateHelper.formatToKorean(_selectedDate),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // 날짜 선택 클릭 처리
  Future<void> _pickDate() async {
    final picked = await DateHelper.pickDate(
      context,
      initialDate: _selectedDate,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateHelper.formatToKorean(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final description = _descriptionController.text.trim();
      final cleanAmountText = _amountController.text.replaceAll(',', '').trim();
      final amount = double.tryParse(cleanAmountText) ?? 0.0;

      final investment = Investment(
        id: widget.initialData?.id,
        description: description,
        amount: amount,
        createdAt: widget.initialData?.createdAt, // 기존 생성일자 유지
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
    return AlertDialog(
      title: Text(_isEditing ? '투자 내역 수정' : '투자 내역 등록'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. 날짜 선택 입력 항목 추가
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                // 키보드가 뜨지 않고 클릭 이벤트만 받도록 설정
                child: TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: '날짜',
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 2. 적요 입력
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: '적요'),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return '적요를 입력해 주세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // 3. 금액 입력
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
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
                final cleanVal = val.replaceAll(',', '').trim();
                if (double.tryParse(cleanVal) == null) {
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
          child:
              _isSubmitting
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
