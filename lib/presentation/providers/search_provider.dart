import 'package:flutter/material.dart';
import 'package:notevault/core/utils/debouncer.dart';
import 'package:notevault/data/models/search_history.dart';
import 'package:notevault/domain/entities/note_entity.dart';
import 'package:notevault/domain/repositories/note_repository.dart';
import 'package:notevault/domain/repositories/search_repository.dart';

class SearchProvider extends ChangeNotifier {
  final NoteRepository _noteRepository;
  final SearchRepository _searchRepository;
  final Debouncer _debouncer = Debouncer(delay: const Duration(milliseconds: 300));

  String _query = '';
  List<NoteEntity> _results = [];
  List<SearchHistoryModel> _recentSearches = [];
  bool _isLoading = false;

  // Filter criteria
  String? _filterFolderId;
  String? _filterTagId;
  int? _filterColor;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  bool? _filterPinned;
  bool? _filterFavorite;
  bool? _filterArchived;
  bool? _filterTrash;

  SearchProvider(this._noteRepository, this._searchRepository) {
    loadRecentSearches();
  }

  String get query => _query;
  List<NoteEntity> get results => _results;
  List<SearchHistoryModel> get recentSearches => _recentSearches;
  bool get isLoading => _isLoading;

  String? get filterFolderId => _filterFolderId;
  String? get filterTagId => _filterTagId;
  int? get filterColor => _filterColor;
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;
  bool? get filterPinned => _filterPinned;
  bool? get filterFavorite => _filterFavorite;
  bool? get filterArchived => _filterArchived;
  bool? get filterTrash => _filterTrash;

  bool get hasActiveFilters =>
      _filterFolderId != null ||
      _filterTagId != null ||
      _filterColor != null ||
      _filterStartDate != null ||
      _filterEndDate != null ||
      _filterPinned != null ||
      _filterFavorite != null ||
      _filterArchived != null ||
      _filterTrash != null;

  void setFolderFilter(String? folderId) {
    _filterFolderId = folderId;
    performSearch();
  }

  void setTagFilter(String? tagId) {
    _filterTagId = tagId;
    performSearch();
  }

  void setColorFilter(int? color) {
    _filterColor = color;
    performSearch();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _filterStartDate = start;
    _filterEndDate = end;
    performSearch();
  }

  void setStatusFilter({
    bool? pinned,
    bool? favorite,
    bool? archived,
    bool? trash,
  }) {
    _filterPinned = pinned;
    _filterFavorite = favorite;
    _filterArchived = archived;
    _filterTrash = trash;
    performSearch();
  }

  void clearFilters() {
    _filterFolderId = null;
    _filterTagId = null;
    _filterColor = null;
    _filterStartDate = null;
    _filterEndDate = null;
    _filterPinned = null;
    _filterFavorite = null;
    _filterArchived = null;
    _filterTrash = null;
    performSearch();
  }

  void onQueryChanged(String query) {
    _query = query;
    _debouncer.run(() {
      performSearch();
    });
  }

  Future<void> performSearch() async {
    final trimmed = _query.trim();
    if (trimmed.isEmpty && !hasActiveFilters) {
      _results = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    if (trimmed.isNotEmpty) {
      await _searchRepository.addSearchQuery(trimmed);
      await loadRecentSearches();
    }

    final result = await _noteRepository.searchNotes(
      query: trimmed,
      folderId: _filterFolderId,
      tagId: _filterTagId,
      color: _filterColor,
      startDate: _filterStartDate,
      endDate: _filterEndDate,
      isPinned: _filterPinned,
      isFavorite: _filterFavorite,
      isArchived: _filterArchived,
      isTrash: _filterTrash,
    );

    if (result.isSuccess) {
      _results = result.dataOrNull ?? [];
    } else {
      _results = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadRecentSearches() async {
    final result = await _searchRepository.getRecentSearches(limit: 8);
    if (result.isSuccess) {
      _recentSearches = result.dataOrNull ?? [];
      notifyListeners();
    }
  }

  Future<void> deleteRecentSearch(String id) async {
    await _searchRepository.deleteSearchQuery(id);
    await loadRecentSearches();
  }

  Future<void> clearRecentSearches() async {
    await _searchRepository.clearAllSearchHistory();
    _recentSearches = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }
}
