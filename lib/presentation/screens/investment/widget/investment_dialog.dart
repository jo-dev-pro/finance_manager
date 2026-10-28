import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../models/investment/investment.dart';
import '../../../../providers/investment/investment_provider.dart';

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

    if (widget.initialData?.createdAt != null) {
      _selectedDate = widget.initialData!.createdAt!;
    }
    _dateController = TextEditingController(
      text: DateHelper.formatToDate(_selectedDate),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await DateHelper.pickDate(
      context,
      initialDate: _selectedDate,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateHelper.formatToDate(picked);
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
        createdAt: widget.initialData?.createdAt,
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
    // 키보드가 올라올 때 화면이 밀리거나 가려지는 것을 방지하기 위해 viewInsets 활용
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
              // 상단 타이틀 및 닫기 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? '투자 내역 수정' : '투자 내역 등록',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // 1. 날짜 선택
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: '날짜',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. 적요 입력
              TextFormField(
                controller: _descriptionController,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: '적요',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '적요를 입력해 주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 3. 투자금액 입력
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
                  border: OutlineInputBorder(),
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
              const SizedBox(height: 24),

              // 하단 버튼 영역 (좌우 꽉 찬 버튼)
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
                            width: 24,
                            height: 24,
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
