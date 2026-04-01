import '../entities/note_entity.dart';
import 'package:notevault/core/utils/result.dart';
import 'package:notevault/data/datasources/local/note_local_datasource.dart';

class DashboardStats {
  final int totalNotes;
  final int totalFolders;
  final int totalTags;
  final int totalPinned;
  final int totalFavorites;
  final int totalArchived;
  final int totalTrash;
  final int createdThisWeek;
  final int updatedThisWeek;
  final List<NoteEntity> upcomingReminders;
  final Map<int, int> weeklyActivityByDay; // weekday (1=Mon..7=Sun) -> count

  const DashboardStats({
    required this.totalNotes,
    required this.totalFolders,
    required this.totalTags,
    required this.totalPinned,
    required this.totalFavorites,
    required this.totalArchived,
    required this.totalTrash,
    required this.createdThisWeek,
    required this.updatedThisWeek,
    required this.upcomingReminders,
    required this.weeklyActivityByDay,
  });
}

abstract class NoteRepository {
  Future<Result<List<NoteEntity>>> getActiveNotes({NoteSortOption sort = NoteSortOption.newestUpdated});
  Future<Result<List<NoteEntity>>> getPinnedNotes();
  Future<Result<List<NoteEntity>>> getFavoriteNotes();
  Future<Result<List<NoteEntity>>> getArchivedNotes();
  Future<Result<List<NoteEntity>>> getTrashNotes();
  Future<Result<List<NoteEntity>>> getNotesByFolder(String folderId);
  Future<Result<List<NoteEntity>>> getNotesByTag(String tagId);
  Future<Result<List<NoteEntity>>> getNotesByColor(int color);
  Future<Result<List<NoteEntity>>> getNotesWithReminders();
  Future<Result<NoteEntity?>> getNoteById(String id);
  Future<Result<void>> createNote(NoteEntity note, {List<String> tagIds = const []});
  Future<Result<void>> updateNote(NoteEntity note, {List<String>? tagIds});
  Future<Result<void>> softDeleteNote(String id);
  Future<Result<void>> restoreNote(String id);
  Future<Result<void>> permanentlyDeleteNote(String id);
  Future<Result<void>> emptyTrash();
  Future<Result<int>> cleanupExpiredTrash({int expiryDays = 30});
  Future<Result<void>> togglePin(String id, bool isPinned);
  Future<Result<void>> toggleFavorite(String id, bool isFavorite);
  Future<Result<void>> toggleArchive(String id, bool isArchived);
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
  });
  Future<Result<void>> bulkPin(List<String> ids, bool pin);
  Future<Result<void>> bulkFavorite(List<String> ids, bool favorite);
  Future<Result<void>> bulkArchive(List<String> ids, bool archive);
  Future<Result<void>> bulkMoveToFolder(List<String> ids, String? folderId);
  Future<Result<void>> bulkAddTag(List<String> ids, String tagId);
  Future<Result<void>> bulkDelete(List<String> ids);
  Future<Result<DashboardStats>> getDashboardStats();
}
