import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/datasources/hive_service.dart';
import '../../common_providers.dart';

class SettingsViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  HiveService get _hiveService => ref.read(hiveServiceProvider);

  Future<String?> saveBackupToStorage() async {
    state = const AsyncValue.loading();
    try {
      final jsonString = _hiveService.exportDataAsJson();
      final dateStr = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final fileName = 'hisheb_backup_$dateStr.json';
      final bytes = Uint8List.fromList(utf8.encode(jsonString));

      final savedUri = await FilePicker.saveFile(
        dialogTitle: 'Save Backup File (Internal Storage / SD Card)',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      if (savedUri != null) {
        if (savedUri.isScheme('file')) {
          try {
            final file = File(savedUri.toFilePath());
            if (!await file.exists() || (await file.length()) == 0) {
              await file.writeAsBytes(bytes);
            }
          } catch (_) {
            // Handled by platform
          }
        }
      }

      state = const AsyncValue.data(null);
      return savedUri != null ? (savedUri.pathSegments.isNotEmpty ? savedUri.pathSegments.last : fileName) : null;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<bool> shareBackup() async {
    state = const AsyncValue.loading();
    try {
      final jsonString = _hiveService.exportDataAsJson();
      final dateStr = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final fileName = 'hisheb_backup_$dateStr.json';

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsString(jsonString);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tempFile.path)],
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

  String getBackupJson() {
    return _hiveService.exportDataAsJson();
  }

  Future<bool> exportBackup() async {
    return shareBackup();
  }

  Future<Map<String, int>?> restoreBackupFromFile() async {
    state = const AsyncValue.loading();
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
      );

      if (files.isEmpty) {
        state = const AsyncValue.data(null);
        return null;
      }

      final file = files.first;
      String? jsonContent;

      try {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) {
          jsonContent = utf8.decode(bytes);
        }
      } catch (_) {
        if (file.path != null) {
          jsonContent = await File(file.path!).readAsString();
        }
      }

      if (jsonContent == null && file.path != null) {
        jsonContent = await File(file.path!).readAsString();
      }

      if (jsonContent == null || jsonContent.trim().isEmpty) {
        throw Exception('Selected backup file was empty or could not be read.');
      }

      final counts = await _hiveService.importDataFromJson(jsonContent);

      // Invalidate reactive providers to update all screens immediately
      ref.invalidate(settingsProvider);
      ref.invalidate(transactionsStreamProvider);
      ref.invalidate(categoriesStreamProvider);
      ref.invalidate(debtsStreamProvider);

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

      // Invalidate reactive providers to update all screens immediately
      ref.invalidate(settingsProvider);
      ref.invalidate(transactionsStreamProvider);
      ref.invalidate(categoriesStreamProvider);
      ref.invalidate(debtsStreamProvider);

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

      // Invalidate reactive providers
      ref.invalidate(settingsProvider);
      ref.invalidate(transactionsStreamProvider);
      ref.invalidate(categoriesStreamProvider);
      ref.invalidate(debtsStreamProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final settingsViewModelProvider =
    AsyncNotifierProvider<SettingsViewModel, void>(SettingsViewModel.new);
