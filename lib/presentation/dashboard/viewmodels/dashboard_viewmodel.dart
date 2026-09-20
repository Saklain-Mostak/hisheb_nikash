import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../domain/entities/domain_enums.dart';
import '../../common_providers.dart';

class DashboardState {
  final String greeting;
  final double todayIncome;
  final double todayExpense;
  final double todayBalance;
  final double monthIncome;
  final double monthExpense;
  final double monthBalance;
  final double totalBalance;
  final List<TransactionModel> recentTransactions;

  const DashboardState({
    required this.greeting,
    required this.todayIncome,
    required this.todayExpense,
    required this.todayBalance,
    required this.monthIncome,
    required this.monthExpense,
    required this.monthBalance,
    required this.totalBalance,
    required this.recentTransactions,
  });

  factory DashboardState.initial() {
    return const DashboardState(
      greeting: 'Welcome 👋',
      todayIncome: 0,
      todayExpense: 0,
      todayBalance: 0,
      monthIncome: 0,
      monthExpense: 0,
      monthBalance: 0,
      totalBalance: 0,
      recentTransactions: [],
    );
  }
}

final dashboardViewModelProvider = Provider<DashboardState>((ref) {
  final transactions = ref.watch(transactionsStreamProvider).value ?? [];
  final now = DateTime.now();

  // Greeting
  final hour = now.hour;
  String greeting = 'Good Morning 👋';
  if (hour >= 12 && hour < 17) {
    greeting = 'Good Afternoon ☀️';
  } else if (hour >= 17 || hour < 5) {
    greeting = 'Good Evening 🌙';
  }

  double todayIncome = 0;
  double todayExpense = 0;
  double monthIncome = 0;
  double monthExpense = 0;
  double totalIncome = 0;
  double totalExpense = 0;

  for (final tx in transactions) {
    final isIncome = tx.type == TransactionType.income;

    // Overall total
    if (isIncome) {
      totalIncome += tx.amount;
    } else {
      totalExpense += tx.amount;
    }

    // Today
    if (DateFormatter.isSameDay(tx.date, now)) {
      if (isIncome) {
        todayIncome += tx.amount;
      } else {
        todayExpense += tx.amount;
      }
    }

    // Month
    if (DateFormatter.isSameMonth(tx.date, now)) {
      if (isIncome) {
        monthIncome += tx.amount;
      } else {
        monthExpense += tx.amount;
      }
    }
  }

  final recentTransactions = transactions.take(6).toList();

  return DashboardState(
    greeting: greeting,
    todayIncome: todayIncome,
    todayExpense: todayExpense,
    todayBalance: todayIncome - todayExpense,
    monthIncome: monthIncome,
    monthExpense: monthExpense,
    monthBalance: monthIncome - monthExpense,
    totalBalance: totalIncome - totalExpense,
    recentTransactions: recentTransactions,
  );
});
