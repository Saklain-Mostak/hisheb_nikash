import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
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
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            // Preferences Section
            _SectionHeader(title: l10n.preferences),
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
                    title: Text(l10n.currency, style: const TextStyle(fontWeight: FontWeight.w600)),
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
                    title: Text(l10n.theme, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(_getThemeName(settings.themeModeIndex, l10n)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showThemePicker(context, settingsNotifier, settings.themeModeIndex, l10n),
                  ),
                  const Divider(height: 1, indent: 56),

                  // Language Selector
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.language_rounded, color: Colors.purple, size: 20),
                    ),
                    title: Text(l10n.language, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(_getLanguageName(settings.languageCode)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showLanguagePicker(context, settingsNotifier, settings.languageCode),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Management Section
            _SectionHeader(title: l10n.management),
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
                    title: Text(l10n.manageCategories, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n.categories),
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
                    title: Text(l10n.dailyHistory, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n.calendar),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/calendar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Backup & Data Section
            _SectionHeader(title: l10n.dataAndBackup),
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
                    title: Text(l10n.backupData, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n.backupSubtitle),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _handleBackup(context, ref),
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
                    title: Text(l10n.restoreData, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n.restoreSubtitle),
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
                    title: Text(
                      l10n.clearAllData,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.expense),
                    ),
                    subtitle: Text(l10n.clearAllDataSubtitle),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final confirmed = await ConfirmDialog.show(
                        context,
                        title: '${l10n.clearAllData}?',
                        message: l10n.clearAllDataSubtitle,
                        confirmLabel: l10n.clearEverything,
                        cancelLabel: l10n.cancel,
                        isDestructive: true,
                      );

                      if (confirmed && context.mounted) {
                        await ref.read(settingsViewModelProvider.notifier).clearAllData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.clearAllDataSubtitle),
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
            _SectionHeader(title: l10n.about),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          AppConstants.appLogoPath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    title: Text(l10n.about, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n.aboutSubtitle),
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

  String _getThemeName(int index, AppLocalizations l10n) {
    switch (index) {
      case 1:
        return l10n.themeLight;
      case 2:
        return l10n.themeDark;
      default:
        return l10n.themeSystem;
    }
  }

  String _getLanguageName(String code) {
    final lang = AppLocalizations.supportedLanguages.firstWhere(
      (l) => l.code == code,
      orElse: () => AppLocalizations.supportedLanguages.first,
    );
    return '${lang.nativeName} (${lang.name})';
  }

  void _showLanguagePicker(BuildContext context, SettingsNotifier notifier, String currentCode) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                  child: Text(
                    l10n.selectLanguage,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: AppLocalizations.supportedLanguages.length,
                    itemBuilder: (context, index) {
                      final lang = AppLocalizations.supportedLanguages[index];
                      final isSelected = lang.code == currentCode;
                      return ListTile(
                        leading: Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: (isSelected ? AppColors.primary : Colors.purple).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            lang.code.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: isSelected ? AppColors.primary : Colors.purple,
                            ),
                          ),
                        ),
                        title: Text(
                          lang.nativeName,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? AppColors.primary : null,
                          ),
                        ),
                        subtitle: Text(lang.name),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                            : null,
                        onTap: () {
                          notifier.updateLanguage(lang.code);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                  child: Text(
                    l10n.selectCurrency,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),
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
          ),
        );
      },
    );
  }

  void _showThemePicker(BuildContext context, SettingsNotifier notifier, int currentMode, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectTheme, style: const TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.themeSystem),
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
              title: Text(l10n.themeLight),
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
              title: Text(l10n.themeDark),
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

  Future<void> _handleBackup(BuildContext context, WidgetRef ref) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final l10n = context.l10n;
    final choice = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.cloud_upload_outlined, color: Colors.blue, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.backupData,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.backupSubtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark
                                     ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildOptionTile(
                context,
                icon: Icons.sd_card_rounded,
                iconColor: Colors.blue,
                title: l10n.downloadToStorage,
                subtitle: l10n.downloadToStorageSubtitle,
                onTap: () => Navigator.pop(context, 'storage'),
              ),
              const SizedBox(height: 10),
              _buildOptionTile(
                context,
                icon: Icons.share_rounded,
                iconColor: Colors.indigo,
                title: l10n.shareViaApps,
                subtitle: l10n.shareViaAppsSubtitle,
                onTap: () => Navigator.pop(context, 'share'),
              ),
              const SizedBox(height: 10),
              _buildOptionTile(
                context,
                icon: Icons.copy_rounded,
                iconColor: Colors.teal,
                title: l10n.copyJson,
                subtitle: l10n.copyJsonSubtitle,
                onTap: () => Navigator.pop(context, 'copy'),
              ),
            ],
          ),
        ),
      ),
    );

    if (choice == null || !context.mounted) return;

    if (choice == 'storage') {
      try {
        final savedPath = await ref.read(settingsViewModelProvider.notifier).saveBackupToStorage();
        if (savedPath != null && context.mounted) {
          final fileName = savedPath.contains('/') ? savedPath.split('/').last : savedPath;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                fileName.isNotEmpty
                    ? 'Backup saved: $fileName'
                    : 'Backup saved to device storage.',
              ),
              backgroundColor: AppColors.income,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save backup: $e'),
              backgroundColor: AppColors.expense,
            ),
          );
        }
      }
    } else if (choice == 'share') {
      try {
        final success = await ref.read(settingsViewModelProvider.notifier).shareBackup();
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.backupReady),
              backgroundColor: AppColors.income,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to share backup: $e'),
              backgroundColor: AppColors.expense,
            ),
          );
        }
      }
    } else if (choice == 'copy') {
      final json = ref.read(settingsViewModelProvider.notifier).getBackupJson();
      await Clipboard.setData(ClipboardData(text: json));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.copyJson),
            backgroundColor: AppColors.income,
          ),
        );
      }
    }
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final l10n = context.l10n;
    final choice = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.cloud_download_outlined, color: Colors.green, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.restoreData,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.restoreSubtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildOptionTile(
                context,
                icon: Icons.sd_card_rounded,
                iconColor: Colors.green,
                title: l10n.selectBackupFile,
                subtitle: l10n.selectBackupFileSubtitle,
                onTap: () => Navigator.pop(context, 'file'),
              ),
              const SizedBox(height: 10),
              _buildOptionTile(
                context,
                icon: Icons.paste_rounded,
                iconColor: AppColors.secondary,
                title: l10n.pasteJsonContent,
                subtitle: l10n.pasteJsonContentSubtitle,
                onTap: () => Navigator.pop(context, 'text'),
              ),
            ],
          ),
        ),
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
          title: Text(l10n.pasteJsonContent),
          content: TextField(
            controller: textController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: l10n.pasteJsonContentSubtitle,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.restoreData),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.asset(
                AppConstants.appLogoPath,
                height: 110,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '${AppConstants.appName} (${AppConstants.appTaglineBengali})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              AppConstants.appTagline,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 24),
            Text(
              '• 100% Offline & Local Storage via Hive\n'
              '• No cloud tracking or personal data collection\n'
              '• Fast expense entry designed for daily use\n'
              '• Complete financial reports and debt management\n'
              '• Free and open local JSON backup/restore (SD card & storage)',
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Version ${AppConstants.appVersion}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(context.l10n.close),
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
