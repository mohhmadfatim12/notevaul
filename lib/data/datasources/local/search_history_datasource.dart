import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../local/database_helper.dart';
import '../../models/search_history.dart';

abstract class SearchHistoryDataSource {
  Future<List<SearchHistoryModel>> getRecentSearches({int limit = 10});
  Future<void> addSearchQuery(String query);
  Future<void> deleteSearchQuery(String id);
  Future<void> clearAllSearchHistory();
}

class SearchHistoryDataSourceImpl implements SearchHistoryDataSource {
  final DatabaseHelper dbHelper;
  final Uuid _uuid = const Uuid();

  SearchHistoryDataSourceImpl({DatabaseHelper? helper})
      : dbHelper = helper ?? DatabaseHelper.instance;

  @override
  Future<List<SearchHistoryModel>> getRecentSearches({int limit = 10}) async {
    final db = await dbHelper.database;
    final results = await db.query(
      DatabaseHelper.tableSearchHistory,
      orderBy: 'searched_at DESC',
      limit: limit,
    );
    return results.map((m) => SearchHistoryModel.fromMap(m)).toList();
  }

  @override
  Future<void> addSearchQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final db = await dbHelper.database;
    await db.transaction((txn) async {
      // Remove any existing exact duplicate to bubble this to top
      await txn.delete(
        DatabaseHelper.tableSearchHistory,
        where: 'LOWER(query) = ?',
        whereArgs: [trimmed.toLowerCase()],
      );
      await txn.insert(
        DatabaseHelper.tableSearchHistory,
        SearchHistoryModel(
          id: _uuid.v4(),
          query: trimmed,
          searchedAt: DateTime.now().millisecondsSinceEpoch,
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  @override
  Future<void> deleteSearchQuery(String id) async {
    final db = await dbHelper.database;
    await db.delete(
      DatabaseHelper.tableSearchHistory,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> clearAllSearchHistory() async {
    final db = await dbHelper.database;
    await db.delete(DatabaseHelper.tableSearchHistory);
  }
}
