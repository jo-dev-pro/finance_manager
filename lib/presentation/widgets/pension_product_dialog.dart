import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/pension_product.dart';
import '../../providers/account_provider.dart';
import '../../providers/pension_product_provider.dart';

class PensionProductDialog extends ConsumerStatefulWidget {
  final PensionProduct? initialData;

  const PensionProductDialog({super.key, this.initialData});

  @override
  ConsumerState<PensionProductDialog> createState() => _PensionProductDialogState();
}

class _PensionProductDialogState extends ConsumerState<PensionProductDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedAccountId; // 👈 accountName -> accountId 로 변경
  late TextEditingController _productNameController;
  String _status = '활동';
  bool _isSubmitting = false;

  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.initialData?.accountId; // 👈 accountId 매핑
    _productNameController = TextEditingController(
      text: widget.initialData?.productName ?? '',
    );
    _status = widget.initialData?.status ?? '활동';
  }

  @override
  void dispose() {
    _productNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final product = PensionProduct(
        id: widget.initialData?.id,
        accountId: _selectedAccountId!, // 👈 accountId 저장
        productName: _productNameController.text.trim(),
        status: _status,
      );

      final notifier = ref.read(pensionProductNotifierProvider.notifier);
      if (_isEditing) {
        await notifier.updatePensionProduct(product);
      } else {
        await notifier.addPensionProduct(product);
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
    final accountState = ref.watch(accountNotifierProvider);

    return AlertDialog(
      title: Text(_isEditing ? '연금상품 수정' : '연금상품 등록'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 계좌선택 (연금 계좌 필터링 콤보박스)
              accountState.when(
                data: (accounts) {
                  final pensionAccounts = accounts.where((acc) {
                    final type = acc.accountType.toUpperCase();
                    return type == '연금';
                  }).toList();

                  // 👈 acc.id 기준으로 선택 존재 여부 확인
                  final initialExists = pensionAccounts.any(
                    (acc) => acc.id == _selectedAccountId,
                  );

                  if (pensionAccounts.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        '등록된 연금 계좌가 없습니다.\n계좌 관리에서 먼저 연금 계좌를 등록해 주세요.',
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: initialExists ? _selectedAccountId : null, // 👈 id 값 사용
                    decoration: const InputDecoration(
                      labelText: '연금 계좌',
                      hintText: '계좌 선택',
                    ),
                    items: pensionAccounts.map((acc) {
                      return DropdownMenuItem<String>(
                        value: acc.id, // 👈 드롭다운 value를 계좌 ID로 지정
                        child: Text('${acc.financialInstitution} - ${acc.accountName}'), // 화면에는 금융사와 계좌명 표시
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedAccountId = val);
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return '계좌를 선택해 주세요.';
                      }
                      return null;
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(),
                ),
                error: (err, stack) => Text(
                  '계좌 목록 로드 실패: $err',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),

              // 상품명 입력
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: '상품명',
                  hintText: '예: TIGER 미국S&P500, 현금성 자산',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '상품명을 입력해 주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // 상태 선택
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: '상태'),
                items: const [
                  DropdownMenuItem(value: '활동', child: Text('활동')),
                  DropdownMenuItem(value: '해지', child: Text('해지')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
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