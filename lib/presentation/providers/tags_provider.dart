import 'package:flutter/material.dart';
import 'package:notevault/domain/entities/tag_entity.dart';
import 'package:notevault/domain/repositories/tag_repository.dart';

class TagsProvider extends ChangeNotifier {
  final TagRepository _repository;

  List<TagEntity> _tags = [];
  bool _isLoading = false;
  String? _errorMessage;

  TagsProvider(this._repository) {
    loadTags();
  }

  List<TagEntity> get tags => _tags;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTags() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getTags();
    result.fold(
      onSuccess: (data) {
        _tags = data;
        _isLoading = false;
        notifyListeners();
      },
      onFailure: (message, _) {
        _errorMessage = message;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> createTag(TagEntity tag) async {
    final result = await _repository.createTag(tag);
    if (result.isSuccess) {
      await loadTags();
      return true;
    } else {
      _errorMessage = result.errorOrNull;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTag(TagEntity tag) async {
    final result = await _repository.updateTag(tag);
    if (result.isSuccess) {
      await loadTags();
      return true;
    } else {
      _errorMessage = result.errorOrNull;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTag(String id) async {
    final result = await _repository.deleteTag(id);
    if (result.isSuccess) {
      await loadTags();
      return true;
    } else {
      _errorMessage = result.errorOrNull;
      notifyListeners();
      return false;
    }
  }
}
