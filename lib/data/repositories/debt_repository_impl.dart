import '../../domain/entities/domain_enums.dart';
import '../../domain/repositories/debt_repository.dart';
import '../datasources/hive_service.dart';
import '../models/debt_model.dart';

class DebtRepositoryImpl implements DebtRepository {
  final HiveService _hiveService;

  DebtRepositoryImpl(this._hiveService);

  @override
  List<DebtModel> getAllDebts() {
    final list = _hiveService.debtBox.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  List<DebtModel> getDebtsByType(DebtType type) {
    return getAllDebts().where((d) => d.type == type).toList();
  }

  @override
  DebtModel? getDebtById(String id) {
    return _hiveService.debtBox.get(id);
  }

  @override
  Future<void> addDebt(DebtModel debt) async {
    await _hiveService.debtBox.put(debt.id, debt);
  }

  @override
  Future<void> updateDebt(DebtModel debt) async {
    await _hiveService.debtBox.put(debt.id, debt);
  }

  @override
  Future<void> recordPayment(String id, double additionalPaid) async {
    final debt = _hiveService.debtBox.get(id);
    if (debt == null) return;

    final newPaid = debt.paidAmount + additionalPaid;
    final DebtStatus newStatus = newPaid >= debt.amount
        ? DebtStatus.paid
        : (newPaid > 0 ? DebtStatus.partiallyPaid : DebtStatus.pending);

    final updated = debt.copyWith(
      paidAmount: newPaid,
      status: newStatus,
    );

    await _hiveService.debtBox.put(id, updated);
  }

  @override
  Future<void> deleteDebt(String id) async {
    await _hiveService.debtBox.delete(id);
  }

  @override
  Stream<List<DebtModel>> watchDebts() async* {
    yield getAllDebts();
    yield* _hiveService.debtBox.watch().map((_) => getAllDebts());
  }
}
