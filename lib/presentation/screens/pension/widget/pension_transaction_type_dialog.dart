import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/pension/pension_transaction_type.dart';
import '../../../../providers/pension/pension_transaction_type_provider.dart';

class PensionTransactionTypeFormDialog extends ConsumerStatefulWidget {
  final PensionTransactionType? type;

  const PensionTransactionTypeFormDialog({super.key, this.type});

  @override
  ConsumerState<PensionTransactionTypeFormDialog> createState() =>
      _PensionTransactionTypeFormDialogState();
}

class _PensionTransactionTypeFormDialogState
    extends ConsumerState<PensionTransactionTypeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _amountSign; // 💡 금액 부호 상태 추가 ('PLUS' 또는 'MINUS')

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.type?.typeName ?? '');
    _amountSign = widget.type?.amountSign ?? 'PLUS'; // 💡 초기 부호 설정 (기본값 'PLUS')
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.type != null;

    return AlertDialog(
      title: Text(isEdit ? '거래구분 수정' : '거래구분 추가'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '구분명 (예: 입금, 출금, 해지)',
                ),
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty ? '구분명을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),

              // 💡 금액 부호 (+ / -) 선택 (SegmentedButton)
              const Text(
                '금액 영향 (부호)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: 'PLUS',
                      label: Text('+ (증가/입금)'),
                      icon: Icon(Icons.add, color: Colors.red),
                    ),
                    ButtonSegment<String>(
                      value: 'MINUS',
                      label: Text('- (감소/출금)'),
                      icon: Icon(Icons.remove, color: Colors.blue),
                    ),
                  ],
                  selected: {_amountSign},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _amountSign = newSelection.first;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(onPressed: _save, child: Text(isEdit ? '수정' : '저장')),
      ],
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final notifier = ref.read(pensionTransactionTypeNotifierProvider.notifier);

    if (widget.type != null) {
      final updated = widget.type!.copyWith(
        typeName: name,
        amountSign: _amountSign, // 💡 변경된 금액 부호 반영
      );
      await notifier.updatePensionTransactionType(updated);
    } else {
      await notifier.addPensionTransactionType(
        PensionTransactionType(
          typeName: name,
          amountSign: _amountSign, // 💡 금액 부호 전달
        ),
      );
    }

    if (mounted) Navigator.pop(context);
  }
}