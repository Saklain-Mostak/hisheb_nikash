import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../domain/entities/domain_enums.dart';
import '../../common_providers.dart';
import '../viewmodels/transactions_viewmodel.dart';
import '../widgets/transaction_tile.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;
    final currencySymbol = ref.watch(currencySymbolProvider);

    final filter = ref.watch(transactionFilterProvider);
    final filterNotifier = ref.read(transactionFilterProvider.notifier);
    final groupedList = ref.watch(groupedTransactionsProvider);
    final allCategories = ref.watch(categoriesStreamProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactions, style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          // Sort Menu
          PopupMenuButton<TransactionSortOrder>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: l10n.sortBy,
            onSelected: filterNotifier.setSortOrder,
            itemBuilder: (context) => TransactionSortOrder.values.map((order) {
              return PopupMenuItem(
                value: order,
                child: Row(
                  children: [
                    if (filter.sortOrder == order)
                      const Icon(Icons.check_rounded, size: 18, color: AppColors.primary)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 10),
                    Text(l10n.getSortOrderName(order)),
                  ],
                ),
              );
            }).toList(),
          ),
          if (filter.hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_rounded),
              tooltip: l10n.resetFilters,
              onPressed: () {
                _searchController.clear();
                filterNotifier.resetFilters();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: filterNotifier.setSearchQuery,
                decoration: InputDecoration(
                  hintText: l10n.searchTransactions,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            filterNotifier.setSearchQuery('');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                ),
              ),
            ),

            // Horizontal Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Row(
                children: [
                  // Type filter: All / Expense / Income
                  FilterChip(
                    label: Text(l10n.filterAll),
                    selected: filter.typeFilter == null,
                    onSelected: (_) => filterNotifier.setTypeFilter(null),
                    showCheckmark: false,
                  ),
                  const SizedBox(width: 6),
                  FilterChip(
                    label: Text(l10n.filterExpense),
                    selected: filter.typeFilter == TransactionType.expense,
                    selectedColor: AppColors.expenseLight,
                    onSelected: (_) => filterNotifier.setTypeFilter(
                      filter.typeFilter == TransactionType.expense ? null : TransactionType.expense,
                    ),
                    showCheckmark: false,
                  ),
                  const SizedBox(width: 6),
                  FilterChip(
                    label: Text(l10n.filterIncome),
                    selected: filter.typeFilter == TransactionType.income,
                    selectedColor: AppColors.incomeLight,
                    onSelected: (_) => filterNotifier.setTypeFilter(
                      filter.typeFilter == TransactionType.income ? null : TransactionType.income,
                    ),
                    showCheckmark: false,
                  ),
                  const SizedBox(width: 6),

                  // Date preset popup button
                  PopupMenuButton<DateFilterPreset>(
                    child: Chip(
                      avatar: const Icon(Icons.date_range_rounded, size: 16),
                      label: Text(l10n.getDatePresetName(filter.datePreset)),
                      backgroundColor: filter.datePreset != DateFilterPreset.all
                          ? (isDark ? AppColors.primaryContainerDark : AppColors.primaryContainerLight)
                          : null,
                    ),
                    onSelected: (preset) async {
                      if (preset == DateFilterPreset.custom) {
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (range != null) {
                          filterNotifier.setDatePreset(preset, range.start, range.end);
                        }
                      } else {
                        filterNotifier.setDatePreset(preset);
                      }
                    },
                    itemBuilder: (context) => DateFilterPreset.values.map((preset) {
                      return PopupMenuItem(
                        value: preset,
                        child: Text(l10n.getDatePresetName(preset)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 6),

                  // Category filter popup button
                  PopupMenuButton<String?>(
                    onSelected: filterNotifier.setCategoryFilter,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: null,
                        child: Text(l10n.allCategories),
                      ),
                      ...allCategories.map(
                        (cat) => PopupMenuItem(
                          value: cat.id,
                          child: Text(l10n.getCategoryName(cat.name, cat.id)),
                        ),
                      ),
                    ],
                    child: Chip(
                      avatar: const Icon(Icons.category_outlined, size: 16),
                      label: Text(
                        filter.categoryIdFilter != null
                            ? (allCategories
                                    .where((c) => c.id == filter.categoryIdFilter)
                                    .firstOrNull != null
                                ? l10n.getCategoryName(
                                    allCategories.firstWhere((c) => c.id == filter.categoryIdFilter).name,
                                    filter.categoryIdFilter,
                                  )
                                : l10n.category)
                            : l10n.category,
                      ),
                      backgroundColor: filter.categoryIdFilter != null
                          ? (isDark ? AppColors.primaryContainerDark : AppColors.primaryContainerLight)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Payment Method filter popup
                  PopupMenuButton<PaymentMethod?>(
                    onSelected: filterNotifier.setPaymentMethodFilter,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: null,
                        child: Text(l10n.allMethods),
                      ),
                      ...PaymentMethod.values.map(
                        (m) => PopupMenuItem(
                          value: m,
                          child: Text(l10n.getPaymentMethodName(m)),
                        ),
                      ),
                    ],
                    child: Chip(
                      avatar: const Icon(Icons.payments_outlined, size: 16),
                      label: Text(
                        filter.paymentMethodFilter != null
                            ? l10n.getPaymentMethodName(filter.paymentMethodFilter!)
                            : l10n.paymentMethod,
                      ),
                      backgroundColor: filter.paymentMethodFilter != null
                          ? (isDark ? AppColors.primaryContainerDark : AppColors.primaryContainerLight)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Grouped Transactions List
            Expanded(
              child: groupedList.isEmpty
                ? Center(
                    child: EmptyStateView(
                      icon: Icons.search_off_rounded,
                      title: l10n.noTransactionsFound,
                      message: filter.hasActiveFilters
                          ? l10n.clearFiltersMessage
                          : l10n.noTransactionsRecorded,
                      actionLabel: filter.hasActiveFilters ? l10n.resetFilters : l10n.addTransaction,
                      onAction: () {
                        if (filter.hasActiveFilters) {
                          _searchController.clear();
                          filterNotifier.resetFilters();
                        } else {
                          context.push('/transaction/add?type=expense');
                        }
                      },
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 18, right: 18, bottom: 80),
                    itemCount: groupedList.length,
                    itemBuilder: (context, groupIndex) {
                      final group = groupedList[groupIndex];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Group Header (Month & Totals)
                          Padding(
                            padding: const EdgeInsets.only(top: 14, bottom: 8, left: 4, right: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  group.monthHeader,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (group.totalIncome > 0)
                                      Text(
                                        '+${CurrencyFormatter.format(group.totalIncome, symbol: currencySymbol)}',
                                        style: const TextStyle(
                                          color: AppColors.income,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    if (group.totalIncome > 0 && group.totalExpense > 0)
                                      const Text('  •  ', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                    if (group.totalExpense > 0)
                                      Text(
                                        '-${CurrencyFormatter.format(group.totalExpense, symbol: currencySymbol)}',
                                        style: const TextStyle(
                                          color: AppColors.expense,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Transactions Card Container
                          AppCard(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: group.transactions.length,
                              separatorBuilder: (context, i) => Divider(
                                height: 1,
                                indent: 68,
                                endIndent: 12,
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                              itemBuilder: (context, i) {
                                final tx = group.transactions[i];
                                return TransactionTile(transaction: tx);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transaction/add?type=expense'),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.add, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
      ),
    );
  }
}
