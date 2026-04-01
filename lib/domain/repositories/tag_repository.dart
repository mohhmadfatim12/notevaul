import '../entities/tag_entity.dart';
import 'package:notevault/core/utils/result.dart';

abstract class TagRepository {
  Future<Result<List<TagEntity>>> getTags();
  Future<Result<TagEntity?>> getTagById(String id);
  Future<Result<void>> createTag(TagEntity tag);
  Future<Result<void>> updateTag(TagEntity tag);
  Future<Result<void>> deleteTag(String id);
  Future<Result<List<TagEntity>>> getTagsForNote(String noteId);
  Future<Result<void>> assignTagsToNote(String noteId, List<String> tagIds);
}
