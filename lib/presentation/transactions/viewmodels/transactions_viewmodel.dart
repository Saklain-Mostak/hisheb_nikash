import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../domain/entities/domain_enums.dart';
import '../../common_providers.dart';

enum DateFilterPreset {
  all,
  today,
  thisWeek,
  thisMonth,
  custom;

  String get displayName {
    switch (this) {
      case DateFilterPreset.all:
        return 'All Time';
      case DateFilterPreset.today:
        return 'Today';
      case DateFilterPreset.thisWeek:
        return 'This Week';
      case DateFilterPreset.thisMonth:
        return 'This Month';
      case DateFilterPreset.custom:
        return 'Custom';
    }
  }
}

enum TransactionSortOrder {
  newestFirst,
  oldestFirst,
  highestAmount,
  lowestAmount;

  String get displayName {
    switch (this) {
      case TransactionSortOrder.newestFirst:
        return 'Newest First';
      case TransactionSortOrder.oldestFirst:
        return 'Oldest First';
      case TransactionSortOrder.highestAmount:
        return 'Highest Amount';
      case TransactionSortOrder.lowestAmount:
        return 'Lowest Amount';
    }
  }
}

class TransactionFilterState {
  final String searchQuery;
  final DateFilterPreset datePreset;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final TransactionType? typeFilter; // null = all
  final String? categoryIdFilter; // null = all
  final PaymentMethod? paymentMethodFilter; // null = all
  final TransactionSortOrder sortOrder;

  const TransactionFilterState({
    this.searchQuery = '',
    this.datePreset = DateFilterPreset.all,
    this.customStartDate,
    this.customEndDate,
    this.typeFilter,
    this.categoryIdFilter,
    this.paymentMethodFilter,
    this.sortOrder = TransactionSortOrder.newestFirst,
  });

  TransactionFilterState copyWith({
    String? searchQuery,
    DateFilterPreset? datePreset,
    DateTime? customStartDate,
    DateTime? customEndDate,
    TransactionType? typeFilter,
    bool clearTypeFilter = false,
    String? categoryIdFilter,
    bool clearCategoryFilter = false,
    PaymentMethod? paymentMethodFilter,
    bool clearPaymentMethodFilter = false,
    TransactionSortOrder? sortOrder,
  }) {
    return TransactionFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      datePreset: datePreset ?? this.datePreset,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      categoryIdFilter: clearCategoryFilter ? null : (categoryIdFilter ?? this.categoryIdFilter),
      paymentMethodFilter:
          clearPaymentMethodFilter ? null : (paymentMethodFilter ?? this.paymentMethodFilter),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      datePreset != DateFilterPreset.all ||
      typeFilter != null ||
      categoryIdFilter != null ||
      paymentMethodFilter != null;
}

class TransactionFilterNotifier extends Notifier<TransactionFilterState> {
  @override
  TransactionFilterState build() => const TransactionFilterState();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setDatePreset(DateFilterPreset preset, [DateTime? start, DateTime? end]) {
    state = state.copyWith(
      datePreset: preset,
      customStartDate: start,
      customEndDate: end,
    );
  }

  void setTypeFilter(TransactionType? type) {
    if (type == null) {
      state = state.copyWith(clearTypeFilter: true);
    } else {
      state = state.copyWith(typeFilter: type);
    }
  }

  void setCategoryFilter(String? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearCategoryFilter: true);
    } else {
      state = state.copyWith(categoryIdFilter: categoryId);
    }
  }

  void setPaymentMethodFilter(PaymentMethod? method) {
    if (method == null) {
      state = state.copyWith(clearPaymentMethodFilter: true);
    } else {
      state = state.copyWith(paymentMethodFilter: method);
    }
  }

  void setSortOrder(TransactionSortOrder order) {
    state = state.copyWith(sortOrder: order);
  }

  void resetFilters() {
    state = const TransactionFilterState();
  }
}

final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilterState>(
  TransactionFilterNotifier.new,
);

// Filtered & Sorted Transactions Provider
final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final allTransactions = ref.watch(transactionsStreamProvider).value ?? [];
  final filter = ref.watch(transactionFilterProvider);
  final categoriesMap = ref.watch(categoriesMapProvider);
  final now = DateTime.now();

  var result = allTransactions.where((tx) {
    // Type Filter
    if (filter.typeFilter != null && tx.type != filter.typeFilter) {
      return false;
    }

    // Category Filter
    if (filter.categoryIdFilter != null && tx.categoryId != filter.categoryIdFilter) {
      return false;
    }

    // Payment Method Filter
    if (filter.paymentMethodFilter != null && tx.paymentMethod != filter.paymentMethodFilter) {
      return false;
    }

    // Date Presets
    switch (filter.datePreset) {
      case DateFilterPreset.all:
        break;
      case DateFilterPreset.today:
        if (!DateFormatter.isSameDay(tx.date, now)) return false;
        break;
      case DateFilterPreset.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final zeroStartOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        if (tx.date.isBefore(zeroStartOfWeek)) return false;
        break;
      case DateFilterPreset.thisMonth:
        if (!DateFormatter.isSameMonth(tx.date, now)) return false;
        break;
      case DateFilterPreset.custom:
        if (filter.customStartDate != null) {
          final start = DateTime(
            filter.customStartDate!.year,
            filter.customStartDate!.month,
            filter.customStartDate!.day,
          );
          if (tx.date.isBefore(start)) return false;
        }
        if (filter.customEndDate != null) {
          final end = DateTime(
            filter.customEndDate!.year,
            filter.customEndDate!.month,
            filter.customEndDate!.day,
            23,
            59,
            59,
          );
          if (tx.date.isAfter(end)) return false;
        }
        break;
    }

    // Search query
    if (filter.searchQuery.trim().isNotEmpty) {
      final query = filter.searchQuery.trim().toLowerCase();
      final catName = categoriesMap[tx.categoryId]?.name.toLowerCase() ?? '';
      final note = tx.note?.toLowerCase() ?? '';
      final amountStr = tx.amount.toString();
      final methodStr = tx.paymentMethod.displayName.toLowerCase();

      final matches = catName.contains(query) ||
          note.contains(query) ||
          amountStr.contains(query) ||
          methodStr.contains(query);
      if (!matches) return false;
    }

    return true;
  }).toList();

  // Sorting
  switch (filter.sortOrder) {
    case TransactionSortOrder.newestFirst:
      result.sort((a, b) => b.date.compareTo(a.date));
      break;
    case TransactionSortOrder.oldestFirst:
      result.sort((a, b) => a.date.compareTo(b.date));
      break;
    case TransactionSortOrder.highestAmount:
      result.sort((a, b) => b.amount.compareTo(a.amount));
      break;
    case TransactionSortOrder.lowestAmount:
      result.sort((a, b) => a.amount.compareTo(b.amount));
      break;
  }

  return result;
});

// Grouping by Month & Year for the list view
class MonthlyGroupedTransactions {
  final String monthHeader;
  final double totalIncome;
  final double totalExpense;
  final List<TransactionModel> transactions;

  MonthlyGroupedTransactions({
    required this.monthHeader,
    required this.totalIncome,
    required this.totalExpense,
    required this.transactions,
  });
}

final groupedTransactionsProvider = Provider<List<MonthlyGroupedTransactions>>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);
  if (transactions.isEmpty) return [];

  final Map<String, List<TransactionModel>> map = {};
  for (final tx in transactions) {
    final key = DateFormatter.formatMonthYear(tx.date);
    map.putIfAbsent(key, () => []).add(tx);
  }

  return map.entries.map((entry) {
    double inc = 0;
    double exp = 0;
    for (final tx in entry.value) {
      if (tx.type == TransactionType.income) {
        inc += tx.amount;
      } else {
        exp += tx.amount;
      }
    }
    return MonthlyGroupedTransactions(
      monthHeader: entry.key,
      totalIncome: inc,
      totalExpense: exp,
      transactions: entry.value,
    );
  }).toList();
});
