import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../../transactions/widgets/transaction_tile.dart';

class RecentTransactions extends ConsumerWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(dashboardViewModelProvider);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentTransactions,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (state.recentTransactions.isNotEmpty)
              TextButton(
                onPressed: () => context.go('/transactions'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Row(
                  children: [
                    Text(
                      l10n.viewAll,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (state.recentTransactions.isEmpty)
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: EmptyStateView(
              icon: Icons.receipt_long_outlined,
              title: l10n.noTransactionsYet,
              message: l10n.startAddingTransactions,
              actionLabel: l10n.addTransaction,
              onAction: () => context.push('/transaction/add?type=expense'),
            ),
          )
        else
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.recentTransactions.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 68,
                endIndent: 12,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              itemBuilder: (context, index) {
                final tx = state.recentTransactions[index];
                return TransactionTile(transaction: tx);
              },
            ),
          ),
      ],
    );
  }
}
