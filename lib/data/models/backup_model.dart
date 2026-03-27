import 'note.dart';
import 'folder.dart';
import 'tag.dart';
import 'note_tag.dart';

/// Complete export/import data backup structure for offline transfer.
class BackupModel {
  final int version;
  final String appName;
  final int exportedAt;
  final List<FolderModel> folders;
  final List<TagModel> tags;
  final List<NoteModel> notes;
  final List<NoteTagModel> noteTags;

  const BackupModel({
    this.version = 1,
    this.appName = 'NoteVault',
    required this.exportedAt,
    required this.folders,
    required this.tags,
    required this.notes,
    required this.noteTags,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'app_name': appName,
      'exported_at': exportedAt,
      'folders': folders.map((f) => f.toJson()).toList(),
      'tags': tags.map((t) => t.toJson()).toList(),
      'notes': notes.map((n) => n.toJson()).toList(),
      'note_tags': noteTags.map((nt) => nt.toJson()).toList(),
    };
  }

  factory BackupModel.fromJson(Map<String, dynamic> json) {
    return BackupModel(
      version: json['version'] as int? ?? 1,
      appName: json['app_name'] as String? ?? 'NoteVault',
      exportedAt: json['exported_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      folders: (json['folders'] as List<dynamic>? ?? [])
          .map((item) => FolderModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((item) => TagModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      notes: (json['notes'] as List<dynamic>? ?? [])
          .map((item) => NoteModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      noteTags: (json['note_tags'] as List<dynamic>? ?? [])
          .map((item) => NoteTagModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Validates integrity of imported backup data.
  bool isValid() {
    if (appName != 'NoteVault') return false;
    if (version < 1) return false;
    return true;
  }
}
