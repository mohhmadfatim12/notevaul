import 'package:notevault/domain/entities/note_entity.dart';
import 'package:notevault/domain/entities/tag_entity.dart';

/// Database model for Notes.
class NoteModel {
  final String id;
  final String? folderId;
  final String title;
  final String body;
  final int color;
  final int isPinned;
  final int isFavorite;
  final int isArchived;
  final int isDeleted;
  final int? reminderAt;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;

  const NoteModel({
    required this.id,
    this.folderId,
    required this.title,
    required this.body,
    required this.color,
    this.isPinned = 0,
    this.isFavorite = 0,
    this.isArchived = 0,
    this.isDeleted = 0,
    this.reminderAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      folderId: map['folder_id'] as String?,
      title: map['title'] as String,
      body: map['body'] as String,
      color: map['color'] as int,
      isPinned: map['is_pinned'] as int? ?? 0,
      isFavorite: map['is_favorite'] as int? ?? 0,
      isArchived: map['is_archived'] as int? ?? 0,
      isDeleted: map['is_deleted'] as int? ?? 0,
      reminderAt: map['reminder_at'] as int?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
      deletedAt: map['deleted_at'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'folder_id': folderId,
      'title': title,
      'body': body,
      'color': color,
      'is_pinned': isPinned,
      'is_favorite': isFavorite,
      'is_archived': isArchived,
      'is_deleted': isDeleted,
      'reminder_at': reminderAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }

  factory NoteModel.fromEntity(NoteEntity entity) {
    return NoteModel(
      id: entity.id,
      folderId: entity.folderId,
      title: entity.title,
      body: entity.body,
      color: entity.color,
      isPinned: entity.isPinned ? 1 : 0,
      isFavorite: entity.isFavorite ? 1 : 0,
      isArchived: entity.isArchived ? 1 : 0,
      isDeleted: entity.isDeleted ? 1 : 0,
      reminderAt: entity.reminderAt?.millisecondsSinceEpoch,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
      updatedAt: entity.updatedAt.millisecondsSinceEpoch,
      deletedAt: entity.deletedAt?.millisecondsSinceEpoch,
    );
  }

  NoteEntity toEntity({
    List<TagEntity> tags = const [],
    String? folderName,
  }) {
    return NoteEntity(
      id: id,
      folderId: folderId,
      folderName: folderName,
      title: title,
      body: body,
      color: color,
      isPinned: isPinned == 1,
      isFavorite: isFavorite == 1,
      isArchived: isArchived == 1,
      isDeleted: isDeleted == 1,
      reminderAt: reminderAt != null
          ? DateTime.fromMillisecondsSinceEpoch(reminderAt!)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      deletedAt: deletedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(deletedAt!)
          : null,
      tags: tags,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory NoteModel.fromJson(Map<String, dynamic> json) =>
      NoteModel.fromMap(json);
}
