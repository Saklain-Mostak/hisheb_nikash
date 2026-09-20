import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class IncomeExpenseBarChart extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final String currencySymbol;

  const IncomeExpenseBarChart({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final maxY = (totalIncome > totalExpense ? totalIncome : totalExpense);
    final effectiveMaxY = maxY > 0 ? maxY * 1.25 : 100.0;

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: effectiveMaxY,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final label = group.x == 0 ? 'Income' : 'Expense';
                    return BarTooltipItem(
                      '$label\n${CurrencyFormatter.format(rod.toY, symbol: currencySymbol)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final style = TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      );
                      if (value == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('Income', style: style),
                        );
                      } else if (value == 1) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('Expense', style: style),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: totalIncome,
                      color: AppColors.income,
                      width: 42,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: totalExpense,
                      color: AppColors.expense,
                      width: 42,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
