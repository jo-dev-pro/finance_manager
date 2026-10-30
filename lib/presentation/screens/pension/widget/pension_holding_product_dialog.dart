import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/date_helper.dart';
import '../../../../models/pension/pension_holding_product.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/pension/pension_holding_product_provider.dart';
import '../../../../providers/pension/pension_product_provider.dart';

class PensionHoldingProductDialog extends ConsumerStatefulWidget {
  final PensionHoldingProduct? initialData;

  const PensionHoldingProductDialog({super.key, this.initialData});

  @override
  ConsumerState<PensionHoldingProductDialog> createState() =>
      _PensionHoldingProductDialogState();
}

class _PensionHoldingProductDialogState
    extends ConsumerState<PensionHoldingProductDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedAccountId;
  String? _selectedProductId;
  late TextEditingController _dateController;
  bool _isActive = true;

  bool _isSubmitting = false;
  bool get _isEditing => widget.initialData != null;

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.initialData?.accountId;
    _selectedProductId = widget.initialData?.productId;
    _isActive = widget.initialData?.isActive ?? true;

    if (widget.initialData?.initialPurchaseDate != null &&
        widget.initialData!.initialPurchaseDate!.isNotEmpty) {
      try {
        _selectedDate = DateFormat('yyyy-MM-dd')
            .parse(widget.initialData!.initialPurchaseDate!);
      } catch (_) {
        _selectedDate = DateTime.now();
      }
    }

    _dateController = TextEditingController(
      text: DateHelper.formatToDate(_selectedDate),
    );
  }

  @override
  void dispose() {
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
    if (_selectedAccountId == null || _selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계좌와 상품을 모두 선택해 주세요.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dateText = _dateController.text.trim();

      final item = PensionHoldingProduct(
        id: widget.initialData?.id,
        accountId: _selectedAccountId!,
        productId: _selectedProductId!,
        isActive: _isActive,
        initialPurchaseDate: dateText.isNotEmpty ? dateText : null,
      );

      final notifier = ref.read(pensionHoldingProductNotifierProvider.notifier);
      if (_isEditing) {
        await notifier.updatePensionHoldingProduct(item);
      } else {
        await notifier.addPensionHoldingProduct(item);
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
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final productsAsync = ref.watch(pensionProductNotifierProvider);

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
                    _isEditing ? '계좌별 보유상품 수정' : '계좌별 상품 등록',
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
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Text(
                  '💡 안내: 이 화면에서는 계좌별 상품의 [활동 여부]와 [최초 매수일]을 설정합니다.\n'
                  '평가액 및 원금 변동은 [월말 연금 입력] 화면에서 관리하세요!',
                  style: TextStyle(fontSize: 12, color: Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 16),

              accountsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('계좌 로딩 실패: $err'),
                data: (accounts) {
                  final accountNames = accountNamesAsync.value ?? [];
                  final pensionAccounts = accounts
                      .where(
                        (a) => a.accountType.toUpperCase() == '연금',
                      )
                      .toList()
                    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                  if (pensionAccounts.isEmpty) {
                    return const Text('등록된 연금 계좌가 없습니다.');
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
                    items: pensionAccounts.map((acc) {
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

              productsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('상품 로딩 실패: $err'),
                data: (products) {
                  if (products.isEmpty) {
                    return const Text('등록된 연금 상품이 없습니다.');
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
                    items: products.map((prod) {
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

              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: '최초 매수일',
                      hintText: 'YYYY-MM-DD',
                      suffixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return '최초 매수일을 입력해 주세요.';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('상품 활동 상태'),
                subtitle: const Text('현재 운용 중인 상품인 경우 켜기'),
                value: _isActive,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setState(() {
                    _isActive = val;
                  });
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
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