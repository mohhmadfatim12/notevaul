/// Domain entity representing a note label/Tag.
class TagEntity {
  final String id;
  final String name;
  final int color;
  final DateTime createdAt;
  final int noteCount;

  const TagEntity({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    this.noteCount = 0,
  });

  TagEntity copyWith({
    String? id,
    String? name,
    int? color,
    DateTime? createdAt,
    int? noteCount,
  }) {
    return TagEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      noteCount: noteCount ?? this.noteCount,
    );
  }
}
