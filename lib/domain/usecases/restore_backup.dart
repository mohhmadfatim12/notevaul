import 'package:notevault/core/utils/result.dart';
import 'package:notevault/data/models/backup_model.dart';
import '../repositories/backup_repository.dart';

class RestoreBackupUseCase {
  final BackupRepository repository;

  RestoreBackupUseCase(this.repository);

  Future<Result<void>> call(BackupModel backup) {
    return repository.restoreBackup(backup);
  }
}
