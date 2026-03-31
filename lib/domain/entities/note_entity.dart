import 'tag_entity.dart';
import 'package:notevault/core/extensions/string_extensions.dart';

/// Domain entity representing a rich Note item.
class NoteEntity {
  final String id;
  final String? folderId;
  final String? folderName;
  final String title;
  final String body;
  final int color;
  final bool isPinned;
  final bool isFavorite;
  final bool isArchived;
  final bool isDeleted;
  final DateTime? reminderAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<TagEntity> tags;

  const NoteEntity({
    required this.id,
    this.folderId,
    this.folderName,
    required this.title,
    required this.body,
    required this.color,
    this.isPinned = false,
    this.isFavorite = false,
    this.isArchived = false,
    this.isDeleted = false,
    this.reminderAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.tags = const [],
  });

  // Productivity metrics
  int get wordCount => '$title $body'.wordCount;
  int get charCount => '$title $body'.charCount;
  int get estimatedReadingMinutes => '$title $body'.estimatedReadingTimeMinutes;
  String get readingTimeFormatted => '$title $body'.readingTimeFormatted;

  bool get hasReminder => reminderAt != null && !isDeleted && !isArchived;
  bool get isOverdueReminder =>
      hasReminder && reminderAt!.isBefore(DateTime.now());

  NoteEntity copyWith({
    String? id,
    String? folderId,
    String? folderName,
    String? title,
    String? body,
    int? color,
    bool? isPinned,
    bool? isFavorite,
    bool? isArchived,
    bool? isDeleted,
    DateTime? reminderAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    List<TagEntity>? tags,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      folderName: folderName ?? this.folderName,
      title: title ?? this.title,
      body: body ?? this.body,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      reminderAt: reminderAt ?? this.reminderAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      tags: tags ?? this.tags,
    );
  }
}
