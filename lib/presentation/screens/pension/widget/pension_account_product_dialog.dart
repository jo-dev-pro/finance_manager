import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../models/pension/pension_account_product.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/pension/pension_account_product_provider.dart';
import '../../../../providers/pension/pension_product_provider.dart';

class PensionAccountProductDialog extends ConsumerStatefulWidget {
  final PensionAccountProduct? initialData;

  const PensionAccountProductDialog({super.key, this.initialData});

  @override
  ConsumerState<PensionAccountProductDialog> createState() =>
      _PensionAccountProductDialogState();
}

class _PensionAccountProductDialogState
    extends ConsumerState<PensionAccountProductDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedAccountId;
  String? _selectedProductId;
  late TextEditingController _principalController;
  late TextEditingController _dateController;

  bool _isSubmitting = false;
  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.initialData?.accountId;
    _selectedProductId = widget.initialData?.productId;

    _principalController = TextEditingController(
      text:
          widget.initialData != null && widget.initialData!.principal > 0
              ? widget.initialData!.principal.toCommaString()
              : '',
    );
    _dateController = TextEditingController(
      text: widget.initialData?.purchaseDate ?? '',
    );
  }

  @override
  void dispose() {
    _principalController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null || _selectedProductId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('계좌와 상품을 모두 선택해 주세요.')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final cleanPrincipal =
          _principalController.text.replaceAll(RegExp(r'[^0-9]'), '').trim();
      final principalVal = double.tryParse(cleanPrincipal) ?? 0.0;
      final dateText = _dateController.text.trim();

      final item = PensionAccountProduct(
        id: widget.initialData?.id,
        accountId: _selectedAccountId!,
        productId: _selectedProductId!,
        principal: principalVal,
        purchaseDate: dateText.isNotEmpty ? dateText : null,
      );

      final notifier = ref.read(pensionAccountProductNotifierProvider.notifier);
      if (_isEditing) {
        await notifier.updatePensionAccountProduct(item);
      } else {
        await notifier.addPensionAccountProduct(item);
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
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final productsAsync = ref.watch(pensionProductNotifierProvider);

    return AlertDialog(
      title: Text(_isEditing ? '계좌별 보유상품 수정' : '계좌별 상품 등록'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 연금 계좌 선택 콤보박스
                accountsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('계좌 로딩 실패: $err'),
                  data: (accounts) {
                    final accountNames = accountNamesAsync.value ?? [];
                    final pensionAccounts =
                        accounts
                            .where(
                              (a) =>
                                  a.accountType.toUpperCase() == '연금' &&
                                  a.status == '활동',
                            )
                            .toList();

                    if (pensionAccounts.isEmpty) {
                      return const Text('활동 중인 연금 계좌가 없습니다.');
                    }

                    final accountNameMap = {
                      for (var an in accountNames) an.id: an,
                    };

                    if (_selectedAccountId == null &&
                        pensionAccounts.isNotEmpty) {
                      _selectedAccountId = pensionAccounts.first.id;
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: _selectedAccountId,
                      decoration: const InputDecoration(
                        labelText: '연금 계좌 선택',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          pensionAccounts.map((acc) {
                            final institution = acc.financialInstitution;
                            final nameObj = accountNameMap[acc.accountNameId];
                            return DropdownMenuItem(
                              value: acc.id,
                              child: Text(
                                '$institution - ${nameObj?.accountName ?? '계좌'}',
                              ),
                            );
                          }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedAccountId = val;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 2. 공용 상품 마스터 선택 콤보박스
                productsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('상품 로딩 실패: $err'),
                  data: (products) {
                    if (products.isEmpty) {
                      return const Text('등록된 연금 상품이 없습니다. 먼저 상품을 추가해 주세요.');
                    }

                    if (_selectedProductId == null && products.isNotEmpty) {
                      _selectedProductId = products.first.id;
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: _selectedProductId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: '상품 선택',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          products.map((prod) {
                            return DropdownMenuItem(
                              value: prod.id,
                              child: Text(
                                prod.productName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedProductId = val;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 3. 최초 투자 원금 입력
                TextFormField(
                  controller: _principalController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: '최초 투자 원금',
                    suffixText: '원',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return '투자 원금을 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 4. 최초 매수일 입력 (연환산 수익률 산출용)
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: '최초 매수일',
                    hintText: 'YYYY-MM-DD',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _dateController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(picked);
                      });
                    }
                  },
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return '최초 매수일을 선택해 주세요.';
                    }
                    return null;
                  },
                ),
              ],
            ),
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
