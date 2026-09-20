import 'package:flutter/material.dart';

import 'account_screen.dart';
import 'investment_screen.dart';
import 'pension_product_screen.dart';
import 'stock_item_screen.dart';


class AllMenuScreen extends StatelessWidget {
  const AllMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: Center(
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.monetization_on_outlined),
              title: Text('투자금 관리'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const InvestmentScreen(),
                  ),
                );
              },
            ),
        SizedBox(height: 20),

        ListTile(
              leading: Icon(Icons.monetization_on_outlined),
              title: Text('계좌 관리'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AccountScreen(),
                  ),
                );
              },
            ),
        SizedBox(height: 20),

        ListTile(
              leading: Icon(Icons.monetization_on_outlined),
              title: Text('주식 종목명 관리'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const StockItemScreen(),
                  ),
                );
              },
            ),
        SizedBox(height: 20),

        ListTile(
              leading: Icon(Icons.monetization_on_outlined),
              title: Text('연금 상품명 관리'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PensionProductScreen(),
                  ),
                );
              },
            ),
          ],
        ),



      ),
    );
  }
}
