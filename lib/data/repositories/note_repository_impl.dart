import 'package:notevault/core/utils/result.dart';
import 'package:notevault/domain/entities/note_entity.dart';
import 'package:notevault/domain/repositories/note_repository.dart';
import '../datasources/local/database_helper.dart';
import '../datasources/local/folder_local_datasource.dart';
import '../datasources/local/note_local_datasource.dart';
import '../datasources/local/tag_local_datasource.dart';
import '../models/note.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource localDataSource;
  final TagLocalDataSource tagDataSource;
  final FolderLocalDataSource folderDataSource;
  final DatabaseHelper dbHelper;

  NoteRepositoryImpl({
    NoteLocalDataSource? noteSource,
    TagLocalDataSource? tagSource,
    FolderLocalDataSource? folderSource,
    DatabaseHelper? helper,
  })  : localDataSource = noteSource ?? NoteLocalDataSourceImpl(),
        tagDataSource = tagSource ?? TagLocalDataSourceImpl(),
        folderDataSource = folderSource ?? FolderLocalDataSourceImpl(),
        dbHelper = helper ?? DatabaseHelper.instance;

  Future<NoteEntity> _hydrateNote(NoteModel model) async {
    final tags = await localDataSource.getTagsForNote(model.id);
    final folderName = await localDataSource.getFolderName(model.folderId);
    return model.toEntity(
      tags: tags.map((t) => t.toEntity()).toList(),
      folderName: folderName,
    );
  }

  Future<List<NoteEntity>> _hydrateNotes(List<NoteModel> models) async {
    return Future.wait(models.map(_hydrateNote));
  }

  @override
  Future<Result<List<NoteEntity>>> getActiveNotes({NoteSortOption sort = NoteSortOption.newestUpdated}) async {
    try {
      final models = await localDataSource.getActiveNotes(sort: sort);
      final entities = await _hydrateNotes(models);
      return Result.success(entities);
    } catch (e) {
      return Result.failure('Failed to load active notes: $e');
    }
  }

  @override
  Future<Result<List<NoteEntity>>> getPinnedNotes() async {
    try {
      final models = await localDataSource.getPinnedNotes();
      final entities = await _hydrateNotes(models);
      return Result.success(entities);
    } catch (e) {
      return Result.failure('Failed to load pinned notes: $e');
    }
  }

  @override
  Future<Result<List<NoteEntity>>> getFavoriteNotes() async {
    try {
      final models = await localDataSource.getFavoriteNotes();
      final entities = await _hydrateNotes(models);
      return Result.success(entities);
    } catch (e) {
      return Result.failure('Failed to load favorite notes: $e');
    }
  }

  @override
  Future<Result<List<NoteEntity>>> getArchivedNotes() async {
    try {
      final models = await localDataSource.getArchivedNotes();
      final entities = await _hydrateNotes(models);
      return Result.success(entities);
    } catch (e) {
      return Result.failure('Failed to load archived notes: $e');
    }
  }

  @override
  Future<Result<List<NoteEntity>>> getTrashNotes() async {
    try {
      final models = await localDataSource.getTrashNotes();
      final entities = await _hydrateNotes(models);
      return Result.success(entities);
    } catch (e) {
      return Result.failure('Failed to load trash notes: $e');
    }
  }

  @override
  Future<Result<List<NoteEntity>>> getNotesByFolder(String folderId) async {
    try {
      final models = await localDataSource.getNotesByFolder(folderId);
      final entities = await _hydrateNotes(models);
      return Result.success(entities);
    } catch (e) {
      return Result.failure('Failed to load folder notes: $e');
    }
  }

  @override
  Future<Result<List<NoteEntity>>> getNotesByTag(String tagId) async {
    try {
      final models = await localDataSource.getNotesByTag(tagId);
      final entities = await _hydrateNotes(models);
      return Result.success(entities);
    } catch (e) {
      return Result.failure('Failed to load tag notes: $e');
    }
  }

  @override
  Future<Result<List<NoteEntity>>> getNotesByColor(int color) async {
    try {
      final models = await localDataSource.getNotesByColor(color);
      final entities = await _hydrateNotes(models);
      return Result.success(entities);
    } catch (e) {
      return Result.failure('Failed to load color notes: $e');
    }
  }

  @override
  Future<Result<List<NoteEntity>>> getNotesWithReminders() async {
    try {
      final models = await localDataSource.getNotesWithReminders();
      final entities = await _hydrateNotes(models);
      return Result.success(entities);
    } catch (e) {
      return Result.failure('Failed to load reminders: $e');
    }
  }

  @override
  Future<Result<NoteEntity?>> getNoteById(String id) async {
    try {
      final model = await localDataSource.getNoteById(id);
      if (model == null) return Result.success(null);
      final entity = await _hydrateNote(model);
      return Result.success(entity);
    } catch (e) {
      return Result.failure('Failed to load note: $e');
    }
  }

  @override
  Future<Result<void>> createNote(NoteEntity note, {List<String> tagIds = const []}) async {
    try {
      final model = NoteModel.fromEntity(note);
      await localDataSource.insertNote(model, tagIds: tagIds);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to create note: $e');
    }
  }

  @override
  Future<Result<void>> updateNote(NoteEntity note, {List<String>? tagIds}) async {
    try {
      final model = NoteModel.fromEntity(note);
      await localDataSource.updateNote(model, tagIds: tagIds);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to update note: $e');
    }
  }

  @override
  Future<Result<void>> softDeleteNote(String id) async {
    try {
      await localDataSource.softDeleteNote(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to delete note: $e');
    }
  }

  @override
  Future<Result<void>> restoreNote(String id) async {
    try {
      await localDataSource.restoreNote(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to restore note: $e');
    }
  }

  @override
  Future<Result<void>> permanentlyDeleteNote(String id) async {
    try {
      await localDataSource.permanentlyDeleteNote(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to permanently delete note: $e');
    }
  }

  @override
  Future<Result<void>> emptyTrash() async {
    try {
      await localDataSource.emptyTrash();
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to empty trash: $e');
    }
  }

  @override
  Future<Result<int>> cleanupExpiredTrash({int expiryDays = 30}) async {
    try {
      final count = await localDataSource.cleanupExpiredTrash(expiryDays: expiryDays);
      return Result.success(count);
    } catch (e) {
      return Result.failure('Failed to cleanup trash: $e');
    }
  }

  @override
  Future<Result<void>> togglePin(String id, bool isPinned) async {
    try {
      await localDataSource.togglePin(id, isPinned);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to toggle pin: $e');
    }
  }

  @override
  Future<Result<void>> toggleFavorite(String id, bool isFavorite) async {
    try {
      await localDataSource.toggleFavorite(id, isFavorite);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to toggle favorite: $e');
    }
  }

  @override
  Future<Result<void>> toggleArchive(String id, bool isArchived) async {
    try {
      await localDataSource.toggleArchive(id, isArchived);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to toggle archive: $e');
    }
  }

  @override
  Future<Result<List<NoteEntity>>> searchNotes({
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
    try {
      final models = await localDataSource.searchNotes(
        query: query,
        folderId: folderId,
        tagId: tagId,
        color: color,
        startDate: startDate,
        endDate: endDate,
        isPinned: isPinned,
        isFavorite: isFavorite,
        isArchived: isArchived,
        isTrash: isTrash,
      );
      final entities = await _hydrateNotes(models);
      return Result.success(entities);
    } catch (e) {
      return Result.failure('Failed to perform search: $e');
    }
  }

  @override
  Future<Result<void>> bulkPin(List<String> ids, bool pin) async {
    try {
      await localDataSource.bulkPin(ids, pin);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to bulk pin: $e');
    }
  }

  @override
  Future<Result<void>> bulkFavorite(List<String> ids, bool favorite) async {
    try {
      await localDataSource.bulkFavorite(ids, favorite);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to bulk favorite: $e');
    }
  }

  @override
  Future<Result<void>> bulkArchive(List<String> ids, bool archive) async {
    try {
      await localDataSource.bulkArchive(ids, archive);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to bulk archive: $e');
    }
  }

  @override
  Future<Result<void>> bulkMoveToFolder(List<String> ids, String? folderId) async {
    try {
      await localDataSource.bulkMoveToFolder(ids, folderId);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to bulk move: $e');
    }
  }

  @override
  Future<Result<void>> bulkAddTag(List<String> ids, String tagId) async {
    try {
      await localDataSource.bulkAddTag(ids, tagId);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to bulk tag: $e');
    }
  }

  @override
  Future<Result<void>> bulkDelete(List<String> ids) async {
    try {
      await localDataSource.bulkDelete(ids);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to bulk delete: $e');
    }
  }

  @override
  Future<Result<DashboardStats>> getDashboardStats() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final weekStartEpoch = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)
          .millisecondsSinceEpoch;

      final totalNotes = await localDataSource.countTotalNotes();
      final totalPinned = await localDataSource.countPinnedNotes();
      final totalFavorites = await localDataSource.countFavoriteNotes();
      final totalArchived = await localDataSource.countArchivedNotes();
      final totalTrash = await localDataSource.countTrashNotes();
      final createdThisWeek = await localDataSource.countCreatedSince(weekStartEpoch);
      final updatedThisWeek = await localDataSource.countUpdatedSince(weekStartEpoch);

      // Folders & tags count
      final db = await dbHelper.database;
      final fRes = await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseHelper.tableFolders}');
      final tRes = await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseHelper.tableTags}');
      final totalFolders = fRes.first.values.first as int? ?? 0;
      final totalTags = tRes.first.values.first as int? ?? 0;

      // Reminders
      final reminderModels = await localDataSource.getNotesWithReminders();
      final upcoming = reminderModels
          .where((m) => m.reminderAt != null && m.reminderAt! >= now.millisecondsSinceEpoch)
          .take(5)
          .toList();
      final upcomingEntities = await _hydrateNotes(upcoming);

      // Weekly activity by weekday (1=Mon..7=Sun)
      final weeklyActivity = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
      final recentNotes = await db.rawQuery('''
        SELECT updated_at FROM ${DatabaseHelper.tableNotes}
        WHERE updated_at >= ? AND is_deleted = 0
      ''', [weekStartEpoch]);

      for (final row in recentNotes) {
        final epoch = row['updated_at'] as int;
        final dt = DateTime.fromMillisecondsSinceEpoch(epoch);
        final day = dt.weekday;
        weeklyActivity[day] = (weeklyActivity[day] ?? 0) + 1;
      }

      return Result.success(DashboardStats(
        totalNotes: totalNotes,
        totalFolders: totalFolders,
        totalTags: totalTags,
        totalPinned: totalPinned,
        totalFavorites: totalFavorites,
        totalArchived: totalArchived,
        totalTrash: totalTrash,
        createdThisWeek: createdThisWeek,
        updatedThisWeek: updatedThisWeek,
        upcomingReminders: upcomingEntities,
        weeklyActivityByDay: weeklyActivity,
      ));
    } catch (e) {
      return Result.failure('Failed to compile dashboard stats: $e');
    }
  }
}
