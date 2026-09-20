import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/providers/firestore_provider.dart';
import '../models/investment.dart';

part 'investment_provider.g.dart';

@riverpod
class InvestmentNotifier extends _$InvestmentNotifier {
  @override
  Future<List<Investment>> build() async {
    return fetchInvestments();
  }

  Future<List<Investment>> fetchInvestments() async {
    final firestore = ref.read(firestoreProvider);
    final snapshot = await firestore
        .collection('investment')
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Investment.fromJson(data);
    }).toList();
  }

  Future<void> addInvestment(Investment investment) async {
    final firestore = ref.read(firestoreProvider);
    final data = investment.toJson()
      ..remove('id')
      ..removeWhere((key, value) => value == null);

    data['created_at'] = FieldValue.serverTimestamp();

    await firestore.collection('investment').add(data);
    ref.invalidateSelf();
  }

  Future<void> updateInvestment(Investment investment) async {
    if (investment.id == null) return;
    final firestore = ref.read(firestoreProvider);
    final data = investment.toJson()..remove('id');

    await firestore.collection('investment').doc(investment.id).update(data);
    ref.invalidateSelf();
  }

  Future<void> deleteInvestment(String id) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection('investment').doc(id).delete();
    ref.invalidateSelf();
  }
}