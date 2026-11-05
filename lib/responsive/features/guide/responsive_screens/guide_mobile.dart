import 'package:flutter/material.dart';

import 'widgets/guide_common_tabs.dart';

class GuideMobileScreen extends StatelessWidget {
  const GuideMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('자산 관리 앱 사용 가이드'),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Colors.teal,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.info_outline), text: '개요 & DB규칙'),
              Tab(icon: Icon(Icons.account_balance), text: '은행 계좌'),
              Tab(icon: Icon(Icons.savings), text: '연금 계좌'),
              Tab(icon: Icon(Icons.show_chart), text: '주식 계좌'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OverviewGuideTab(),
            BankGuideTab(),
            PensionGuideTab(),
            StockGuideTab(),
          ],
        ),
      ),
    );
  }
}