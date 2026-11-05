import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/date_helper.dart';
import '../../../../../core/utils/number_formatter.dart';
import '../../../../../models/investment/investment.dart';
import '../../../../../providers/investment/investment_provider.dart';

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

  // 날짜를 String('yyyy-MM-dd') 형태로 관리
  late String _selectedDateStr;

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

    // 초기 날짜 설정 (데이터가 있으면 해당 값, 없으면 오늘 날짜 'yyyy-MM-dd')
    if (widget.initialData?.createdAt != null && widget.initialData!.createdAt!.isNotEmpty) {
      _selectedDateStr = widget.initialData!.createdAt!;
    } else {
      _selectedDateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }

    _dateController = TextEditingController(text: _selectedDateStr);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    // 기존 선택된 String을 DateTime으로 변환하여 피커에 전달
    DateTime initialDateTime = DateTime.tryParse(_selectedDateStr) ?? DateTime.now();

    final picked = await DateHelper.pickDate(
      context,
      initialDate: initialDateTime,
    );
    if (picked != null) {
      setState(() {
        _selectedDateStr = DateFormat('yyyy-MM-dd').format(picked);
        _dateController.text = _selectedDateStr;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final description = _descriptionController.text.trim();
      final cleanAmountText = _amountController.text.replaceAll(',', '').trim();
      final amount = double.tryParse(cleanAmountText) ?? 0.0;

      final investment = Investment(
        id: widget.initialData?.id,
        description: description,
        amount: amount,
        createdAt: _selectedDateStr, // 수정된 String 날짜 전달
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

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
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