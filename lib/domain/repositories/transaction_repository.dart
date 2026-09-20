import '../../data/models/transaction_model.dart';

abstract class TransactionRepository {
  List<TransactionModel> getAllTransactions();
  TransactionModel? getTransactionById(String id);
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Stream<List<TransactionModel>> watchTransactions();
}
