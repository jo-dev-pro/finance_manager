// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';

// import '../../../../core/utils/number_formatter.dart';
// import '../../../../core/widgets/main_constrainedbox.dart';
// import '../../../../core/widgets/summary_item.dart';
// import '../../../../providers/account/account_name_provider.dart';
// import '../../../../providers/account/account_provider.dart';
// import '../../../../providers/dashboard/dashboard_provider.dart';
// import '../../../../providers/monthly_data/monthly_pension_balance_provider.dart';
// import '../../../../providers/monthly_data/monthly_pension_account_balance_provider.dart';
// import '../../../../providers/pension/pension_product_provider.dart';
// import 'widgets/monthly_pension_account_summary_list.dart';

// final selectedPensionAccountFilterProvider = StateProvider.autoDispose<String?>((ref) => null);

// class MonthlyPensionSummaryScreenCopy extends ConsumerWidget {
//   final String? initialYearMonth;

//   const MonthlyPensionSummaryScreenCopy({super.key, this.initialYearMonth});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final selectedMonth = ref.watch(selectedYearMonthProvider);
//     final targetMonth =
//         selectedMonth ??
//         initialYearMonth ??
//         DateFormat('yyyy-MM').format(DateTime.now());

//     final selectedAccountId = ref.watch(selectedPensionAccountFilterProvider);

//     final balancesAsync = ref.watch(
//       monthlyPensionBalanceNotifierProvider(targetMonth),
//     );
//     final accountBalancesAsync = ref.watch(
//       monthlyPensionAccountBalanceNotifierProvider(targetMonth),
//     );
//     final accountsAsync = ref.watch(accountNotifierProvider);
//     final accountNamesAsync = ref.watch(accountNameNotifierProvider);
//     final productsAsync = ref.watch(pensionProductNotifierProvider);
//     final availableMonthsAsync = ref.watch(availableYearMonthsProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('연금 월말평가'),
//       ),
//       body: availableMonthsAsync.when(
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, stack) => Center(child: Text('데이터를 불러오지 못했습니다: $err')),
//         data: (months) {
//           if (months.isEmpty) {
//             return const Center(child: Text('등록된 연금 데이터가 없습니다.'));
//           }

//           final activeCurrentMonth =
//               (selectedMonth != null && months.contains(selectedMonth))
//                   ? selectedMonth
//                   : months.first;

//           if (selectedMonth == null || !months.contains(selectedMonth)) {
//             Future.microtask(() {
//               ref
//                   .read(selectedYearMonthProvider.notifier)
//                   .select(activeCurrentMonth);
//             });
//           }

//           final accounts = accountsAsync.value ?? [];
//           final accountNames = accountNamesAsync.value ?? [];
//           final products = productsAsync.value ?? [];
//           final accountBalances = accountBalancesAsync.value ?? [];
//           final items = balancesAsync.value ?? [];

//           final accountMap = {for (var a in accounts) a.id!: a};
//           final accountNameMap = {for (var an in accountNames) an.id: an};
//           final productMap = {for (var p in products) p.id!: p.productName};
//           final accountBalanceMap = {for (var ab in accountBalances) ab.accountId: ab};

//           final pensionAccounts = accounts
//               .where((a) => a.accountType.trim() == '연금' && a.status == '활동')
//               .toList();

//           final filteredAccountBalances = selectedAccountId == null
//               ? accountBalances
//               : accountBalances.where((ab) => ab.accountId == selectedAccountId).toList();

//           final filteredPensionItems = selectedAccountId == null
//               ? items
//               : items.where((item) => item.accountId == selectedAccountId).toList();

//           double totalPensionBalance = 0;
//           double totalPensionPrincipal = 0;
//           double totalCashBalance = 0;

//           for (var b in filteredPensionItems) {
//             totalPensionBalance += b.balance;
//             totalPensionPrincipal += b.principal;
//           }

//           for (var ab in filteredAccountBalances) {
//             totalCashBalance += ab.cashBalance;
//           }

//           final grandTotalBalance = totalPensionBalance + totalCashBalance;
//           final totalProfit = (grandTotalBalance) - totalPensionPrincipal;

//           return MainConstrainedBox(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 상단 기준년월 & 계좌선택 콤보박스
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade400),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: DropdownButtonHideUnderline(
//                             child: DropdownButton<String>(
//                               value: months.contains(activeCurrentMonth) ? activeCurrentMonth : months.first,
//                               isExpanded: true,
//                               items: months.map((ym) {
//                                 return DropdownMenuItem(
//                                   value: ym,
//                                   child: Text(ym, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                                 );
//                               }).toList(),
//                               onChanged: (val) {
//                                 if (val != null) {
//                                   ref.read(selectedYearMonthProvider.notifier).select(val);
//                                 }
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         flex: 2,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade400),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: DropdownButtonHideUnderline(
//                             child: DropdownButton<String?>(
//                               value: selectedAccountId,
//                               isExpanded: true,
//                               hint: const Text('전체 계좌'),
//                               items: [
//                                 const DropdownMenuItem<String?>(
//                                   value: null,
//                                   child: Text('전체 계좌', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                                 ),
//                                 ...pensionAccounts.map((acc) {
//                                   final accId = acc.id ?? '';
//                                   final nameObj = accountNameMap[acc.accountNameId];
//                                   final accName = nameObj?.accountName ?? '계좌';
//                                   final institution = acc.financialInstitution;
//                                   return DropdownMenuItem<String?>(
//                                     value: accId,
//                                     child: Text(
//                                       '$institution$accName',
//                                       style: const TextStyle(fontSize: 14),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   );
//                                 }),
//                               ],
//                               onChanged: (val) {
//                                 ref.read(selectedPensionAccountFilterProvider.notifier).state = val;
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),

//                   // 요약 카드
//                   Card(
//                     elevation: 0,
//                     color: Colors.indigo.shade50,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       side: BorderSide(color: Colors.indigo.shade100),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           SummaryItem(label: '총 자산', value: grandTotalBalance.toWon()),
//                           SummaryItem(label: '총 원금', value: totalPensionPrincipal.toWon()),
//                           SummaryItem(
//                             label: '평가 손익',
//                             value: '${totalProfit >= 0 ? '+' : ''}${totalProfit.toWon()}',
//                             color: totalProfit >= 0 ? Colors.red.shade700 : Colors.blue.shade700,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   const Text(
//                     '계좌별 현금 및 자금 요약',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),

//                   // 조회 전용 계좌 요약 리스트 (수정 콜백 제외 또는 뷰 전용)
//                   MonthlyPensionAccountSummaryList(
//                     pensionAccounts: pensionAccounts,
//                     accountNameMap: accountNameMap,
//                     accountBalanceMap: accountBalanceMap,
//                     selectedAccountId: selectedAccountId,
//                     targetMonth: activeCurrentMonth,
//                     onEditPressed: null, // 요약 화면이므로 수정 버튼 비활성화 또는 미표시
//                   ),

//                   const SizedBox(height: 20),
//                   const Text(
//                     '보유 상품별 월말 내역',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),

//                   if (filteredPensionItems.isEmpty)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 20),
//                       child: Center(child: Text('$activeCurrentMonth에 등록된 연금 월말 데이터가 없습니다.')),
//                     )
//                   else
//                     ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: filteredPensionItems.length,
//                       itemBuilder: (context, index) {
//                         final balanceItem = filteredPensionItems[index];

//                         final matchedAcc = accountMap[balanceItem.accountId];
//                         final institution =
//                             matchedAcc?.financialInstitution ?? '기타 금융기관';
//                         final nameObj =
//                             matchedAcc != null
//                                 ? accountNameMap[matchedAcc.accountNameId]
//                                 : null;
//                         final accountName = nameObj?.accountName ?? '연금계좌';

//                         final bool isCashAsset =
//                             balanceItem.productId ==
//                             '_CASH_ASSET_PRODUCT_ID_';
//                         final String displayName =
//                             isCashAsset
//                                 ? '💵 계좌 공통 현금성 자산 (예수금)'
//                                 : (productMap[balanceItem.productId] ??
//                                     '알 수 없는 상품');

//                         return Padding(
//                           padding: const EdgeInsets.only(bottom: 12),
//                           child: Card(
//                             elevation: 1.5,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(16),
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           displayName,
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 15,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 6),
//                                         Text(
//                                           '[$institution]$accountName',
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.grey.shade600,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         if (!isCashAsset && balanceItem.purchaseDate != null && balanceItem.purchaseDate!.isNotEmpty) ...[
//                                           const SizedBox(height: 4),
//                                           Text(
//                                             '최초 매수일: ${balanceItem.purchaseDate}',
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               color: Colors.indigo.shade600,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ],
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Text(
//                                     balanceItem.balance.toWon(),
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 15,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }