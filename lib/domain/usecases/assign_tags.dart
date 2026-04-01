import 'package:notevault/core/utils/result.dart';
import '../repositories/tag_repository.dart';

class AssignTagsUseCase {
  final TagRepository repository;

  AssignTagsUseCase(this.repository);

  Future<Result<void>> call(String noteId, List<String> tagIds) {
    return repository.assignTagsToNote(noteId, tagIds);
  }
}
