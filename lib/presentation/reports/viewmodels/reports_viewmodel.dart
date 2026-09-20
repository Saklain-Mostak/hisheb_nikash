import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../domain/entities/domain_enums.dart';
import '../../common_providers.dart';

class CategorySpendInfo {
  final CategoryModel category;
  final double totalAmount;
  final double percentage;
  final int transactionCount;

  CategorySpendInfo({
    required this.category,
    required this.totalAmount,
    required this.percentage,
    required this.transactionCount,
  });
}

class DailySpendPoint {
  final int day;
  final double expenseAmount;
  final double incomeAmount;

  DailySpendPoint({
    required this.day,
    required this.expenseAmount,
    required this.incomeAmount,
  });
}

class MonthlyReportState {
  final DateTime selectedMonth;
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final CategorySpendInfo? highestSpendingCategory;
  final TransactionModel? highestExpense;
  final int transactionCount;
  final List<CategorySpendInfo> categoryBreakdown;
  final List<DailySpendPoint> dailyTrends;

  const MonthlyReportState({
    required this.selectedMonth,
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    this.highestSpendingCategory,
    this.highestExpense,
    required this.transactionCount,
    required this.categoryBreakdown,
    required this.dailyTrends,
  });
}

class SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime(DateTime.now().year, DateTime.now().month, 1);

  void previousMonth() {
    state = DateTime(state.year, state.month - 1, 1);
  }

  void nextMonth() {
    state = DateTime(state.year, state.month + 1, 1);
  }

  void setMonth(DateTime month) {
    state = DateTime(month.year, month.month, 1);
  }
}

final selectedMonthProvider =
    NotifierProvider<SelectedMonthNotifier, DateTime>(SelectedMonthNotifier.new);

final monthlyReportProvider = Provider<MonthlyReportState>((ref) {
  final selectedMonth = ref.watch(selectedMonthProvider);
  final allTransactions = ref.watch(transactionsStreamProvider).value ?? [];
  final categoriesMap = ref.watch(categoriesMapProvider);

  // Filter transactions for the selected month
  final monthTxs = allTransactions.where((tx) {
    return tx.date.year == selectedMonth.year && tx.date.month == selectedMonth.month;
  }).toList();

  double totalIncome = 0;
  double totalExpense = 0;
  TransactionModel? highestExpense;

  final Map<String, double> categorySpendMap = {};
  final Map<String, int> categoryCountMap = {};

  final int daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
  final Map<int, double> dailyExpenseMap = {for (int i = 1; i <= daysInMonth; i++) i: 0.0};
  final Map<int, double> dailyIncomeMap = {for (int i = 1; i <= daysInMonth; i++) i: 0.0};

  for (final tx in monthTxs) {
    final day = tx.date.day;

    if (tx.type == TransactionType.income) {
      totalIncome += tx.amount;
      dailyIncomeMap[day] = (dailyIncomeMap[day] ?? 0) + tx.amount;
    } else {
      totalExpense += tx.amount;
      dailyExpenseMap[day] = (dailyExpenseMap[day] ?? 0) + tx.amount;

      // Track highest individual expense
      if (highestExpense == null || tx.amount > highestExpense.amount) {
        highestExpense = tx;
      }

      // Aggregate category spend
      categorySpendMap[tx.categoryId] =
          (categorySpendMap[tx.categoryId] ?? 0) + tx.amount;
      categoryCountMap[tx.categoryId] =
          (categoryCountMap[tx.categoryId] ?? 0) + 1;
    }
  }

  // Build category breakdown list
  final List<CategorySpendInfo> categoryBreakdown = [];
  categorySpendMap.forEach((catId, amount) {
    final cat = categoriesMap[catId] ??
        CategoryModel(
          id: catId,
          name: 'Other',
          type: TransactionType.expense,
          iconCodePoint: Icons.interests_rounded.codePoint,
          colorValue: 0xFF64748B,
        );
    final pct = totalExpense > 0 ? (amount / totalExpense) * 100 : 0.0;
    categoryBreakdown.add(CategorySpendInfo(
      category: cat,
      totalAmount: amount,
      percentage: pct,
      transactionCount: categoryCountMap[catId] ?? 1,
    ));
  });

  categoryBreakdown.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

  final CategorySpendInfo? highestSpendingCategory =
      categoryBreakdown.isNotEmpty ? categoryBreakdown.first : null;

  // Build daily spend points
  final List<DailySpendPoint> dailyTrends = [];
  for (int i = 1; i <= daysInMonth; i++) {
    dailyTrends.add(DailySpendPoint(
      day: i,
      expenseAmount: dailyExpenseMap[i] ?? 0.0,
      incomeAmount: dailyIncomeMap[i] ?? 0.0,
    ));
  }

  return MonthlyReportState(
    selectedMonth: selectedMonth,
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    netBalance: totalIncome - totalExpense,
    highestSpendingCategory: highestSpendingCategory,
    highestExpense: highestExpense,
    transactionCount: monthTxs.length,
    categoryBreakdown: categoryBreakdown,
    dailyTrends: dailyTrends,
  );
});
