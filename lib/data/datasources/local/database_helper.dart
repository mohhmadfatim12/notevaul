import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

/// Singleton SQLite database manager for NoteVault.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static const String databaseName = 'notevault.db';
  static const int databaseVersion = 2;

  // Table Names
  static const String tableFolders = 'folders';
  static const String tableNotes = 'notes';
  static const String tableTags = 'tags';
  static const String tableNoteTags = 'note_tags';
  static const String tableSearchHistory = 'search_history';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, databaseName);

    return await openDatabase(
      path,
      version: databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableFolders (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        icon TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE $tableNotes (
        id TEXT PRIMARY KEY,
        folder_id TEXT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        color INTEGER NOT NULL,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        is_archived INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        reminder_at INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,
        FOREIGN KEY (folder_id) REFERENCES $tableFolders (id) ON DELETE SET NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE $tableTags (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        color INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE $tableNoteTags (
        note_id TEXT NOT NULL,
        tag_id TEXT NOT NULL,
        PRIMARY KEY (note_id, tag_id),
        FOREIGN KEY (note_id) REFERENCES $tableNotes (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES $tableTags (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE $tableSearchHistory (
        id TEXT PRIMARY KEY,
        query TEXT NOT NULL,
        searched_at INTEGER NOT NULL
      );
    ''');

    // Create Indexes
    await _createIndexes(db);
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute('CREATE INDEX IF NOT EXISTS idx_notes_title ON $tableNotes (title);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_notes_updated_at ON $tableNotes (updated_at);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_notes_folder_id ON $tableNotes (folder_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_notes_is_pinned ON $tableNotes (is_pinned);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_notes_is_deleted ON $tableNotes (is_deleted);');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Version 2 migration: Ensure all indexes exist
      await _createIndexes(db);
    }
  }

  /// Closes database connection.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Completely wipes database (used for reset app data).
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(tableNoteTags);
      await txn.delete(tableNotes);
      await txn.delete(tableFolders);
      await txn.delete(tableTags);
      await txn.delete(tableSearchHistory);
    });
  }
}
