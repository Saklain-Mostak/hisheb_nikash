import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../common_providers.dart';
import '../viewmodels/reports_viewmodel.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/income_expense_bar_chart.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencySymbol = ref.watch(currencySymbolProvider);

    final selectedMonth = ref.watch(selectedMonthProvider);
    final monthNotifier = ref.read(selectedMonthProvider.notifier);
    final report = ref.watch(monthlyReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Selector Bar (< Month Year >)
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: monthNotifier.previousMonth,
                    ),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedMonth,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          monthNotifier.setMonth(picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              DateFormatter.formatMonthYear(selectedMonth),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: monthNotifier.nextMonth,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Summary Highlight Cards
              Row(
                children: [
                  // Income
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.incomeLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_downward_rounded, size: 12, color: AppColors.income),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Income',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyFormatter.format(report.totalIncome, symbol: currencySymbol),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.income,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Expense
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.expenseLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_upward_rounded, size: 12, color: AppColors.expense),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Expense',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyFormatter.format(report.totalExpense, symbol: currencySymbol),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.expense,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Net Balance Card
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Net Balance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(report.netBalance, symbol: currencySymbol, showSign: true),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: report.netBalance >= 0 ? AppColors.income : AppColors.expense,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Key Stats Row (Highest spending category, highest expense, count)
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _StatRow(
                      label: 'Top Spending Category',
                      value: report.highestSpendingCategory != null
                          ? '${report.highestSpendingCategory!.category.name} (${CurrencyFormatter.format(report.highestSpendingCategory!.totalAmount, symbol: currencySymbol)})'
                          : 'None',
                    ),
                    const Divider(height: 18),
                    _StatRow(
                      label: 'Highest Single Expense',
                      value: report.highestExpense != null
                          ? CurrencyFormatter.format(report.highestExpense!.amount, symbol: currencySymbol)
                          : 'None',
                    ),
                    const Divider(height: 18),
                    _StatRow(
                      label: 'Number of Transactions',
                      value: '${report.transactionCount}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Category Breakdown Chart Card
              Text(
                'Expense by Category',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              AppCard(
                padding: const EdgeInsets.all(18),
                child: CategoryPieChart(
                  categoryBreakdown: report.categoryBreakdown,
                  currencySymbol: currencySymbol,
                  totalExpense: report.totalExpense,
                ),
              ),
              const SizedBox(height: 20),

              // Income vs Expense Bar Chart Card
              Text(
                'Income vs Expense',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              AppCard(
                padding: const EdgeInsets.all(18),
                child: IncomeExpenseBarChart(
                  totalIncome: report.totalIncome,
                  totalExpense: report.totalExpense,
                  currencySymbol: currencySymbol,
                ),
              ),
              const SizedBox(height: 20),

              // Top Spending Categories List
              if (report.categoryBreakdown.isNotEmpty) ...[
                Text(
                  'Top Spending Breakdown',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: report.categoryBreakdown.length,
                    separatorBuilder: (context, index) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final item = report.categoryBreakdown[index];
                      final catColor = Color(item.category.colorValue);
                      final iconData = AppIcons.getIconData(item.category.iconCodePoint);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: catColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(iconData, color: catColor, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.category.name,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                    ),
                                    Text(
                                      '${item.transactionCount} transactions',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(item.totalAmount, symbol: currencySymbol),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${item.percentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (item.percentage / 100).clamp(0.0, 1.0),
                              backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(catColor),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
