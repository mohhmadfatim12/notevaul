import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../../models/folder.dart';

abstract class FolderLocalDataSource {
  Future<List<FolderModel>> getFolders();
  Future<FolderModel?> getFolderById(String id);
  Future<void> insertFolder(FolderModel folder);
  Future<void> updateFolder(FolderModel folder);
  Future<void> deleteFolder(String id, {required bool moveToUnfiled});
  Future<int> getNoteCountForFolder(String folderId);
  Future<Map<String, int>> getFolderNoteCounts();
}

class FolderLocalDataSourceImpl implements FolderLocalDataSource {
  final DatabaseHelper dbHelper;

  FolderLocalDataSourceImpl({DatabaseHelper? helper})
      : dbHelper = helper ?? DatabaseHelper.instance;

  @override
  Future<List<FolderModel>> getFolders() async {
    final db = await dbHelper.database;
    final results = await db.query(
      DatabaseHelper.tableFolders,
      orderBy: 'name ASC',
    );
    return results.map((m) => FolderModel.fromMap(m)).toList();
  }

  @override
  Future<FolderModel?> getFolderById(String id) async {
    final db = await dbHelper.database;
    final results = await db.query(
      DatabaseHelper.tableFolders,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return FolderModel.fromMap(results.first);
  }

  @override
  Future<void> insertFolder(FolderModel folder) async {
    final db = await dbHelper.database;
    await db.insert(
      DatabaseHelper.tableFolders,
      folder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateFolder(FolderModel folder) async {
    final db = await dbHelper.database;
    await db.update(
      DatabaseHelper.tableFolders,
      folder.toMap(),
      where: 'id = ?',
      whereArgs: [folder.id],
    );
  }

  @override
  Future<void> deleteFolder(String id, {required bool moveToUnfiled}) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      if (moveToUnfiled) {
        // Move all notes in this folder to Unfiled (null folder_id)
        await txn.update(
          DatabaseHelper.tableNotes,
          {'folder_id': null, 'updated_at': DateTime.now().millisecondsSinceEpoch},
          where: 'folder_id = ?',
          whereArgs: [id],
        );
      } else {
        // Soft delete all notes belonging to this folder
        final now = DateTime.now().millisecondsSinceEpoch;
        await txn.update(
          DatabaseHelper.tableNotes,
          {
            'is_deleted': 1,
            'deleted_at': now,
            'updated_at': now,
            'reminder_at': null,
          },
          where: 'folder_id = ?',
          whereArgs: [id],
        );
      }
      // Delete the folder itself
      await txn.delete(
        DatabaseHelper.tableFolders,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<int> getNoteCountForFolder(String folderId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM ${DatabaseHelper.tableNotes}
      WHERE folder_id = ? AND is_deleted = 0 AND is_archived = 0
    ''', [folderId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<Map<String, int>> getFolderNoteCounts() async {
    final db = await dbHelper.database;
    final results = await db.rawQuery('''
      SELECT folder_id, COUNT(*) as count FROM ${DatabaseHelper.tableNotes}
      WHERE folder_id IS NOT NULL AND is_deleted = 0 AND is_archived = 0
      GROUP BY folder_id
    ''');
    final map = <String, int>{};
    for (final row in results) {
      final fId = row['folder_id'] as String?;
      final count = row['count'] as int? ?? 0;
      if (fId != null) {
        map[fId] = count;
      }
    }
    return map;
  }
}
