import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/datasources/hive_service.dart';
import '../../common_providers.dart';

class SettingsViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  HiveService get _hiveService => ref.read(hiveServiceProvider);

  Future<bool> exportBackup() async {
    state = const AsyncValue.loading();
    try {
      final jsonString = _hiveService.exportDataAsJson();
      final dateStr = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final fileName = 'hisheb_backup_$dateStr.json';

      await SharePlus.instance.share(
        ShareParams(
          text: jsonString,
          subject: 'Hisheb Backup ($fileName)',
        ),
      );

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<Map<String, int>?> restoreBackupFromFile() async {
    state = const AsyncValue.loading();
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (files.isEmpty) {
        state = const AsyncValue.data(null);
        return null;
      }

      String? jsonContent;
      final file = files.first;
      if (file.path != null) {
        jsonContent = await File(file.path!).readAsString();
      } else {
        final bytes = await file.readAsBytes();
        jsonContent = String.fromCharCodes(bytes);
      }

      if (jsonContent.trim().isEmpty) {
        throw Exception('Backup file was empty.');
      }

      final counts = await _hiveService.importDataFromJson(jsonContent);
      state = const AsyncValue.data(null);
      return counts;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Map<String, int>> restoreBackupFromText(String jsonContent) async {
    state = const AsyncValue.loading();
    try {
      final counts = await _hiveService.importDataFromJson(jsonContent);
      state = const AsyncValue.data(null);
      return counts;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> clearAllData() async {
    state = const AsyncValue.loading();
    try {
      await _hiveService.clearAllData();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final settingsViewModelProvider =
    AsyncNotifierProvider<SettingsViewModel, void>(SettingsViewModel.new);
