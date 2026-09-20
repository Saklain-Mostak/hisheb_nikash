import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/debt_model.dart';
import '../../../domain/entities/domain_enums.dart';
import '../../common_providers.dart';

class DebtsSummary {
  final double totalWillReceive; // Money I gave
  final double totalNeedToPay;   // Money I received
  final int pendingCount;
  final int settledCount;

  const DebtsSummary({
    required this.totalWillReceive,
    required this.totalNeedToPay,
    required this.pendingCount,
    required this.settledCount,
  });
}

class DebtsFilterState {
  final DebtType? typeFilter;     // null = all
  final DebtStatus? statusFilter; // null = all
  final String searchQuery;

  const DebtsFilterState({
    this.typeFilter,
    this.statusFilter,
    this.searchQuery = '',
  });

  DebtsFilterState copyWith({
    DebtType? typeFilter,
    bool clearType = false,
    DebtStatus? statusFilter,
    bool clearStatus = false,
    String? searchQuery,
  }) {
    return DebtsFilterState(
      typeFilter: clearType ? null : (typeFilter ?? this.typeFilter),
      statusFilter: clearStatus ? null : (statusFilter ?? this.statusFilter),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class DebtsFilterNotifier extends Notifier<DebtsFilterState> {
  @override
  DebtsFilterState build() => const DebtsFilterState();

  void setTypeFilter(DebtType? type) {
    if (type == null) {
      state = state.copyWith(clearType: true);
    } else {
      state = state.copyWith(typeFilter: type);
    }
  }

  void setStatusFilter(DebtStatus? status) {
    if (status == null) {
      state = state.copyWith(clearStatus: true);
    } else {
      state = state.copyWith(statusFilter: status);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void reset() {
    state = const DebtsFilterState();
  }
}

final debtsFilterProvider =
    NotifierProvider<DebtsFilterNotifier, DebtsFilterState>(DebtsFilterNotifier.new);

// Summary calculation provider
final debtsSummaryProvider = Provider<DebtsSummary>((ref) {
  final allDebts = ref.watch(debtsStreamProvider).value ?? [];

  double willReceive = 0;
  double needToPay = 0;
  int pending = 0;
  int settled = 0;

  for (final debt in allDebts) {
    if (debt.status == DebtStatus.paid) {
      settled++;
    } else {
      pending++;
    }

    if (debt.type == DebtType.gave) {
      willReceive += debt.remainingAmount;
    } else {
      needToPay += debt.remainingAmount;
    }
  }

  return DebtsSummary(
    totalWillReceive: willReceive,
    totalNeedToPay: needToPay,
    pendingCount: pending,
    settledCount: settled,
  );
});

// Filtered debts provider
final filteredDebtsProvider = Provider<List<DebtModel>>((ref) {
  final allDebts = ref.watch(debtsStreamProvider).value ?? [];
  final filter = ref.watch(debtsFilterProvider);

  return allDebts.where((debt) {
    if (filter.typeFilter != null && debt.type != filter.typeFilter) {
      return false;
    }
    if (filter.statusFilter != null && debt.status != filter.statusFilter) {
      return false;
    }
    if (filter.searchQuery.trim().isNotEmpty) {
      final query = filter.searchQuery.trim().toLowerCase();
      final name = debt.personName.toLowerCase();
      final note = debt.note?.toLowerCase() ?? '';
      final amount = debt.amount.toString();
      if (!name.contains(query) && !note.contains(query) && !amount.contains(query)) {
        return false;
      }
    }
    return true;
  }).toList();
});
