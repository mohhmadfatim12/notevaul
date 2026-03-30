import 'package:notevault/core/utils/result.dart';
import 'package:notevault/domain/entities/tag_entity.dart';
import 'package:notevault/domain/repositories/tag_repository.dart';
import '../datasources/local/tag_local_datasource.dart';
import '../models/tag.dart';

class TagRepositoryImpl implements TagRepository {
  final TagLocalDataSource localDataSource;

  TagRepositoryImpl({TagLocalDataSource? dataSource})
      : localDataSource = dataSource ?? TagLocalDataSourceImpl();

  @override
  Future<Result<List<TagEntity>>> getTags() async {
    try {
      final models = await localDataSource.getTags();
      final counts = await localDataSource.getTagNoteCounts();
      final entities = models.map((m) {
        final count = counts[m.id] ?? 0;
        return m.toEntity(noteCount: count);
      }).toList();
      return Result.success(entities);
    } catch (e) {
      return Result.failure('Failed to load tags: $e');
    }
  }

  @override
  Future<Result<TagEntity?>> getTagById(String id) async {
    try {
      final model = await localDataSource.getTagById(id);
      if (model == null) return Result.success(null);
      return Result.success(model.toEntity());
    } catch (e) {
      return Result.failure('Failed to fetch tag: $e');
    }
  }

  @override
  Future<Result<void>> createTag(TagEntity tag) async {
    try {
      final existing = await localDataSource.getTagByName(tag.name);
      if (existing != null) {
        return Result.failure('A tag with the name "${tag.name}" already exists.');
      }
      await localDataSource.insertTag(TagModel.fromEntity(tag));
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to create tag: $e');
    }
  }

  @override
  Future<Result<void>> updateTag(TagEntity tag) async {
    try {
      final existing = await localDataSource.getTagByName(tag.name);
      if (existing != null && existing.id != tag.id) {
        return Result.failure('Another tag with the name "${tag.name}" already exists.');
      }
      await localDataSource.updateTag(TagModel.fromEntity(tag));
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to update tag: $e');
    }
  }

  @override
  Future<Result<void>> deleteTag(String id) async {
    try {
      await localDataSource.deleteTag(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to delete tag: $e');
    }
  }

  @override
  Future<Result<List<TagEntity>>> getTagsForNote(String noteId) async {
    try {
      final models = await localDataSource.getTagsForNote(noteId);
      return Result.success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Result.failure('Failed to get tags for note: $e');
    }
  }

  @override
  Future<Result<void>> assignTagsToNote(String noteId, List<String> tagIds) async {
    try {
      await localDataSource.assignTagsToNote(noteId, tagIds);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to assign tags: $e');
    }
  }
}
