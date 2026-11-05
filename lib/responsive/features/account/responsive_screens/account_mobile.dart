import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/account/account_provider.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../models/account/account_name.dart';

class AccountMobileScreen extends ConsumerWidget {
  const AccountMobileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountState = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('계좌 관리 (모바일 - 조회 전용)'),
        // 모바일은 입력/수정 기능이 없으므로 actions(추가 버튼)를 아예 배치하지 않음
      ),
      body: accountState.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(
              child: Text(
                '등록된 계좌가 없습니다.',
                textAlign: TextAlign.center,
              ),
            );
          }

          final sortedAccounts = accounts.toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

          return accountNamesAsync.when(
            data: (accountNames) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedAccounts.length,
                itemBuilder: (context, index) {
                  final account = sortedAccounts[index];
                  final hasNumber = account.accountNumber != null && account.accountNumber!.isNotEmpty;
                  final accountName = _getAccountName(accountNames, account.accountNameId ?? '');

                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            backgroundImage: account.logoUrl != null && account.logoUrl!.isNotEmpty
                                ? NetworkImage(account.logoUrl!)
                                : null,
                            child: account.logoUrl == null || account.logoUrl!.isEmpty
                                ? Text(
                                    account.financialInstitution.isNotEmpty ? account.financialInstitution[0] : '?',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(accountName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    if (hasNumber) ...[
                                      const SizedBox(width: 6),
                                      Text('(${account.accountNumber})', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(account.financialInstitution, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                    const SizedBox(width: 6),
                                    Text(account.accountType, style: TextStyle(color: Colors.grey.shade800, fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // 모바일에서는 수정/삭제 버튼을 제공하지 않으므로 Row에 추가하지 않음 (조회 전용)
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('로드 실패: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('데이터 로드 실패: $err')),
      ),
    );
  }

  String _getAccountName(List<AccountName> accountNames, String accountNameId) {
    final match = accountNames.firstWhere(
      (an) => an.id == accountNameId,
      orElse: () => const AccountName(accountName: '알 수 없는 계좌명'),
    );
    return match.accountName;
  }
}