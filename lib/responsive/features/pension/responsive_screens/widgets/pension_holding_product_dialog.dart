import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/date_helper.dart';
import '../../../../../models/pension/pension_holding_product.dart';
import '../../../../../models/pension/pension_product.dart';
import '../../../../../providers/account/account_name_provider.dart';
import '../../../../../providers/account/account_provider.dart';
import '../../../../../providers/pension/pension_holding_product_provider.dart';
import '../../../../../providers/pension/pension_product_provider.dart';

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
        _selectedDate = DateFormat(
          'yyyy-MM-dd',
        ).parse(widget.initialData!.initialPurchaseDate!);
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

  // 💡 선택된 상품명이 "현금성자산" 또는 "현금", "예수금"을 포함하는지 정확히 판별
  bool _checkIsCashAsset(List<PensionProduct> products) {
    if (_selectedProductId == null) return false;
    final matchedProduct = products.firstWhere(
      (p) => p.id == _selectedProductId,
      orElse: () => PensionProduct(id: '', productName: ''),
    );
    final name = matchedProduct.productName.replaceAll(' ', '').toLowerCase();
    return name.contains('현금성자산') ||
        name.contains('현금') ||
        name.contains('예수금');
  }

  Future<void> _submit(List<PensionProduct> products) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null || _selectedProductId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('계좌와 상품을 모두 선택해 주세요.')));
      return;
    }

    final isCash = _checkIsCashAsset(products);

    try {
      // 💡 현금성 자산일 경우 매수일은 null로 저장
      final dateText = _dateController.text.trim();
      final finalPurchaseDate =
          isCash ? null : (dateText.isNotEmpty ? dateText : null);

      final item = PensionHoldingProduct(
        id: widget.initialData?.id,
        accountId: _selectedAccountId!,
        productId: _selectedProductId!,
        isActive: _isActive,
        initialPurchaseDate: finalPurchaseDate,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      }
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
          child: productsAsync.when(
            loading:
                () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
            error: (err, _) => Text('데이터 로딩 실패: $err'),
            data: (products) {
              if (_selectedProductId == null && products.isNotEmpty) {
                _selectedProductId = products.first.id;
              }

              // 💡 현재 선택된 상품이 현금성 자산인지 실시간 확인
              final isCash = _checkIsCashAsset(products);

              return Column(
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

                  // 1. 연금 계좌 선택
                  accountsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (err, _) => Text('계좌 로딩 실패: $err'),
                    data: (accounts) {
                      final accountNames = accountNamesAsync.value ?? [];
                      final pensionAccounts =
                          accounts
                              .where((a) => a.accountType.toUpperCase() == '연금')
                              .toList()
                            ..sort(
                              (a, b) => a.sortOrder.compareTo(b.sortOrder),
                            );

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

                  // 2. 상품 선택 (콤보박스)
                  if (products.isEmpty)
                    const Text('등록된 연금 보유상품이 없습니다.')
                  else
                    DropdownButtonFormField<String>(
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
                          _selectedProductId =
                              val; // 선택 변경 시 setState로 화면 갱신되어 매수일 영역 즉시 토글됨
                        });
                      },
                    ),
                  const SizedBox(height: 16),

                  // 💡 3. "현금성자산"이 아닐 때만 최초 매수일 입력 필드 노출
                  if (!isCash) ...[
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
                            if (!isCash &&
                                (val == null || val.trim().isEmpty)) {
                              return '최초 매수일을 입력해 주세요.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 4. 활동 상태 스위치
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

                  // 5. 저장 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                  child: ElevatedButton(
                  onPressed: () => _submit(products),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
