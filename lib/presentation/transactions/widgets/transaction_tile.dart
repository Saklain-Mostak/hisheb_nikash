import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../domain/entities/domain_enums.dart';
import '../../common_providers.dart';

class TransactionTile extends ConsumerWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencySymbol = ref.watch(currencySymbolProvider);
    final categoriesMap = ref.watch(categoriesMapProvider);
    final category = categoriesMap[transaction.categoryId];

    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final amountPrefix = isIncome ? '+ ' : '- ';

    final catIconData = category != null
        ? AppIcons.getIconData(category.iconCodePoint)
        : Icons.receipt_rounded;
    final catColor = category != null
        ? Color(category.colorValue)
        : (isIncome ? AppColors.income : AppColors.expense);

    return InkWell(
      onTap: onTap ?? () => context.push('/transaction/detail/${transaction.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Category Icon with soft colored container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  catIconData,
                  color: catColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Category name, note & timestamp
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category?.name ?? 'Unknown',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        DateFormatter.formatTransactionDateTime(transaction.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        transaction.paymentMethod.displayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      transaction.note!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Formatted Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$amountPrefix${CurrencyFormatter.format(transaction.amount, symbol: currencySymbol)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
