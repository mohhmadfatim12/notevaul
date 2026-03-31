import 'package:notevault/core/utils/result.dart';
import 'package:notevault/data/models/backup_model.dart';

abstract class BackupRepository {
  Future<Result<BackupModel>> exportBackup();
  Future<Result<void>> restoreBackup(BackupModel backup);
  Future<Result<bool>> validateBackupString(String jsonContent);
}
