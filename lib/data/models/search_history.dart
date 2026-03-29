/// Model representing a recent search query.
class SearchHistoryModel {
  final String id;
  final String query;
  final int searchedAt;

  const SearchHistoryModel({
    required this.id,
    required this.query,
    required this.searchedAt,
  });

  factory SearchHistoryModel.fromMap(Map<String, dynamic> map) {
    return SearchHistoryModel(
      id: map['id'] as String,
      query: map['query'] as String,
      searchedAt: map['searched_at'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'query': query,
      'searched_at': searchedAt,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory SearchHistoryModel.fromJson(Map<String, dynamic> json) =>
      SearchHistoryModel.fromMap(json);
}
