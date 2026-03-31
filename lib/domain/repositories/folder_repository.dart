import '../entities/folder_entity.dart';
import 'package:notevault/core/utils/result.dart';

abstract class FolderRepository {
  Future<Result<List<FolderEntity>>> getFolders();
  Future<Result<FolderEntity?>> getFolderById(String id);
  Future<Result<void>> createFolder(FolderEntity folder);
  Future<Result<void>> updateFolder(FolderEntity folder);
  Future<Result<void>> deleteFolder(String id, {required bool moveToUnfiled});
}
