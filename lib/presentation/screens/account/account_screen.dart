import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/number_formatter.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../models/account/account.dart';
import '../../../models/account/account_name.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/account/account_provider.dart';
import 'widget/account_dialog.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('계좌 관리'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '계좌 추가',
            onPressed: () => _showAccountDialog(context, ref, null),
          ),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('계좌를 불러오지 못했습니다: $err')),
        data: (accounts) {
          return accountNamesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('계좌 명칭을 불러오지 못했습니다: $err')),
            data: (accountNames) {
              final accountNameMap = {for (var an in accountNames) an.id: an};

              if (accounts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('등록된 계좌가 없습니다.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAccountDialog(context, ref, null),
                        icon: const Icon(Icons.add),
                        label: const Text('첫 계좌 등록하기'),
                      ),
                    ],
                  ),
                );
              }

              // 자산 유형별 또는 상태별로 그룹화하거나 리스트 형태로 출력
              return MainConstrainedBox(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    final accountNameObj = accountNameMap[account.accountNameId];
                    final accountName = accountNameObj?.accountName ?? '지정 안됨';
                    final institution = account.financialInstitution;
                    final accountType = account.accountType;
                    final status = account.status;
                    final logoUrl = account.logoUrl;

                    // 💡 모델의 isForeignCurrency 겟터 및 currency 필드 활용
                    final isForeign = account.isForeignCurrency;
                    final currencyLabel = isForeign ? '외화 (USD)' : '원화 (KRW)';

                    return Card(
                      elevation: 1.5,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.shade50,
                          backgroundImage: (logoUrl != null && logoUrl.isNotEmpty) ? NetworkImage(logoUrl) : null,
                          child: (logoUrl == null || logoUrl.isEmpty)
                              ? const Icon(Icons.account_balance, color: Colors.indigo)
                              : null,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$institution - $accountName',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isForeign ? Colors.orange.shade50 : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isForeign ? Colors.orange.shade200 : Colors.blue.shade200,
                                ),
                              ),
                              child: Text(
                                currencyLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isForeign ? Colors.orange.shade800 : Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Text(
                                '유형: $accountType',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '상태: $status',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: status == '활동' ? Colors.green.shade700 : Colors.red.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                              onPressed: () => _showAccountDialog(context, ref, account),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                              onPressed: () => _confirmDelete(context, ref, account),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAccountDialog(BuildContext context, WidgetRef ref, Account? account) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AccountDialog(initialAccount: account),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Account account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('계좌 삭제'),
        content: Text('정말 "${account.financialInstitution} 계좌"를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(accountNotifierProvider.notifier).deleteAccount(account.id!);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}