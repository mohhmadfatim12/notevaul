import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../../models/tag.dart';

abstract class TagLocalDataSource {
  Future<List<TagModel>> getTags();
  Future<TagModel?> getTagById(String id);
  Future<TagModel?> getTagByName(String name);
  Future<void> insertTag(TagModel tag);
  Future<void> updateTag(TagModel tag);
  Future<void> deleteTag(String id);
  Future<List<TagModel>> getTagsForNote(String noteId);
  Future<void> assignTagsToNote(String noteId, List<String> tagIds);
  Future<Map<String, int>> getTagNoteCounts();
}

class TagLocalDataSourceImpl implements TagLocalDataSource {
  final DatabaseHelper dbHelper;

  TagLocalDataSourceImpl({DatabaseHelper? helper})
      : dbHelper = helper ?? DatabaseHelper.instance;

  @override
  Future<List<TagModel>> getTags() async {
    final db = await dbHelper.database;
    final results = await db.query(
      DatabaseHelper.tableTags,
      orderBy: 'name ASC',
    );
    return results.map((m) => TagModel.fromMap(m)).toList();
  }

  @override
  Future<TagModel?> getTagById(String id) async {
    final db = await dbHelper.database;
    final results = await db.query(
      DatabaseHelper.tableTags,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return TagModel.fromMap(results.first);
  }

  @override
  Future<TagModel?> getTagByName(String name) async {
    final db = await dbHelper.database;
    final results = await db.query(
      DatabaseHelper.tableTags,
      where: 'LOWER(name) = ?',
      whereArgs: [name.toLowerCase().trim()],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return TagModel.fromMap(results.first);
  }

  @override
  Future<void> insertTag(TagModel tag) async {
    final db = await dbHelper.database;
    await db.insert(
      DatabaseHelper.tableTags,
      tag.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  @override
  Future<void> updateTag(TagModel tag) async {
    final db = await dbHelper.database;
    await db.update(
      DatabaseHelper.tableTags,
      tag.toMap(),
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }

  @override
  Future<void> deleteTag(String id) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      // Junction rows are deleted via ON DELETE CASCADE, but explicit delete guarantees integrity
      await txn.delete(
        DatabaseHelper.tableNoteTags,
        where: 'tag_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        DatabaseHelper.tableTags,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<List<TagModel>> getTagsForNote(String noteId) async {
    final db = await dbHelper.database;
    final results = await db.rawQuery('''
      SELECT t.* FROM ${DatabaseHelper.tableTags} t
      INNER JOIN ${DatabaseHelper.tableNoteTags} nt ON t.id = nt.tag_id
      WHERE nt.note_id = ?
      ORDER BY t.name ASC
    ''', [noteId]);
    return results.map((m) => TagModel.fromMap(m)).toList();
  }

  @override
  Future<void> assignTagsToNote(String noteId, List<String> tagIds) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        DatabaseHelper.tableNoteTags,
        where: 'note_id = ?',
        whereArgs: [noteId],
      );
      for (final tId in tagIds) {
        await txn.insert(
          DatabaseHelper.tableNoteTags,
          {'note_id': noteId, 'tag_id': tId},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }

  @override
  Future<Map<String, int>> getTagNoteCounts() async {
    final db = await dbHelper.database;
    final results = await db.rawQuery('''
      SELECT nt.tag_id, COUNT(DISTINCT n.id) as count
      FROM ${DatabaseHelper.tableNoteTags} nt
      INNER JOIN ${DatabaseHelper.tableNotes} n ON nt.note_id = n.id
      WHERE n.is_deleted = 0 AND n.is_archived = 0
      GROUP BY nt.tag_id
    ''');
    final map = <String, int>{};
    for (final row in results) {
      final tId = row['tag_id'] as String?;
      final count = row['count'] as int? ?? 0;
      if (tId != null) {
        map[tId] = count;
      }
    }
    return map;
  }
}
