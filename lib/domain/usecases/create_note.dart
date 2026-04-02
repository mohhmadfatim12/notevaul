import 'package:notevault/core/utils/result.dart';
import '../entities/note_entity.dart';
import '../repositories/note_repository.dart';

class CreateNoteUseCase {
  final NoteRepository repository;

  CreateNoteUseCase(this.repository);

  Future<Result<void>> call(NoteEntity note, {List<String> tagIds = const []}) {
    return repository.createNote(note, tagIds: tagIds);
  }
}
