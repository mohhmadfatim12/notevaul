import 'package:notevault/core/utils/result.dart';
import 'package:notevault/data/models/search_history.dart';

abstract class SearchRepository {
  Future<Result<List<SearchHistoryModel>>> getRecentSearches({int limit = 10});
  Future<Result<void>> addSearchQuery(String query);
  Future<Result<void>> deleteSearchQuery(String id);
  Future<Result<void>> clearAllSearchHistory();
}
