import 'package:notevault/core/utils/result.dart';
import 'package:notevault/domain/repositories/search_repository.dart';
import '../datasources/local/search_history_datasource.dart';
import '../models/search_history.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchHistoryDataSource localDataSource;

  SearchRepositoryImpl({SearchHistoryDataSource? dataSource})
      : localDataSource = dataSource ?? SearchHistoryDataSourceImpl();

  @override
  Future<Result<List<SearchHistoryModel>>> getRecentSearches({int limit = 10}) async {
    try {
      final list = await localDataSource.getRecentSearches(limit: limit);
      return Result.success(list);
    } catch (e) {
      return Result.failure('Failed to load recent searches: $e');
    }
  }

  @override
  Future<Result<void>> addSearchQuery(String query) async {
    try {
      await localDataSource.addSearchQuery(query);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to save search query: $e');
    }
  }

  @override
  Future<Result<void>> deleteSearchQuery(String id) async {
    try {
      await localDataSource.deleteSearchQuery(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to delete search query: $e');
    }
  }

  @override
  Future<Result<void>> clearAllSearchHistory() async {
    try {
      await localDataSource.clearAllSearchHistory();
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to clear search history: $e');
    }
  }
}
