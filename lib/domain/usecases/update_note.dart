import 'package:notevault/core/utils/result.dart';
import '../entities/note_entity.dart';
import '../repositories/note_repository.dart';

class UpdateNoteUseCase {
  final NoteRepository repository;

  UpdateNoteUseCase(this.repository);

  Future<Result<void>> call(NoteEntity note, {List<String>? tagIds}) {
    return repository.updateNote(note, tagIds: tagIds);
  }
}
