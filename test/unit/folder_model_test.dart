import 'package:flutter_test/flutter_test.dart';
import 'package:notevault/data/models/folder.dart';

void main() {
  group('Folder Model Serialization Tests', () {
    final now = DateTime(2026, 10, 27, 10, 0, 0);

    test('should map folder to database map and back correctly', () {
      final folder = FolderModel(
        id: 'f-1',
        name: 'Work Projects',
        color: 0xFF4CAF50,
        icon: 'work',
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
      );

      final map = folder.toMap();
      expect(map['id'], 'f-1');
      expect(map['name'], 'Work Projects');
      expect(map['color'], 0xFF4CAF50);
      expect(map['icon'], 'work');
      expect(map['created_at'], now.millisecondsSinceEpoch);

      final fromMap = FolderModel.fromMap(map);
      expect(fromMap.id, folder.id);
      expect(fromMap.name, folder.name);
      expect(fromMap.color, folder.color);
      expect(fromMap.icon, folder.icon);
      expect(fromMap.createdAt, folder.createdAt);
    });

    test('should convert FolderModel to FolderEntity with note count', () {
      final folder = FolderModel(
        id: 'f-2',
        name: 'Ideas',
        color: 0xFFFF9800,
        icon: 'lightbulb',
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
      );

      final entity = folder.toEntity(noteCount: 15);
      expect(entity.id, 'f-2');
      expect(entity.name, 'Ideas');
      expect(entity.noteCount, 15);
      expect(entity.color, 0xFFFF9800);
      expect(entity.icon, 'lightbulb');
    });
  });
}
