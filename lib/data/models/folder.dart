import 'package:notevault/domain/entities/folder_entity.dart';

/// Database model for Folders / Notebooks.
class FolderModel {
  final String id;
  final String name;
  final int color;
  final String? icon;
  final int createdAt;
  final int updatedAt;

  const FolderModel({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FolderModel.fromMap(Map<String, dynamic> map) {
    return FolderModel(
      id: map['id'] as String,
      name: map['name'] as String,
      color: map['color'] as int,
      icon: map['icon'] as String?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory FolderModel.fromEntity(FolderEntity entity) {
    return FolderModel(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      icon: entity.icon,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
      updatedAt: entity.updatedAt.millisecondsSinceEpoch,
    );
  }

  FolderEntity toEntity({int noteCount = 0}) {
    return FolderEntity(
      id: id,
      name: name,
      color: color,
      icon: icon,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      noteCount: noteCount,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory FolderModel.fromJson(Map<String, dynamic> json) =>
      FolderModel.fromMap(json);
}
