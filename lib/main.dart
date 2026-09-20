import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/hive_service.dart';
import 'presentation/common_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and seed defaults
  final hiveService = HiveService();
  await hiveService.init();

  runApp(
    const ProviderScope(
      child: HishebApp(),
    ),
  );
}

class HishebApp extends ConsumerWidget {
  const HishebApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
