import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../common_providers.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            // Preferences Section
            _SectionHeader(title: 'Preferences'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Currency Selector
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        settings.currencySymbol,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    title: const Text('Currency', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${settings.currencyCode} (${settings.currencySymbol})'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showCurrencyPicker(context, ref),
                  ),
                  const Divider(height: 1, indent: 56),

                  // Theme Selector
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.brightness_6_rounded, color: Colors.indigo, size: 20),
                    ),
                    title: const Text('Theme', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(_getThemeName(settings.themeModeIndex)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showThemePicker(context, settingsNotifier, settings.themeModeIndex),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Management Section
            _SectionHeader(title: 'Management'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Manage Categories
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.category_rounded, color: Colors.teal, size: 20),
                    ),
                    title: const Text('Manage Categories', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Add, edit, or customize categories'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/categories'),
                  ),
                  const Divider(height: 1, indent: 56),

                  // Daily History / Calendar
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.calendar_month_rounded, color: Colors.orange, size: 20),
                    ),
                    title: const Text('Daily History / Calendar', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Explore transactions by date'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/calendar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Backup & Data Section
            _SectionHeader(title: 'Data & Backup'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Backup Data (Export JSON)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.cloud_upload_outlined, color: Colors.blue, size: 20),
                    ),
                    title: const Text('Backup Data', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Export data to JSON file'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final success = await ref.read(settingsViewModelProvider.notifier).exportBackup();
                      if (context.mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Backup ready for sharing/saving.')),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 56),

                  // Restore Data (Import JSON)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.cloud_download_outlined, color: Colors.green, size: 20),
                    ),
                    title: const Text('Restore Data', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Import JSON backup file'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _handleRestore(context, ref),
                  ),
                  const Divider(height: 1, indent: 56),

                  // Clear All Data
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.expense.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_forever_rounded, color: AppColors.expense, size: 20),
                    ),
                    title: const Text(
                      'Clear All Data',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.expense),
                    ),
                    subtitle: const Text('Delete all transactions and reset'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final confirmed = await ConfirmDialog.show(
                        context,
                        title: 'Clear All Data?',
                        message: 'This will permanently remove all transactions, debts, custom categories, and reset all settings to default. Make sure to backup first!',
                        confirmLabel: 'Clear Everything',
                        isDestructive: true,
                      );

                      if (confirmed && context.mounted) {
                        await ref.read(settingsViewModelProvider.notifier).clearAllData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All data has been cleared and reset.'),
                              backgroundColor: AppColors.expense,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About Section
            _SectionHeader(title: 'About'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: Colors.purple, size: 20),
                    ),
                    title: const Text('About Hisheb', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Version 1.0.0 • 100% Offline & Private'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getThemeName(int index) {
    switch (index) {
      case 1:
        return 'Light';
      case 2:
        return 'Dark';
      default:
        return 'System Default';
    }
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Select Currency',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: AppConstants.supportedCurrencies.length,
                  itemBuilder: (context, index) {
                    final curr = AppConstants.supportedCurrencies[index];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          curr.symbol,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                      title: Text(curr.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Text(curr.code, style: const TextStyle(fontWeight: FontWeight.w700)),
                      onTap: () {
                        ref.read(settingsProvider.notifier).updateCurrency(curr.code, curr.symbol);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemePicker(BuildContext context, SettingsNotifier notifier, int currentMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme', style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('System Default'),
              leading: Icon(
                currentMode == 0 ? Icons.radio_button_checked : Icons.radio_button_off,
                color: currentMode == 0 ? AppColors.primary : null,
              ),
              onTap: () {
                notifier.updateTheme(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Light'),
              leading: Icon(
                currentMode == 1 ? Icons.radio_button_checked : Icons.radio_button_off,
                color: currentMode == 1 ? AppColors.primary : null,
              ),
              onTap: () {
                notifier.updateTheme(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Dark'),
              leading: Icon(
                currentMode == 2 ? Icons.radio_button_checked : Icons.radio_button_off,
                color: currentMode == 2 ? AppColors.primary : null,
              ),
              onTap: () {
                notifier.updateTheme(2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    // Show option: Pick file or paste JSON
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Restore Backup', style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'file'),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: const Row(
              children: [
                Icon(Icons.file_open_rounded, color: AppColors.primary),
                SizedBox(width: 14),
                Text('Select JSON File', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'text'),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: const Row(
              children: [
                Icon(Icons.paste_rounded, color: AppColors.secondary),
                SizedBox(width: 14),
                Text('Paste JSON Content', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );

    if (choice == null || !context.mounted) return;

    if (choice == 'file') {
      try {
        final result = await ref.read(settingsViewModelProvider.notifier).restoreBackupFromFile();
        if (result != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Restored successfully: ${result['transactions']} transactions, ${result['categories']} categories, ${result['debts']} debts.',
              ),
              backgroundColor: AppColors.income,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to restore: $e'), backgroundColor: AppColors.expense),
          );
        }
      }
    } else if (choice == 'text') {
      final textController = TextEditingController();
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Paste JSON Backup'),
          content: TextField(
            controller: textController,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Paste backup JSON here...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Restore'),
            ),
          ],
        ),
      );

      if (proceed == true && textController.text.trim().isNotEmpty && context.mounted) {
        try {
          final result = await ref
              .read(settingsViewModelProvider.notifier)
              .restoreBackupFromText(textController.text.trim());
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Restored: ${result['transactions']} transactions, ${result['categories']} categories, ${result['debts']} debts.',
                ),
                backgroundColor: AppColors.income,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to restore: $e'), backgroundColor: AppColors.expense),
            );
          }
        }
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Hisheb', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Expense & Income Tracker',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              '• 100% Offline & Local Storage via Hive\n'
              '• No cloud tracking or personal data collection\n'
              '• Fast expense entry designed for daily use\n'
              '• Complete financial reports and debt management\n'
              '• Free and open local JSON backup/restore',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
