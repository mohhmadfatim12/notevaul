import 'package:flutter_test/flutter_test.dart';
import 'package:notevault/data/models/note.dart';
import 'package:notevault/domain/entities/note_entity.dart';

void main() {
  group('Note Model & Entity Serialization Tests', () {
    final now = DateTime(2026, 10, 27, 12, 0, 0);

    test('should convert NoteModel to Map and from Map accurately', () {
      final note = NoteModel(
        id: 'test-note-1',
        folderId: 'folder-123',
        title: 'Meeting Notes',
        body: 'Discuss offline architecture and SQLite schema.',
        color: 0xFF2196F3,
        isPinned: 1,
        isFavorite: 0,
        isArchived: 0,
        isDeleted: 0,
        reminderAt: now.add(const Duration(days: 1)).millisecondsSinceEpoch,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
        deletedAt: null,
      );

      final map = note.toMap();
      expect(map['id'], 'test-note-1');
      expect(map['folder_id'], 'folder-123');
      expect(map['title'], 'Meeting Notes');
      expect(map['body'], 'Discuss offline architecture and SQLite schema.');
      expect(map['color'], 0xFF2196F3);
      expect(map['is_pinned'], 1);
      expect(map['is_favorite'], 0);
      expect(map['is_archived'], 0);
      expect(map['is_deleted'], 0);
      expect(map['reminder_at'], now.add(const Duration(days: 1)).millisecondsSinceEpoch);
      expect(map['created_at'], now.millisecondsSinceEpoch);
      expect(map['updated_at'], now.millisecondsSinceEpoch);
      expect(map['deleted_at'], isNull);

      final fromMap = NoteModel.fromMap(map);
      expect(fromMap.id, note.id);
      expect(fromMap.folderId, note.folderId);
      expect(fromMap.title, note.title);
      expect(fromMap.body, note.body);
      expect(fromMap.color, note.color);
      expect(fromMap.isPinned, 1);
      expect(fromMap.isFavorite, 0);
      expect(fromMap.isArchived, 0);
      expect(fromMap.isDeleted, 0);
      expect(fromMap.reminderAt, note.reminderAt);
      expect(fromMap.createdAt, note.createdAt);
      expect(fromMap.updatedAt, note.updatedAt);
      expect(fromMap.deletedAt, isNull);
    });

    test('should convert NoteModel to NoteEntity and handle copyWith correctly', () {
      final note = NoteModel(
        id: 'n-1',
        title: 'Initial Title',
        body: 'Initial Content',
        color: 0xFFFFFFFF,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
      );

      final entity = note.toEntity(folderName: 'Personal', tags: []);
      expect(entity.id, 'n-1');
      expect(entity.title, 'Initial Title');
      expect(entity.folderName, 'Personal');
      expect(entity.tags, isEmpty);

      final updatedEntity = entity.copyWith(
        title: 'Updated Title',
        isPinned: true,
        isFavorite: true,
      );

      expect(updatedEntity.title, 'Updated Title');
      expect(updatedEntity.body, 'Initial Content');
      expect(updatedEntity.isPinned, isTrue);
      expect(updatedEntity.isFavorite, isTrue);
      expect(updatedEntity.folderName, 'Personal');
    });

    test('should calculate word count, character count, and reading time accurately', () {
      final entity = NoteEntity(
        id: 'read-test',
        title: 'Speed Reading Test',
        body: 'Flutter is an open source framework by Google for building beautiful, '
            'natively compiled, multi-platform applications from a single codebase. '
            'NoteVault provides 100% offline-first productivity with SQLite storage.',
        color: 0xFFFFFFFF,
        createdAt: now,
        updatedAt: now,
      );

      expect(entity.wordCount, 30);
      expect(entity.charCount, greaterThan(150));
      expect(entity.readingTimeFormatted, '< 1 min read');
    });
  });
}
