/// Domain entity representing a note organization Folder/Notebook.
class FolderEntity {
  final String id;
  final String name;
  final int color;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int noteCount;

  const FolderEntity({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
    this.noteCount = 0,
  });

  FolderEntity copyWith({
    String? id,
    String? name,
    int? color,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? noteCount,
  }) {
    return FolderEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      noteCount: noteCount ?? this.noteCount,
    );
  }
}
