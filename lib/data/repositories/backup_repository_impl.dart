import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:notevault/core/utils/result.dart';
import 'package:notevault/domain/repositories/backup_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/backup_model.dart';
import '../models/folder.dart';
import '../models/note.dart';
import '../models/note_tag.dart';
import '../models/tag.dart';

class BackupRepositoryImpl implements BackupRepository {
  final DatabaseHelper dbHelper;

  BackupRepositoryImpl({DatabaseHelper? helper})
      : dbHelper = helper ?? DatabaseHelper.instance;

  @override
  Future<Result<BackupModel>> exportBackup() async {
    try {
      final db = await dbHelper.database;
      final folderRows = await db.query(DatabaseHelper.tableFolders);
      final tagRows = await db.query(DatabaseHelper.tableTags);
      final noteRows = await db.query(DatabaseHelper.tableNotes);
      final noteTagRows = await db.query(DatabaseHelper.tableNoteTags);

      final backup = BackupModel(
        version: 1,
        appName: 'NoteVault',
        exportedAt: DateTime.now().millisecondsSinceEpoch,
        folders: folderRows.map((m) => FolderModel.fromMap(m)).toList(),
        tags: tagRows.map((m) => TagModel.fromMap(m)).toList(),
        notes: noteRows.map((m) => NoteModel.fromMap(m)).toList(),
        noteTags: noteTagRows.map((m) => NoteTagModel.fromMap(m)).toList(),
      );

      return Result.success(backup);
    } catch (e) {
      return Result.failure('Failed to generate offline backup: $e');
    }
  }

  @override
  Future<Result<bool>> validateBackupString(String jsonContent) async {
    try {
      final dynamic parsed = jsonDecode(jsonContent);
      if (parsed is! Map<String, dynamic>) {
        return Result.failure('Invalid backup file: Root must be a JSON object.');
      }
      final backup = BackupModel.fromJson(parsed);
      if (!backup.isValid()) {
        return Result.failure(
            'Incompatible backup file: Signature mismatch or invalid schema version.');
      }
      return Result.success(true);
    } catch (e) {
      return Result.failure('Corrupt or malformed backup JSON: $e');
    }
  }

  @override
  Future<Result<void>> restoreBackup(BackupModel backup) async {
    try {
      if (!backup.isValid()) {
        return Result.failure('Backup verification failed: Incompatible format.');
      }

      final db = await dbHelper.database;
      await db.transaction((txn) async {
        // Clear existing tables
        await txn.delete(DatabaseHelper.tableNoteTags);
        await txn.delete(DatabaseHelper.tableNotes);
        await txn.delete(DatabaseHelper.tableFolders);
        await txn.delete(DatabaseHelper.tableTags);

        // Restore Folders
        for (final f in backup.folders) {
          await txn.insert(
            DatabaseHelper.tableFolders,
            f.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // Restore Tags
        for (final t in backup.tags) {
          await txn.insert(
            DatabaseHelper.tableTags,
            t.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // Restore Notes
        for (final n in backup.notes) {
          await txn.insert(
            DatabaseHelper.tableNotes,
            n.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // Restore NoteTags junction rows
        for (final nt in backup.noteTags) {
          await txn.insert(
            DatabaseHelper.tableNoteTags,
            nt.toMap(),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to restore backup: $e');
    }
  }
}
