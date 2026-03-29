import 'package:notevault/domain/entities/tag_entity.dart';

/// Database model for note Tags.
class TagModel {
  final String id;
  final String name;
  final int color;
  final int createdAt;

  const TagModel({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  factory TagModel.fromMap(Map<String, dynamic> map) {
    return TagModel(
      id: map['id'] as String,
      name: map['name'] as String,
      color: map['color'] as int,
      createdAt: map['created_at'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'created_at': createdAt,
    };
  }

  factory TagModel.fromEntity(TagEntity entity) {
    return TagModel(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
    );
  }

  TagEntity toEntity({int noteCount = 0}) {
    return TagEntity(
      id: id,
      name: name,
      color: color,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      noteCount: noteCount,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory TagModel.fromJson(Map<String, dynamic> json) =>
      TagModel.fromMap(json);
}
