import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../data/models/debt_model.dart';
import '../../../domain/entities/domain_enums.dart';
import '../../common_providers.dart';
import '../viewmodels/debts_viewmodel.dart';
import '../widgets/record_payment_dialog.dart';

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;
    final currencySymbol = ref.watch(currencySymbolProvider);

    final summary = ref.watch(debtsSummaryProvider);
    final debts = ref.watch(filteredDebtsProvider);
    final filter = ref.watch(debtsFilterProvider);
    final filterNotifier = ref.read(debtsFilterProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.loansAndDebts, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Summary Cards (You will receive & You need to pay)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(
                children: [
                  // You will receive (Money Given)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lentContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.lentColor.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.arrow_upward_rounded, size: 14, color: AppColors.lentColor),
                              const SizedBox(width: 4),
                              Text(
                                l10n.youWillReceive,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF92400E),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyFormatter.format(summary.totalWillReceive, symbol: currencySymbol),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.lentColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // You need to pay (Money Received)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.borrowedContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.borrowedColor.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.arrow_downward_rounded, size: 14, color: AppColors.borrowedColor),
                              const SizedBox(width: 4),
                              Text(
                                l10n.youNeedToPay,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF5B21B6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyFormatter.format(summary.totalNeedToPay, symbol: currencySymbol),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.borrowedColor,
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
            ),

            // Horizontal Filter Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Row(
                children: [
                  // Type filter chips
                  ChoiceChip(
                    label: Text(l10n.filterAll),
                    selected: filter.typeFilter == null,
                    onSelected: (_) => filterNotifier.setTypeFilter(null),
                    showCheckmark: false,
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: Text(l10n.iGave),
                    selected: filter.typeFilter == DebtType.gave,
                    selectedColor: AppColors.lentContainer,
                    onSelected: (_) => filterNotifier.setTypeFilter(
                      filter.typeFilter == DebtType.gave ? null : DebtType.gave,
                    ),
                    showCheckmark: false,
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: Text(l10n.iTook),
                    selected: filter.typeFilter == DebtType.received,
                    selectedColor: AppColors.borrowedContainer,
                    onSelected: (_) => filterNotifier.setTypeFilter(
                      filter.typeFilter == DebtType.received ? null : DebtType.received,
                    ),
                    showCheckmark: false,
                  ),
                  const SizedBox(width: 10),

                  // Status filter popup
                  PopupMenuButton<DebtStatus?>(
                    onSelected: filterNotifier.setStatusFilter,
                    itemBuilder: (context) => [
                      PopupMenuItem(value: null, child: Text(l10n.statusAll)),
                      ...DebtStatus.values.map(
                        (s) => PopupMenuItem(value: s, child: Text(l10n.getDebtStatusName(s))),
                      ),
                    ],
                    child: Chip(
                      avatar: const Icon(Icons.filter_list_rounded, size: 16),
                      label: Text(
                        filter.statusFilter != null
                            ? l10n.getDebtStatusName(filter.statusFilter!)
                            : l10n.statusAll,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Debts List
            Expanded(
              child: debts.isEmpty
                  ? Center(
                      child: EmptyStateView(
                        icon: Icons.handshake_outlined,
                        title: l10n.noLoansOrDebts,
                        message: l10n.noLoansOrDebtsSub,
                        actionLabel: l10n.addLoanDebt,
                        onAction: () => context.push('/debt/add'),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      itemCount: debts.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final debt = debts[index];
                        return _DebtCard(debt: debt, currencySymbol: currencySymbol);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/debt/add'),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addDebt, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
      ),
    );
  }
}

class _DebtCard extends ConsumerWidget {
  final DebtModel debt;
  final String currencySymbol;

  const _DebtCard({
    required this.debt,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;
    final isGave = debt.type == DebtType.gave;
    final typeColor = isGave ? AppColors.lentColor : AppColors.borrowedColor;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Person name, type badge, popup menu)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isGave ? Icons.arrow_outward_rounded : Icons.arrow_downward_rounded,
                      color: typeColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.personName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.getDebtTypeName(debt.type),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: typeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: debt.status.badgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.getDebtStatusName(debt.status),
                      style: TextStyle(
                        color: debt.status.badgeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 20),
                    onSelected: (val) async {
                      if (val == 'edit') {
                        context.push('/debt/edit/${debt.id}');
                      } else if (val == 'delete') {
                        final confirmed = await ConfirmDialog.show(
                          context,
                          title: l10n.deleteDebt,
                          message: l10n.confirmDeleteDebt,
                          confirmLabel: l10n.delete,
                          cancelLabel: l10n.cancel,
                          isDestructive: true,
                        );
                        if (confirmed) {
                          await ref.read(debtRepositoryProvider).deleteDebt(debt.id);
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l10n.delete, style: const TextStyle(color: AppColors.expense)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Amounts Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.remainingDue,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(debt.remainingAmount, symbol: currencySymbol),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: debt.isFullyPaid ? AppColors.income : typeColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.totalAmount,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(debt.amount, symbol: currencySymbol),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Progress Bar
          if (debt.paidAmount > 0 && !debt.isFullyPaid) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (debt.paidAmount / debt.amount).clamp(0.0, 1.0),
                backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(typeColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.paid}: ${CurrencyFormatter.format(debt.paidAmount, symbol: currencySymbol)}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],

          const SizedBox(height: 10),
          const Divider(height: 12),

          // Footer Row (Dates & Record Payment Button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.given}: ${DateFormatter.formatDate(debt.date)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  if (debt.dueDate != null)
                    Text(
                      '${l10n.due}: ${DateFormatter.formatDate(debt.dueDate!)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: debt.dueDate!.isBefore(DateTime.now()) && !debt.isFullyPaid
                            ? AppColors.expense
                            : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                      ),
                    ),
                ],
              ),
              if (!debt.isFullyPaid)
                FilledButton.tonal(
                  onPressed: () {
                    RecordPaymentDialog.show(context, debt);
                  },
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(l10n.recordPayment, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
