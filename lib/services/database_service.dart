import 'package:sqflite/sqflite.dart';
import 'package:notevault/data/datasources/local/database_helper.dart';

/// Service facade for database management and maintenance.
class DatabaseService {
  final DatabaseHelper _helper;

  DatabaseService({DatabaseHelper? helper}) : _helper = helper ?? DatabaseHelper.instance;

  Future<Database> get database => _helper.database;

  Future<void> clearAllData() => _helper.clearAllData();

  Future<void> close() => _helper.close();
}
