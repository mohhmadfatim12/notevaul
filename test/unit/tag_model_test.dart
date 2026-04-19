import 'package:flutter_test/flutter_test.dart';
import 'package:notevault/data/models/tag.dart';

void main() {
  group('Tag Model Serialization Tests', () {
    final now = DateTime(2026, 10, 27, 9, 30, 0);

    test('should map tag to database map and back correctly', () {
      final tag = TagModel(
        id: 't-1',
        name: 'Urgent',
        color: 0xFFE53935,
        createdAt: now.millisecondsSinceEpoch,
      );

      final map = tag.toMap();
      expect(map['id'], 't-1');
      expect(map['name'], 'Urgent');
      expect(map['color'], 0xFFE53935);
      expect(map['created_at'], now.millisecondsSinceEpoch);

      final fromMap = TagModel.fromMap(map);
      expect(fromMap.id, tag.id);
      expect(fromMap.name, tag.name);
      expect(fromMap.color, tag.color);
      expect(fromMap.createdAt, tag.createdAt);
    });

    test('should convert TagModel to TagEntity accurately', () {
      final tag = TagModel(
        id: 't-2',
        name: 'Finance',
        color: 0xFF1E88E5,
        createdAt: now.millisecondsSinceEpoch,
      );

      final entity = tag.toEntity();
      expect(entity.id, 't-2');
      expect(entity.name, 'Finance');
      expect(entity.color, 0xFF1E88E5);
    });
  });
}
