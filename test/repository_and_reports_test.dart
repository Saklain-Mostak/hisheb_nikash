import 'package:flutter_test/flutter_test.dart';
import 'package:hisab_nikash/data/models/debt_model.dart';
import 'package:hisab_nikash/data/models/transaction_model.dart';
import 'package:hisab_nikash/domain/entities/domain_enums.dart';

void main() {
  group('Reports Aggregation Logic Tests', () {
    final testTransactions = [
      TransactionModel(
        id: '1',
        amount: 8500.0,
        type: TransactionType.expense,
        categoryId: 'cat_food',
        date: DateTime(2026, 9, 2),
      ),
      TransactionModel(
        id: '2',
        amount: 6200.0,
        type: TransactionType.expense,
        categoryId: 'cat_shopping',
        date: DateTime(2026, 9, 3),
      ),
      TransactionModel(
        id: '3',
        amount: 4500.0,
        type: TransactionType.expense,
        categoryId: 'cat_transport',
        date: DateTime(2026, 9, 4),
      ),
      TransactionModel(
        id: '4',
        amount: 3800.0,
        type: TransactionType.expense,
        categoryId: 'cat_food',
        date: DateTime(2026, 9, 5),
      ),
      TransactionModel(
        id: '5',
        amount: 50000.0,
        type: TransactionType.income,
        categoryId: 'cat_salary',
        date: DateTime(2026, 9, 1),
      ),
    ];

    test('Computes total income and total expense correctly', () {
      double totalIncome = 0;
      double totalExpense = 0;

      for (final tx in testTransactions) {
        if (tx.type == TransactionType.income) {
          totalIncome += tx.amount;
        } else {
          totalExpense += tx.amount;
        }
      }

      expect(totalIncome, 50000.0);
      expect(totalExpense, 23000.0); // 8500 + 6200 + 4500 + 3800
      expect(totalIncome - totalExpense, 27000.0);
    });

    test('Identifies highest single expense transaction correctly', () {
      TransactionModel? highestExpense;
      for (final tx in testTransactions) {
        if (tx.type == TransactionType.expense) {
          if (highestExpense == null || tx.amount > highestExpense.amount) {
            highestExpense = tx;
          }
        }
      }

      expect(highestExpense, isNotNull);
      expect(highestExpense!.id, '1');
      expect(highestExpense.amount, 8500.0);
    });

    test('Aggregates spend by category and identifies top spending category', () {
      final Map<String, double> categorySpendMap = {};
      double totalExpense = 0;

      for (final tx in testTransactions) {
        if (tx.type == TransactionType.expense) {
          totalExpense += tx.amount;
          categorySpendMap[tx.categoryId] =
              (categorySpendMap[tx.categoryId] ?? 0) + tx.amount;
        }
      }

      expect(categorySpendMap['cat_food'], 12300.0); // 8500 + 3800
      expect(categorySpendMap['cat_shopping'], 6200.0);
      expect(categorySpendMap['cat_transport'], 4500.0);

      // Percentage calculation
      final foodPct = (categorySpendMap['cat_food']! / totalExpense) * 100;
      expect(foodPct, closeTo(53.47, 0.01));
    });
  });

  group('Debt Calculations Tests', () {
    final debts = [
      DebtModel(
        id: 'd1',
        personName: 'Rahim',
        amount: 5000.0,
        paidAmount: 1000.0,
        type: DebtType.gave,
        date: DateTime(2026, 9, 1),
        status: DebtStatus.partiallyPaid,
      ),
      DebtModel(
        id: 'd2',
        personName: 'Karim',
        amount: 2500.0,
        paidAmount: 0.0,
        type: DebtType.received,
        date: DateTime(2026, 9, 2),
        status: DebtStatus.pending,
      ),
      DebtModel(
        id: 'd3',
        personName: 'Tanvir',
        amount: 3000.0,
        paidAmount: 3000.0,
        type: DebtType.gave,
        date: DateTime(2026, 8, 15),
        status: DebtStatus.paid,
      ),
    ];

    test('Calculates total receivable (gave) and payable (received)', () {
      double willReceive = 0;
      double needToPay = 0;

      for (final debt in debts) {
        if (debt.type == DebtType.gave) {
          willReceive += debt.remainingAmount;
        } else {
          needToPay += debt.remainingAmount;
        }
      }

      // d1 remaining = 4000, d3 remaining = 0
      expect(willReceive, 4000.0);
      // d2 remaining = 2500
      expect(needToPay, 2500.0);
    });
  });
}
