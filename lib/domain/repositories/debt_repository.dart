import '../../data/models/debt_model.dart';
import '../entities/domain_enums.dart';

abstract class DebtRepository {
  List<DebtModel> getAllDebts();
  List<DebtModel> getDebtsByType(DebtType type);
  DebtModel? getDebtById(String id);
  Future<void> addDebt(DebtModel debt);
  Future<void> updateDebt(DebtModel debt);
  Future<void> recordPayment(String id, double additionalPaid);
  Future<void> deleteDebt(String id);
  Stream<List<DebtModel>> watchDebts();
}
