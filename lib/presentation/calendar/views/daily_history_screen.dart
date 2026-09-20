import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../common_providers.dart';
import '../../transactions/widgets/transaction_tile.dart';
import '../viewmodels/calendar_viewmodel.dart';

class DailyHistoryScreen extends ConsumerWidget {
  const DailyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencySymbol = ref.watch(currencySymbolProvider);

    final history = ref.watch(dailyHistoryProvider);
    final dateNotifier = ref.read(selectedDateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily History', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Date Selector Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: dateNotifier.previousDay,
                      tooltip: 'Previous Day',
                    ),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: history.selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          dateNotifier.setDate(picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                Text(
                                  DateFormatter.formatDate(history.selectedDate),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  DateFormatter.isSameDay(history.selectedDate, DateTime.now())
                                      ? 'Today'
                                      : DateFormatter.formatDayOfWeek(history.selectedDate),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: dateNotifier.nextDay,
                      tooltip: 'Next Day',
                    ),
                  ],
                ),
              ),
            ),

            // Daily Summary Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Income
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Income',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(history.dailyIncome, symbol: currencySymbol),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.income,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    // Expense
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expense',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(history.dailyExpense, symbol: currencySymbol),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.expense,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    // Balance
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Balance',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(history.dailyBalance, symbol: currencySymbol),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: history.dailyBalance >= 0 ? AppColors.income : AppColors.expense,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Transactions for Selected Date
            Expanded(
              child: history.transactions.isEmpty
                  ? Center(
                      child: EmptyStateView(
                        icon: Icons.event_busy_rounded,
                        title: 'No transactions on this date',
                        message: 'Quickly record an expense or income for ${DateFormatter.formatShortDate(history.selectedDate)}.',
                        actionLabel: 'Add Transaction',
                        onAction: () => context.push('/transaction/add?type=expense'),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      itemCount: history.transactions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final tx = history.transactions[index];
                        return AppCard(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                          child: TransactionTile(transaction: tx),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
