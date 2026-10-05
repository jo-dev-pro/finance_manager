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
  late TextEditingController _orderController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.type?.name ?? '');
    _orderController = TextEditingController(
      text: (widget.type?.displayOrder ?? 0).toString(),
    );
    _isActive = widget.type?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.type != null;

    return AlertDialog(
      title: Text(isEdit ? '거래구분 수정' : '거래구분 추가'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 12),
            TextFormField(
              controller: _orderController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '표시 순서'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('사용 여부'),
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
            ),
          ],
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
    final order = int.tryParse(_orderController.text) ?? 0;
    final notifier = ref.read(pensionTransactionTypeNotifierProvider.notifier);

    if (widget.type != null) {
      final updated = widget.type!.copyWith(
        name: name,
        displayOrder: order,
        isActive: _isActive,
      );
      await notifier.updatePensionTransactionType(updated);
    } else {
      await notifier.addPensionTransactionType(
        PensionTransactionType(
          name: name,
          displayOrder: order,
          isActive: _isActive,
        ),
      );
    }

    if (mounted) Navigator.pop(context);
  }
}
