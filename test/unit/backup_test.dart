import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevault/data/models/backup_model.dart';
import 'package:notevault/data/models/folder.dart';
import 'package:notevault/data/models/note.dart';
import 'package:notevault/data/models/note_tag.dart';
import 'package:notevault/data/models/tag.dart';

void main() {
  group('Backup Model Serialization & Integrity Tests', () {
    final now = DateTime(2026, 10, 27, 12, 0, 0);

    test('encodes and decodes full backup payload without loss', () {
      final note = NoteModel(
        id: 'n-100',
        folderId: 'f-100',
        title: 'Architecture Blueprint',
        body: 'Clean architecture layers: presentation, domain, data.',
        color: 0xFF1976D2,
        isPinned: 1,
        isFavorite: 1,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
      );

      final folder = FolderModel(
        id: 'f-100',
        name: 'Technical Specs',
        color: 0xFF4CAF50,
        icon: 'folder',
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
      );

      final tag = TagModel(
        id: 't-100',
        name: 'flutter',
        color: 0xFF9C27B0,
        createdAt: now.millisecondsSinceEpoch,
      );

      final noteTag = NoteTagModel(noteId: 'n-100', tagId: 't-100');

      final backup = BackupModel(
        exportedAt: now.millisecondsSinceEpoch,
        notes: [note],
        folders: [folder],
        tags: [tag],
        noteTags: [noteTag],
      );

      final jsonMap = backup.toJson();
      final jsonString = jsonEncode(jsonMap);

      expect(jsonMap['version'], 1);
      expect(jsonMap['app_name'], 'NoteVault');
      expect((jsonMap['notes'] as List).length, 1);
      expect((jsonMap['folders'] as List).length, 1);
      expect((jsonMap['tags'] as List).length, 1);
      expect((jsonMap['note_tags'] as List).length, 1);

      final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final restoredBackup = BackupModel.fromJson(decodedMap);

      expect(restoredBackup.notes.length, 1);
      expect(restoredBackup.notes.first.title, 'Architecture Blueprint');
      expect(restoredBackup.folders.length, 1);
      expect(restoredBackup.folders.first.name, 'Technical Specs');
      expect(restoredBackup.tags.length, 1);
      expect(restoredBackup.tags.first.name, 'flutter');
      expect(restoredBackup.noteTags.length, 1);
      expect(restoredBackup.noteTags.first.noteId, 'n-100');
    });
  });
}
