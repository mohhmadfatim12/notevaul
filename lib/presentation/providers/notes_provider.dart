import 'package:flutter/material.dart';
import 'package:notevault/core/utils/result.dart';
import 'package:notevault/data/datasources/local/note_local_datasource.dart';
import 'package:notevault/domain/entities/note_entity.dart';
import 'package:notevault/domain/repositories/note_repository.dart';
import 'package:notevault/services/notification_service.dart';

class NotesProvider extends ChangeNotifier {
  final NoteRepository _repository;
  final NotificationService _notificationService;

  List<NoteEntity> _notes = [];
  List<NoteEntity> _pinnedNotes = [];
  List<NoteEntity> _favoriteNotes = [];
  List<NoteEntity> _archivedNotes = [];
  List<NoteEntity> _trashNotes = [];
  List<NoteEntity> _reminderNotes = [];
  DashboardStats? _dashboardStats;

  NoteSortOption _currentSort = NoteSortOption.newestUpdated;
  String? _selectedFolderId;
  String? _selectedTagId;
  int? _selectedColorId;

  // Multi-select state
  final Set<String> _selectedIds = {};
  bool _isMultiSelect = false;

  bool _isLoading = false;
  String? _errorMessage;

  NotesProvider(this._repository, {NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService.instance {
    loadAll();
  }

  // Getters
  List<NoteEntity> get notes => _notes;
  List<NoteEntity> get pinnedNotes => _pinnedNotes;
  List<NoteEntity> get favoriteNotes => _favoriteNotes;
  List<NoteEntity> get archivedNotes => _archivedNotes;
  List<NoteEntity> get trashNotes => _trashNotes;
  List<NoteEntity> get reminderNotes => _reminderNotes;
  DashboardStats? get dashboardStats => _dashboardStats;

  NoteSortOption get currentSort => _currentSort;
  String? get selectedFolderId => _selectedFolderId;
  String? get selectedTagId => _selectedTagId;
  int? get selectedColorId => _selectedColorId;

  bool get isMultiSelect => _isMultiSelect;
  Set<String> get selectedIds => _selectedIds;
  int get selectedCount => _selectedIds.length;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Multi-select actions
  void enterMultiSelect(String initialId) {
    _isMultiSelect = true;
    _selectedIds.clear();
    _selectedIds.add(initialId);
    notifyListeners();
  }

  void toggleSelection(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
      if (_selectedIds.isEmpty) {
        _isMultiSelect = false;
      }
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedIds.clear();
    _selectedIds.addAll(_notes.map((n) => n.id));
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    _isMultiSelect = false;
    notifyListeners();
  }

  // Filter setters
  void setSortOption(NoteSortOption sort) {
    _currentSort = sort;
    loadNotes();
  }

  void setFolderFilter(String? folderId) {
    _selectedFolderId = folderId;
    loadNotes();
  }

  void setTagFilter(String? tagId) {
    _selectedTagId = tagId;
    loadNotes();
  }

  void setColorFilter(int? colorId) {
    _selectedColorId = colorId;
    loadNotes();
  }

  void clearFilters() {
    _selectedFolderId = null;
    _selectedTagId = null;
    _selectedColorId = null;
    loadNotes();
  }

  // Data Loading
  Future<void> loadAll() async {
    await Future.wait([
      loadNotes(),
      loadPinnedNotes(),
      loadFavoriteNotes(),
      loadArchivedNotes(),
      loadTrashNotes(),
      loadReminders(),
      loadDashboardStats(),
    ]);
    // Also perform silent 30-day trash cleanup on launch
    await cleanupExpiredTrash();
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    Result<List<NoteEntity>> result;
    if (_selectedFolderId != null) {
      result = await _repository.getNotesByFolder(_selectedFolderId!);
    } else if (_selectedTagId != null) {
      result = await _repository.getNotesByTag(_selectedTagId!);
    } else if (_selectedColorId != null) {
      result = await _repository.getNotesByColor(_selectedColorId!);
    } else {
      result = await _repository.getActiveNotes(sort: _currentSort);
    }

    result.fold(
      onSuccess: (data) {
        _notes = data;
        _isLoading = false;
        notifyListeners();
      },
      onFailure: (msg, _) {
        _errorMessage = msg;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> loadPinnedNotes() async {
    final result = await _repository.getPinnedNotes();
    if (result.isSuccess) {
      _pinnedNotes = result.dataOrNull ?? [];
      notifyListeners();
    }
  }

  Future<void> loadFavoriteNotes() async {
    final result = await _repository.getFavoriteNotes();
    if (result.isSuccess) {
      _favoriteNotes = result.dataOrNull ?? [];
      notifyListeners();
    }
  }

  Future<void> loadArchivedNotes() async {
    final result = await _repository.getArchivedNotes();
    if (result.isSuccess) {
      _archivedNotes = result.dataOrNull ?? [];
      notifyListeners();
    }
  }

  Future<void> loadTrashNotes() async {
    final result = await _repository.getTrashNotes();
    if (result.isSuccess) {
      _trashNotes = result.dataOrNull ?? [];
      notifyListeners();
    }
  }

  Future<void> loadReminders() async {
    final result = await _repository.getNotesWithReminders();
    if (result.isSuccess) {
      _reminderNotes = result.dataOrNull ?? [];
      notifyListeners();
    }
  }

  Future<void> loadDashboardStats() async {
    final result = await _repository.getDashboardStats();
    if (result.isSuccess) {
      _dashboardStats = result.dataOrNull;
      notifyListeners();
    }
  }

  // CRUD Operations
  Future<bool> createNote(NoteEntity note, {List<String> tagIds = const []}) async {
    final result = await _repository.createNote(note, tagIds: tagIds);
    if (result.isSuccess) {
      if (note.reminderAt != null) {
        await _notificationService.scheduleReminder(
          noteId: note.id,
          title: note.title,
          body: note.body,
          scheduledDate: note.reminderAt!,
        );
      }
      await loadAll();
      return true;
    }
    _errorMessage = result.errorOrNull;
    notifyListeners();
    return false;
  }

  Future<bool> updateNote(NoteEntity note, {List<String>? tagIds}) async {
    final result = await _repository.updateNote(note, tagIds: tagIds);
    if (result.isSuccess) {
      if (note.reminderAt != null) {
        await _notificationService.scheduleReminder(
          noteId: note.id,
          title: note.title,
          body: note.body,
          scheduledDate: note.reminderAt!,
        );
      } else {
        await _notificationService.cancelReminder(note.id);
      }
      await loadAll();
      return true;
    }
    _errorMessage = result.errorOrNull;
    notifyListeners();
    return false;
  }

  Future<bool> softDeleteNote(String id) async {
    await _notificationService.cancelReminder(id);
    final result = await _repository.softDeleteNote(id);
    if (result.isSuccess) {
      await loadAll();
      return true;
    }
    return false;
  }

  Future<bool> restoreNote(String id) async {
    final result = await _repository.restoreNote(id);
    if (result.isSuccess) {
      await loadAll();
      return true;
    }
    return false;
  }

  Future<bool> permanentlyDeleteNote(String id) async {
    await _notificationService.cancelReminder(id);
    final result = await _repository.permanentlyDeleteNote(id);
    if (result.isSuccess) {
      await loadAll();
      return true;
    }
    return false;
  }

  Future<bool> emptyTrash() async {
    for (final note in _trashNotes) {
      await _notificationService.cancelReminder(note.id);
    }
    final result = await _repository.emptyTrash();
    if (result.isSuccess) {
      await loadAll();
      return true;
    }
    return false;
  }

  Future<int> cleanupExpiredTrash({int expiryDays = 30}) async {
    final result = await _repository.cleanupExpiredTrash(expiryDays: expiryDays);
    if (result.isSuccess) {
      final count = result.dataOrNull ?? 0;
      if (count > 0) {
        await loadTrashNotes();
        await loadDashboardStats();
      }
      return count;
    }
    return 0;
  }

  Future<void> togglePin(NoteEntity note) async {
    await _repository.togglePin(note.id, !note.isPinned);
    await loadAll();
  }

  Future<void> toggleFavorite(NoteEntity note) async {
    await _repository.toggleFavorite(note.id, !note.isFavorite);
    await loadAll();
  }

  Future<void> toggleArchive(NoteEntity note) async {
    if (!note.isArchived) {
      await _notificationService.cancelReminder(note.id);
    }
    await _repository.toggleArchive(note.id, !note.isArchived);
    await loadAll();
  }

  // Bulk operations
  Future<void> bulkPin(bool pin) async {
    final ids = _selectedIds.toList();
    clearSelection();
    await _repository.bulkPin(ids, pin);
    await loadAll();
  }

  Future<void> bulkFavorite(bool favorite) async {
    final ids = _selectedIds.toList();
    clearSelection();
    await _repository.bulkFavorite(ids, favorite);
    await loadAll();
  }

  Future<void> bulkArchive(bool archive) async {
    final ids = _selectedIds.toList();
    clearSelection();
    for (final id in ids) {
      await _notificationService.cancelReminder(id);
    }
    await _repository.bulkArchive(ids, archive);
    await loadAll();
  }

  Future<void> bulkMoveToFolder(String? folderId) async {
    final ids = _selectedIds.toList();
    clearSelection();
    await _repository.bulkMoveToFolder(ids, folderId);
    await loadAll();
  }

  Future<void> bulkAddTag(String tagId) async {
    final ids = _selectedIds.toList();
    clearSelection();
    await _repository.bulkAddTag(ids, tagId);
    await loadAll();
  }

  Future<void> bulkDelete() async {
    final ids = _selectedIds.toList();
    clearSelection();
    for (final id in ids) {
      await _notificationService.cancelReminder(id);
    }
    await _repository.bulkDelete(ids);
    await loadAll();
  }
}
