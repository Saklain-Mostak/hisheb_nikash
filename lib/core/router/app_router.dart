import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/domain_enums.dart';
import '../../presentation/calendar/views/daily_history_screen.dart';
import '../../presentation/categories/views/categories_screen.dart';
import '../../presentation/common_providers.dart';
import '../../presentation/dashboard/views/dashboard_screen.dart';
import '../../presentation/debts/views/add_edit_debt_screen.dart';
import '../../presentation/debts/views/debts_screen.dart';
import '../../presentation/reports/views/reports_screen.dart';
import '../../presentation/settings/views/settings_screen.dart';
import '../../presentation/shell/main_navigation_shell.dart';
import '../../presentation/transactions/views/add_edit_transaction_screen.dart';
import '../../presentation/transactions/views/transaction_detail_screen.dart';
import '../../presentation/transactions/views/transactions_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorDashboard = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final _shellNavigatorTransactions = GlobalKey<NavigatorState>(debugLabel: 'transactions');
final _shellNavigatorReports = GlobalKey<NavigatorState>(debugLabel: 'reports');
final _shellNavigatorDebts = GlobalKey<NavigatorState>(debugLabel: 'debts');
final _shellNavigatorSettings = GlobalKey<NavigatorState>(debugLabel: 'settings');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Dashboard / Home
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDashboard,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Branch 1: Transactions
          StatefulShellBranch(
            navigatorKey: _shellNavigatorTransactions,
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),

          // Branch 2: Reports
          StatefulShellBranch(
            navigatorKey: _shellNavigatorReports,
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),

          // Branch 3: Debts
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDebts,
            routes: [
              GoRoute(
                path: '/debts',
                builder: (context, state) => const DebtsScreen(),
              ),
            ],
          ),

          // Branch 4: Settings
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSettings,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Add Transaction
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/transaction/add',
        builder: (context, state) {
          final typeParam = state.uri.queryParameters['type'];
          final initialType = typeParam == 'income'
              ? TransactionType.income
              : TransactionType.expense;
          return AddEditTransactionScreen(initialType: initialType);
        },
      ),

      // Edit Transaction
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/transaction/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final tx = ref.read(transactionRepositoryProvider).getTransactionById(id);
          return AddEditTransactionScreen(existingTransaction: tx);
        },
      ),

      // Transaction Detail
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/transaction/detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TransactionDetailScreen(transactionId: id);
        },
      ),

      // Manage Categories
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),

      // Daily History / Calendar
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/calendar',
        builder: (context, state) => const DailyHistoryScreen(),
      ),

      // Add Debt
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/debt/add',
        builder: (context, state) => const AddEditDebtScreen(),
      ),

      // Edit Debt
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/debt/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final debt = ref.read(debtRepositoryProvider).getDebtById(id);
          return AddEditDebtScreen(existingDebt: debt);
        },
      ),
    ],
  );
});
