import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection {
    return _firestore.collection(AppConstants.usersCollection);
  }

  CollectionReference<Map<String, dynamic>> _transactionsCollection(
    String uid,
  ) {
    return _usersCollection
        .doc(uid)
        .collection(AppConstants.transactionsCollection);
  }

  CollectionReference<Map<String, dynamic>> _budgetsCollection(String uid) {
    return _usersCollection.doc(uid).collection(AppConstants.budgetsCollection);
  }

  Future<void> saveUser(UserModel user) {
    return _usersCollection
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUser(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _usersCollection.doc(uid).get();

    final Map<String, dynamic>? data = snapshot.data();
    if (!snapshot.exists || data == null) {
      return null;
    }
    return UserModel.fromMap(data);
  }

  Stream<List<TransactionModel>> streamTransactions(String uid) {
    return _transactionsCollection(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs.map((
            QueryDocumentSnapshot<Map<String, dynamic>> doc,
          ) {
            final Map<String, dynamic> data = doc.data();
            data['id'] ??= doc.id;
            return TransactionModel.fromMap(data);
          }).toList();
        });
  }

  Future<void> addTransaction(String uid, TransactionModel transaction) async {
    final DocumentReference<Map<String, dynamic>> doc = transaction.id.isEmpty
        ? _transactionsCollection(uid).doc()
        : _transactionsCollection(uid).doc(transaction.id);

    final Map<String, dynamic> payload =
        transaction.copyWith(id: doc.id, updatedAt: DateTime.now()).toMap()
          ..removeWhere((String key, dynamic value) => value == null);

    await doc.set(payload);
  }

  Future<void> updateTransaction(
    String uid,
    TransactionModel transaction,
  ) async {
    final Map<String, dynamic> payload =
        transaction.copyWith(updatedAt: DateTime.now()).toMap()
          ..removeWhere((String key, dynamic value) => value == null);

    await _transactionsCollection(
      uid,
    ).doc(transaction.id).set(payload, SetOptions(merge: true));
  }

  Future<void> deleteTransaction(String uid, String transactionId) {
    return _transactionsCollection(uid).doc(transactionId).delete();
  }

  Future<void> deleteAllTransactions(String uid) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _transactionsCollection(uid).get();

    final WriteBatch batch = _firestore.batch();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Stream<BudgetModel?> streamBudgetForMonth(String uid, DateTime date) {
    return _budgetsCollection(uid).doc(budgetDocumentId(date)).snapshots().map((
      DocumentSnapshot<Map<String, dynamic>> snapshot,
    ) {
      final Map<String, dynamic>? data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }
      return BudgetModel.fromMap(data);
    });
  }

  Future<void> upsertBudget(String uid, BudgetModel budget) {
    final Map<String, dynamic> payload = budget.toMap()
      ..removeWhere((String key, dynamic value) => value == null);

    return _budgetsCollection(
      uid,
    ).doc(budget.id).set(payload, SetOptions(merge: true));
  }

  static String budgetDocumentId(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }
}
