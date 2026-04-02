import 'package:notevault/core/utils/result.dart';
import 'package:notevault/data/models/backup_model.dart';
import '../repositories/backup_repository.dart';

class CreateBackupUseCase {
  final BackupRepository repository;

  CreateBackupUseCase(this.repository);

  Future<Result<BackupModel>> call() {
    return repository.exportBackup();
  }
}
