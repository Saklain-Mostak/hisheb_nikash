import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../domain/entities/domain_enums.dart';
import '../../common_providers.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final currencySymbol = ref.watch(currencySymbolProvider);

    final allTransactions = ref.watch(transactionsStreamProvider).value ?? [];
    final transaction = allTransactions.where((t) => t.id == transactionId).firstOrNull;

    if (transaction == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.transactionNotFound)),
      );
    }

    final categoriesMap = ref.watch(categoriesMapProvider);
    final category = categoriesMap[transaction.categoryId];
    final isIncome = transaction.type == TransactionType.income;
    final typeColor = isIncome ? AppColors.income : AppColors.expense;
    final catIconData = category != null
        ? AppIcons.getIconData(category.iconCodePoint)
        : Icons.receipt_rounded;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionDetails, style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.edit,
            onPressed: () {
              context.push('/transaction/edit/${transaction.id}');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expense),
            tooltip: l10n.delete,
            onPressed: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: l10n.deleteTransaction,
                message: l10n.confirmDeleteTransaction,
                confirmLabel: l10n.delete,
                cancelLabel: l10n.cancel,
                isDestructive: true,
              );

              if (confirmed && context.mounted) {
                await ref.read(transactionRepositoryProvider).deleteTransaction(transaction.id);
                if (context.mounted) {
                  context.pop();
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Hero Receipt Card
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Category Icon Bubble
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: (category != null ? Color(category.colorValue) : typeColor)
                            .withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        catIconData,
                        color: category != null ? Color(category.colorValue) : typeColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category Name
                    Text(
                      category != null
                          ? l10n.getCategoryName(category.name, category.id)
                          : l10n.none,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.getTransactionTypeName(transaction.type),
                        style: TextStyle(
                          color: typeColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Formatted Amount
                    Text(
                      '${isIncome ? '+' : '-'} ${CurrencyFormatter.format(transaction.amount, symbol: currencySymbol)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 34,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Details Rows
                    _DetailRow(
                      icon: Icons.calendar_today_rounded,
                      label: l10n.date,
                      value: DateFormatter.formatDate(transaction.date),
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      icon: Icons.access_time_rounded,
                      label: l10n.time,
                      value: DateFormatter.formatTime(transaction.date),
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      icon: transaction.paymentMethod.icon,
                      label: l10n.paymentMethod,
                      value: l10n.getPaymentMethodName(transaction.paymentMethod),
                    ),
                    if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _DetailRow(
                        icon: Icons.notes_rounded,
                        label: l10n.note,
                        value: transaction.note!,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.push('/transaction/edit/${transaction.id}');
                      },
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: Text(l10n.edit),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final confirmed = await ConfirmDialog.show(
                          context,
                          title: l10n.deleteTransaction,
                          message: l10n.confirmDeleteTransaction,
                          confirmLabel: l10n.delete,
                          cancelLabel: l10n.cancel,
                          isDestructive: true,
                        );

                        if (confirmed && context.mounted) {
                          await ref.read(transactionRepositoryProvider).deleteTransaction(transaction.id);
                          if (context.mounted) {
                            context.pop();
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_rounded, size: 18),
                      label: Text(l10n.delete),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.expense,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const Spacer(),
        Flexible(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
