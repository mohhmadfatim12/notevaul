import 'package:flutter/material.dart';
import 'package:notevault/domain/entities/folder_entity.dart';
import 'package:notevault/domain/repositories/folder_repository.dart';

class FoldersProvider extends ChangeNotifier {
  final FolderRepository _repository;

  List<FolderEntity> _folders = [];
  bool _isLoading = false;
  String? _errorMessage;

  FoldersProvider(this._repository) {
    loadFolders();
  }

  List<FolderEntity> get folders => _folders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadFolders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getFolders();
    result.fold(
      onSuccess: (data) {
        _folders = data;
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

  Future<bool> createFolder(FolderEntity folder) async {
    final result = await _repository.createFolder(folder);
    if (result.isSuccess) {
      await loadFolders();
      return true;
    } else {
      _errorMessage = result.errorOrNull;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateFolder(FolderEntity folder) async {
    final result = await _repository.updateFolder(folder);
    if (result.isSuccess) {
      await loadFolders();
      return true;
    } else {
      _errorMessage = result.errorOrNull;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteFolder(String id, {required bool moveToUnfiled}) async {
    final result = await _repository.deleteFolder(id, moveToUnfiled: moveToUnfiled);
    if (result.isSuccess) {
      await loadFolders();
      return true;
    } else {
      _errorMessage = result.errorOrNull;
      notifyListeners();
      return false;
    }
  }
}
