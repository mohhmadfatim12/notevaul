import 'package:notevault/core/utils/result.dart';
import 'package:notevault/domain/entities/folder_entity.dart';
import 'package:notevault/domain/repositories/folder_repository.dart';
import '../datasources/local/folder_local_datasource.dart';
import '../models/folder.dart';

class FolderRepositoryImpl implements FolderRepository {
  final FolderLocalDataSource localDataSource;

  FolderRepositoryImpl({FolderLocalDataSource? dataSource})
      : localDataSource = dataSource ?? FolderLocalDataSourceImpl();

  @override
  Future<Result<List<FolderEntity>>> getFolders() async {
    try {
      final models = await localDataSource.getFolders();
      final counts = await localDataSource.getFolderNoteCounts();
      final entities = models.map((m) {
        final count = counts[m.id] ?? 0;
        return m.toEntity(noteCount: count);
      }).toList();
      return Result.success(entities);
    } catch (e) {
      return Result.failure('Failed to load folders: $e');
    }
  }

  @override
  Future<Result<FolderEntity?>> getFolderById(String id) async {
    try {
      final model = await localDataSource.getFolderById(id);
      if (model == null) return Result.success(null);
      final count = await localDataSource.getNoteCountForFolder(id);
      return Result.success(model.toEntity(noteCount: count));
    } catch (e) {
      return Result.failure('Failed to fetch folder: $e');
    }
  }

  @override
  Future<Result<void>> createFolder(FolderEntity folder) async {
    try {
      await localDataSource.insertFolder(FolderModel.fromEntity(folder));
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to create folder: $e');
    }
  }

  @override
  Future<Result<void>> updateFolder(FolderEntity folder) async {
    try {
      await localDataSource.updateFolder(FolderModel.fromEntity(folder));
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to update folder: $e');
    }
  }

  @override
  Future<Result<void>> deleteFolder(String id, {required bool moveToUnfiled}) async {
    try {
      await localDataSource.deleteFolder(id, moveToUnfiled: moveToUnfiled);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to delete folder: $e');
    }
  }
}
