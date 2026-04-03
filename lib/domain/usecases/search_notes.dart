import 'package:notevault/core/utils/result.dart';
import '../entities/note_entity.dart';
import '../repositories/note_repository.dart';

class SearchNotesUseCase {
  final NoteRepository repository;

  SearchNotesUseCase(this.repository);

  Future<Result<List<NoteEntity>>> call({
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
  }) {
    return repository.searchNotes(
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
  }
}
