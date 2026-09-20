import 'package:flutter/material.dart';

class StockTranactionScreen extends StatelessWidget {
  const StockTranactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('증권')),
      body: const Center(child: Text('증권 거래 내역')),
    );
  }
}