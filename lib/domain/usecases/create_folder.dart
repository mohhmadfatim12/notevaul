import 'package:notevault/core/utils/result.dart';
import '../entities/folder_entity.dart';
import '../repositories/folder_repository.dart';

class CreateFolderUseCase {
  final FolderRepository repository;

  CreateFolderUseCase(this.repository);

  Future<Result<void>> call(FolderEntity folder) {
    return repository.createFolder(folder);
  }
}
