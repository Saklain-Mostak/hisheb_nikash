import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../domain/entities/domain_enums.dart';
import '../../common_providers.dart';

class DailyHistoryState {
  final DateTime selectedDate;
  final double dailyIncome;
  final double dailyExpense;
  final double dailyBalance;
  final List<TransactionModel> transactions;

  const DailyHistoryState({
    required this.selectedDate,
    required this.dailyIncome,
    required this.dailyExpense,
    required this.dailyBalance,
    required this.transactions,
  });
}

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  void setDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }

  void previousDay() {
    state = state.subtract(const Duration(days: 1));
  }

  void nextDay() {
    state = state.add(const Duration(days: 1));
  }
}

final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

final dailyHistoryProvider = Provider<DailyHistoryState>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final allTransactions = ref.watch(transactionsStreamProvider).value ?? [];

  final dayTxs = allTransactions.where((tx) {
    return DateFormatter.isSameDay(tx.date, selectedDate);
  }).toList();

  double income = 0;
  double expense = 0;

  for (final tx in dayTxs) {
    if (tx.type == TransactionType.income) {
      income += tx.amount;
    } else {
      expense += tx.amount;
    }
  }

  return DailyHistoryState(
    selectedDate: selectedDate,
    dailyIncome: income,
    dailyExpense: expense,
    dailyBalance: income - expense,
    transactions: dayTxs,
  );
});
