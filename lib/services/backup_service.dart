import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:notevault/core/utils/result.dart';
import 'package:notevault/data/models/backup_model.dart';
import 'package:notevault/domain/repositories/backup_repository.dart';

class BackupService {
  final BackupRepository backupRepository;

  BackupService(this.backupRepository);

  /// Generates backup JSON file and opens share dialog to save/export it safely.
  Future<Result<String>> exportBackupToFile() async {
    try {
      final exportResult = await backupRepository.exportBackup();
      if (exportResult.isFailure) {
        return Result.failure(exportResult.errorOrNull ?? 'Failed to export data');
      }

      final backupModel = exportResult.dataOrNull!;
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupModel.toJson());

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${dir.path}/notevault_backup_$timestamp.json');
      await file.writeAsString(jsonString);

      // Offer user option to share or save the file externally
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          text: 'NoteVault Complete Offline Backup',
          subject: 'NoteVault Backup ($timestamp)',
        ),
      );

      return Result.success(file.path);
    } catch (e) {
      return Result.failure('Export failed: $e');
    }
  }

  /// Picks a backup JSON file from device storage, validates, and restores data.
  Future<Result<void>> pickAndRestoreBackup() async {
    try {
      final pickedFiles = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (pickedFiles.isEmpty) {
        return Result.failure('No backup file selected');
      }

      final path = pickedFiles.first.path;
      if (path == null) {
        return Result.failure('Unable to access selected file');
      }

      final file = File(path);
      final content = await file.readAsString();

      final validation = await backupRepository.validateBackupString(content);
      if (validation.isFailure) {
        return Result.failure(validation.errorOrNull ?? 'Invalid backup file structure');
      }

      final dynamic parsed = jsonDecode(content);
      final backupModel = BackupModel.fromJson(parsed as Map<String, dynamic>);

      final restoreResult = await backupRepository.restoreBackup(backupModel);
      return restoreResult;
    } catch (e) {
      return Result.failure('Restore failed: $e');
    }
  }
}
