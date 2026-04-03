import 'package:notevault/core/utils/result.dart';
import '../repositories/note_repository.dart';

class RestoreNoteUseCase {
  final NoteRepository repository;

  RestoreNoteUseCase(this.repository);

  Future<Result<void>> call(String id) {
    return repository.restoreNote(id);
  }
}
