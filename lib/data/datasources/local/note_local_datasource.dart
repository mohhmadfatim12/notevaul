import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../../models/note.dart';
import '../../models/tag.dart';

enum NoteSortOption {
  newestUpdated,
  oldestUpdated,
  newestCreated,
  oldestCreated,
  titleAsc,
  titleDesc,
}

abstract class NoteLocalDataSource {
  Future<List<NoteModel>> getActiveNotes({NoteSortOption sort = NoteSortOption.newestUpdated});
  Future<List<NoteModel>> getPinnedNotes();
  Future<List<NoteModel>> getFavoriteNotes();
  Future<List<NoteModel>> getArchivedNotes();
  Future<List<NoteModel>> getTrashNotes();
  Future<List<NoteModel>> getNotesByFolder(String folderId);
  Future<List<NoteModel>> getNotesByTag(String tagId);
  Future<List<NoteModel>> getNotesByColor(int color);
  Future<List<NoteModel>> getNotesWithReminders();
  Future<NoteModel?> getNoteById(String id);
  Future<void> insertNote(NoteModel note, {List<String> tagIds = const []});
  Future<void> updateNote(NoteModel note, {List<String>? tagIds});
  Future<void> softDeleteNote(String id);
  Future<void> restoreNote(String id);
  Future<void> permanentlyDeleteNote(String id);
  Future<void> emptyTrash();
  Future<int> cleanupExpiredTrash({int expiryDays = 30});
  Future<void> togglePin(String id, bool isPinned);
  Future<void> toggleFavorite(String id, bool isFavorite);
  Future<void> toggleArchive(String id, bool isArchived);
  Future<List<NoteModel>> searchNotes({
    required String query,
    String? folderId,
    String? tagId,
    int? color,
    DateTime? startDate,
    DateTime? endDate,
    bool? isPinned,
    bool? isFavorite,
    bool? isArchived,
    bool? isTrash,
  });
  Future<void> bulkPin(List<String> ids, bool pin);
  Future<void> bulkFavorite(List<String> ids, bool favorite);
  Future<void> bulkArchive(List<String> ids, bool archive);
  Future<void> bulkMoveToFolder(List<String> ids, String? folderId);
  Future<void> bulkAddTag(List<String> ids, String tagId);
  Future<void> bulkDelete(List<String> ids);
  Future<int> countTotalNotes();
  Future<int> countPinnedNotes();
  Future<int> countFavoriteNotes();
  Future<int> countArchivedNotes();
  Future<int> countTrashNotes();
  Future<int> countCreatedSince(int epochMillis);
  Future<int> countUpdatedSince(int epochMillis);
  Future<List<TagModel>> getTagsForNote(String noteId);
  Future<String?> getFolderName(String? folderId);
}

class NoteLocalDataSourceImpl implements NoteLocalDataSource {
  final DatabaseHelper dbHelper;

  NoteLocalDataSourceImpl({DatabaseHelper? helper})
      : dbHelper = helper ?? DatabaseHelper.instance;

  String _getOrderBy(NoteSortOption sort) {
    switch (sort) {
      case NoteSortOption.newestUpdated:
        return 'is_pinned DESC, updated_at DESC';
      case NoteSortOption.oldestUpdated:
        return 'is_pinned DESC, updated_at ASC';
      case NoteSortOption.newestCreated:
        return 'is_pinned DESC, created_at DESC';
      case NoteSortOption.oldestCreated:
        return 'is_pinned DESC, created_at ASC';
      case NoteSortOption.titleAsc:
        return 'is_pinned DESC, LOWER(title) ASC';
      case NoteSortOption.titleDesc:
        return 'is_pinned DESC, LOWER(title) DESC';
    }
  }

  @override
  Future<List<NoteModel>> getActiveNotes({NoteSortOption sort = NoteSortOption.newestUpdated}) async {
    final db = await dbHelper.database;
    final results = await db.query(
      DatabaseHelper.tableNotes,
      where: 'is_deleted = 0 AND is_archived = 0',
      orderBy: _getOrderBy(sort),
    );
    return results.map((m) => NoteModel.fromMap(m)).toList();
  }

  @override
  Future<List<NoteModel>> getPinnedNotes() async {
    final db = await dbHelper.database;
    final results = await db.query(
      DatabaseHelper.tableNotes,
      where: 'is_pinned = 1 AND is_deleted = 0 AND is_archived = 0',
      orderBy: 'updated_at DESC',
    );
    return results.map((m) => NoteModel.fromMap(m)).toList();
  }

  @override
  Future<List<NoteModel>> getFavoriteNotes() async {
    final db = await dbHelper.database;
    final results = await db.query(
      DatabaseHelper.tableNotes,
      where: 'is_favorite = 1 AND is_deleted = 0 AND is_archived = 0',
      orderBy: 'updated_at DESC',
    );
    return results.map((m) => NoteModel.fromMap(m)).toList();
  }

  @override
  Future<List<NoteModel>> getArchivedNotes() async {
    final db = await dbHelper.database;
    final results = await db.query(
      DatabaseHelper.tableNotes,
      where: 'is_archived = 1 AND is_deleted = 0',
      orderBy: 'updated_at DESC',
    );
    return results.map((m) => NoteModel.fromMap(m)).toList();
  }

  @override
  Future<List<NoteModel>> getTrashNotes() async {
    final db = await dbHelper.database;
    final results = await db.query(
      DatabaseHelper.tableNotes,
      where: 'is_deleted = 1',
      orderBy: 'deleted_at DESC',
    );
    return results.map((m) => NoteModel.fromMap(m)).toList();
  }

  @override
  Future<List<NoteModel>> getNotesByFolder(String folderId) async {
    final db = await dbHelper.database;
    final results = await db.query(
      DatabaseHelper.tableNotes,
      where: 'folder_id = ? AND is_deleted = 0 AND is_archived = 0',
      whereArgs: [folderId],
      orderBy: 'is_pinned DESC, updated_at DESC',
    );
    return results.map((m) => NoteModel.fromMap(m)).toList();
  }

  @override
  Future<List<NoteModel>> getNotesByTag(String tagId) async {
    final db = await dbHelper.database;
    final results = await db.rawQuery('''
      SELECT n.* FROM ${DatabaseHelper.tableNotes} n
      INNER JOIN ${DatabaseHelper.tableNoteTags} nt ON n.id = nt.note_id
      WHERE nt.tag_id = ? AND n.is_deleted = 0 AND n.is_archived = 0
      ORDER BY n.is_pinned DESC, n.updated_at DESC
    ''', [tagId]);
    return results.map((m) => NoteModel.fromMap(m)).toList();
  }

  @override
  Future<List<NoteModel>> getNotesByColor(int color) async {
    final db = await dbHelper.database;
    final results = await db.query(
      DatabaseHelper.tableNotes,
      where: 'color = ? AND is_deleted = 0 AND is_archived = 0',
      whereArgs: [color],
      orderBy: 'is_pinned DESC, updated_at DESC',
    );
    return results.map((m) => NoteModel.fromMap(m)).toList();
  }

  @override
  Future<List<NoteModel>> getNotesWithReminders() async {
    final db = await dbHelper.database;
    final results = await db.query(
      DatabaseHelper.tableNotes,
      where: 'reminder_at IS NOT NULL AND is_deleted = 0 AND is_archived = 0',
      orderBy: 'reminder_at ASC',
    );
    return results.map((m) => NoteModel.fromMap(m)).toList();
  }

  @override
  Future<NoteModel?> getNoteById(String id) async {
    final db = await dbHelper.database;
    final results = await db.query(
      DatabaseHelper.tableNotes,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return NoteModel.fromMap(results.first);
  }

  @override
  Future<void> insertNote(NoteModel note, {List<String> tagIds = const []}) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert(
        DatabaseHelper.tableNotes,
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (final tId in tagIds) {
        await txn.insert(
          DatabaseHelper.tableNoteTags,
          {'note_id': note.id, 'tag_id': tId},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }

  @override
  Future<void> updateNote(NoteModel note, {List<String>? tagIds}) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.update(
        DatabaseHelper.tableNotes,
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
      if (tagIds != null) {
        await txn.delete(
          DatabaseHelper.tableNoteTags,
          where: 'note_id = ?',
          whereArgs: [note.id],
        );
        for (final tId in tagIds) {
          await txn.insert(
            DatabaseHelper.tableNoteTags,
            {'note_id': note.id, 'tag_id': tId},
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    });
  }

  @override
  Future<void> softDeleteNote(String id) async {
    final db = await dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      DatabaseHelper.tableNotes,
      {
        'is_deleted': 1,
        'deleted_at': now,
        'updated_at': now,
        'reminder_at': null, // Cancel reminder on trash
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> restoreNote(String id) async {
    final db = await dbHelper.database;
    await db.update(
      DatabaseHelper.tableNotes,
      {
        'is_deleted': 0,
        'deleted_at': null,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> permanentlyDeleteNote(String id) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        DatabaseHelper.tableNoteTags,
        where: 'note_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        DatabaseHelper.tableNotes,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<void> emptyTrash() async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.rawDelete('''
        DELETE FROM ${DatabaseHelper.tableNoteTags}
        WHERE note_id IN (SELECT id FROM ${DatabaseHelper.tableNotes} WHERE is_deleted = 1)
      ''');
      await txn.delete(
        DatabaseHelper.tableNotes,
        where: 'is_deleted = 1',
      );
    });
  }

  @override
  Future<int> cleanupExpiredTrash({int expiryDays = 30}) async {
    final db = await dbHelper.database;
    final cutoff = DateTime.now()
        .subtract(Duration(days: expiryDays))
        .millisecondsSinceEpoch;
    var count = 0;
    await db.transaction((txn) async {
      await txn.rawDelete('''
        DELETE FROM ${DatabaseHelper.tableNoteTags}
        WHERE note_id IN (
          SELECT id FROM ${DatabaseHelper.tableNotes}
          WHERE is_deleted = 1 AND deleted_at IS NOT NULL AND deleted_at < ?
        )
      ''', [cutoff]);
      count = await txn.delete(
        DatabaseHelper.tableNotes,
        where: 'is_deleted = 1 AND deleted_at IS NOT NULL AND deleted_at < ?',
        whereArgs: [cutoff],
      );
    });
    return count;
  }

  @override
  Future<void> togglePin(String id, bool isPinned) async {
    final db = await dbHelper.database;
    await db.update(
      DatabaseHelper.tableNotes,
      {
        'is_pinned': isPinned ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final db = await dbHelper.database;
    await db.update(
      DatabaseHelper.tableNotes,
      {
        'is_favorite': isFavorite ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> toggleArchive(String id, bool isArchived) async {
    final db = await dbHelper.database;
    await db.update(
      DatabaseHelper.tableNotes,
      {
        'is_archived': isArchived ? 1 : 0,
        'reminder_at': isArchived ? null : null,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<NoteModel>> searchNotes({
    required String query,
    String? folderId,
    String? tagId,
    int? color,
    DateTime? startDate,
    DateTime? endDate,
    bool? isPinned,
    bool? isFavorite,
    bool? isArchived,
    bool? isTrash,
  }) async {
    final db = await dbHelper.database;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    // Status condition
    if (isTrash == true) {
      whereClauses.add('n.is_deleted = 1');
    } else {
      whereClauses.add('n.is_deleted = 0');
      if (isArchived == true) {
        whereClauses.add('n.is_archived = 1');
      } else if (isArchived == false) {
        whereClauses.add('n.is_archived = 0');
      }
    }

    if (isPinned != null) {
      whereClauses.add('n.is_pinned = ?');
      whereArgs.add(isPinned ? 1 : 0);
    }
    if (isFavorite != null) {
      whereClauses.add('n.is_favorite = ?');
      whereArgs.add(isFavorite ? 1 : 0);
    }
    if (folderId != null) {
      whereClauses.add('n.folder_id = ?');
      whereArgs.add(folderId);
    }
    if (color != null) {
      whereClauses.add('n.color = ?');
      whereArgs.add(color);
    }
    if (startDate != null) {
      whereClauses.add('n.created_at >= ?');
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }
    if (endDate != null) {
      whereClauses.add('n.created_at <= ?');
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }

    // Query match across title, body, tag name, folder name
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      final pattern = '%$trimmed%';
      whereClauses.add('''
        (n.title LIKE ? OR n.body LIKE ? OR f.name LIKE ? OR t.name LIKE ?)
      ''');
      whereArgs.addAll([pattern, pattern, pattern, pattern]);
    }

    if (tagId != null) {
      whereClauses.add('nt.tag_id = ?');
      whereArgs.add(tagId);
    }

    final whereString = whereClauses.isNotEmpty
        ? 'WHERE ${whereClauses.join(' AND ')}'
        : '';

    final sql = '''
      SELECT DISTINCT n.* FROM ${DatabaseHelper.tableNotes} n
      LEFT JOIN ${DatabaseHelper.tableFolders} f ON n.folder_id = f.id
      LEFT JOIN ${DatabaseHelper.tableNoteTags} nt ON n.id = nt.note_id
      LEFT JOIN ${DatabaseHelper.tableTags} t ON nt.tag_id = t.id
      $whereString
      ORDER BY n.is_pinned DESC, n.updated_at DESC
    ''';

    final results = await db.rawQuery(sql, whereArgs);
    return results.map((m) => NoteModel.fromMap(m)).toList();
  }

  @override
  Future<void> bulkPin(List<String> ids, bool pin) async {
    if (ids.isEmpty) return;
    final db = await dbHelper.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawUpdate('''
      UPDATE ${DatabaseHelper.tableNotes}
      SET is_pinned = ?, updated_at = ?
      WHERE id IN ($placeholders)
    ''', [pin ? 1 : 0, DateTime.now().millisecondsSinceEpoch, ...ids]);
  }

  @override
  Future<void> bulkFavorite(List<String> ids, bool favorite) async {
    if (ids.isEmpty) return;
    final db = await dbHelper.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawUpdate('''
      UPDATE ${DatabaseHelper.tableNotes}
      SET is_favorite = ?, updated_at = ?
      WHERE id IN ($placeholders)
    ''', [favorite ? 1 : 0, DateTime.now().millisecondsSinceEpoch, ...ids]);
  }

  @override
  Future<void> bulkArchive(List<String> ids, bool archive) async {
    if (ids.isEmpty) return;
    final db = await dbHelper.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawUpdate('''
      UPDATE ${DatabaseHelper.tableNotes}
      SET is_archived = ?, reminder_at = NULL, updated_at = ?
      WHERE id IN ($placeholders)
    ''', [archive ? 1 : 0, DateTime.now().millisecondsSinceEpoch, ...ids]);
  }

  @override
  Future<void> bulkMoveToFolder(List<String> ids, String? folderId) async {
    if (ids.isEmpty) return;
    final db = await dbHelper.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawUpdate('''
      UPDATE ${DatabaseHelper.tableNotes}
      SET folder_id = ?, updated_at = ?
      WHERE id IN ($placeholders)
    ''', [folderId, DateTime.now().millisecondsSinceEpoch, ...ids]);
  }

  @override
  Future<void> bulkAddTag(List<String> ids, String tagId) async {
    if (ids.isEmpty) return;
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      for (final id in ids) {
        await txn.insert(
          DatabaseHelper.tableNoteTags,
          {'note_id': id, 'tag_id': tagId},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }

  @override
  Future<void> bulkDelete(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await dbHelper.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.rawUpdate('''
      UPDATE ${DatabaseHelper.tableNotes}
      SET is_deleted = 1, deleted_at = ?, reminder_at = NULL, updated_at = ?
      WHERE id IN ($placeholders)
    ''', [now, now, ...ids]);
  }

  @override
  Future<int> countTotalNotes() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM ${DatabaseHelper.tableNotes}
      WHERE is_deleted = 0 AND is_archived = 0
    ''');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<int> countPinnedNotes() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM ${DatabaseHelper.tableNotes}
      WHERE is_pinned = 1 AND is_deleted = 0 AND is_archived = 0
    ''');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<int> countFavoriteNotes() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM ${DatabaseHelper.tableNotes}
      WHERE is_favorite = 1 AND is_deleted = 0 AND is_archived = 0
    ''');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<int> countArchivedNotes() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM ${DatabaseHelper.tableNotes}
      WHERE is_archived = 1 AND is_deleted = 0
    ''');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<int> countTrashNotes() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM ${DatabaseHelper.tableNotes}
      WHERE is_deleted = 1
    ''');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<int> countCreatedSince(int epochMillis) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM ${DatabaseHelper.tableNotes}
      WHERE created_at >= ? AND is_deleted = 0
    ''', [epochMillis]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<int> countUpdatedSince(int epochMillis) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM ${DatabaseHelper.tableNotes}
      WHERE updated_at >= ? AND is_deleted = 0
    ''', [epochMillis]);
    return Sqflite.firstIntValue(result) ?? 0;
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
  Future<String?> getFolderName(String? folderId) async {
    if (folderId == null) return null;
    final db = await dbHelper.database;
    final results = await db.query(
      DatabaseHelper.tableFolders,
      columns: ['name'],
      where: 'id = ?',
      whereArgs: [folderId],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return results.first['name'] as String?;
  }
}
