import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/account/account_provider.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../models/account/account.dart';
import '../../../models/account/account_name.dart';
import 'widget/account_dialog.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  void _showDeleteConfirmDialog(
      BuildContext context, WidgetRef ref, Account account, String productName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('계좌 삭제'),
        content: Text('\'$productName\' 계좌를 정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (account.id != null) {
                ref
                    .read(accountNotifierProvider.notifier)
                    .deleteAccount(account.id!);
              }
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _showFormDialog(BuildContext context, [Account? account]) {
    showDialog(
      context: context,
      builder: (_) => AccountDialog(initialAccount: account),
    );
  }

  String _getAccountName(List<AccountName> accountNames, String accountNameId) {
    final match = accountNames.firstWhere(
      (an) => an.id == accountNameId,
      orElse: () => const AccountName(accountName: '알 수 없는 계좌명'),
    );
    return match.accountName;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountState = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('계좌 관리')),
      body: accountState.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(
              child: Text('등록된 계좌가 없습니다.\n하단 버튼을 눌러 계좌를 추가해보세요.',
                  textAlign: TextAlign.center),
            );
          }

          return accountNamesAsync.when(
            data: (accountNames) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  final hasNumber = account.accountNumber != null &&
                      account.accountNumber!.isNotEmpty;

                  // 안전하게 null 체크 적용
                  final accountName = _getAccountName(
                    accountNames,
                    account.accountNameId ?? '',
                  );

                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            backgroundImage: account.logoUrl != null &&
                                    account.logoUrl!.isNotEmpty
                                ? NetworkImage(account.logoUrl!)
                                : null,
                            child: account.logoUrl == null ||
                                    account.logoUrl!.isEmpty
                                ? Text(
                                    account.financialInstitution.isNotEmpty
                                        ? account.financialInstitution[0]
                                        : '?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
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
                                    Text(
                                      accountName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (hasNumber) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        '(${account.accountNumber})',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      account.financialInstitution,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 6),
                                      width: 3,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade400,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        account.accountType,
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            color: Colors.grey.shade700,
                            onPressed: () => _showFormDialog(context, account),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: Colors.red.shade400,
                            onPressed: () => _showDeleteConfirmDialog(
                                context, ref, account, accountName),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('상품 목록 로드 실패: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('데이터 로드 실패: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('계좌 추가'),
      ),
    );
  }
}