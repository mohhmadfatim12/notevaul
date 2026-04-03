import 'package:notevault/core/utils/result.dart';
import '../repositories/note_repository.dart';

class DeleteNoteUseCase {
  final NoteRepository repository;

  DeleteNoteUseCase(this.repository);

  Future<Result<void>> softDelete(String id) {
    return repository.softDeleteNote(id);
  }

  Future<Result<void>> permanentDelete(String id) {
    return repository.permanentlyDeleteNote(id);
  }
}
