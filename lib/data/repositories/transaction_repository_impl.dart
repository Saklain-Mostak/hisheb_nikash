import '../../domain/repositories/transaction_repository.dart';
import '../datasources/hive_service.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final HiveService _hiveService;

  TransactionRepositoryImpl(this._hiveService);

  @override
  List<TransactionModel> getAllTransactions() {
    final list = _hiveService.transactionBox.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  TransactionModel? getTransactionById(String id) {
    return _hiveService.transactionBox.get(id);
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    await _hiveService.transactionBox.put(transaction.id, transaction);
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _hiveService.transactionBox.put(transaction.id, transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _hiveService.transactionBox.delete(id);
  }

  @override
  Stream<List<TransactionModel>> watchTransactions() async* {
    yield getAllTransactions();
    yield* _hiveService.transactionBox.watch().map((_) => getAllTransactions());
  }
}
