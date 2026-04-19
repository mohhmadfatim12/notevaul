import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevault/core/theme/app_theme.dart';
import 'package:notevault/domain/entities/folder_entity.dart';
import 'package:notevault/domain/entities/note_entity.dart';
import 'package:notevault/domain/entities/tag_entity.dart';
import 'package:notevault/presentation/widgets/color_picker_row.dart';
import 'package:notevault/presentation/widgets/empty_state.dart';
import 'package:notevault/presentation/widgets/folder_card.dart';
import 'package:notevault/presentation/widgets/note_card.dart';
import 'package:notevault/presentation/widgets/search_field.dart';
import 'package:notevault/presentation/widgets/tag_chip.dart';

void main() {
  final now = DateTime(2026, 10, 27, 12, 0);

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: child),
    );
  }

  group('NoteVault Core Widget Tests', () {
    testWidgets('EmptyState displays custom icon, title, and action button', (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(createTestWidget(
        EmptyState(
          icon: Icons.note_alt_outlined,
          title: 'No notes yet',
          subtitle: 'Create your first note by tapping the button below.',
          actionLabel: 'Create Note',
          onAction: () => actionTriggered = true,
        ),
      ));

      expect(find.text('No notes yet'), findsOneWidget);
      expect(find.text('Create your first note by tapping the button below.'), findsOneWidget);
      expect(find.text('Create Note'), findsOneWidget);

      await tester.tap(find.text('Create Note'));
      await tester.pump();
      expect(actionTriggered, isTrue);
    });

    testWidgets('NoteCard renders title, body snippet, tags, and pin badge', (tester) async {
      final note = NoteEntity(
        id: 'widget-note-1',
        title: 'Project Roadmap',
        body: 'Sprint 1: Architecture, Sprint 2: UI, Sprint 3: Release.',
        color: 0,
        isPinned: true,
        isFavorite: true,
        folderName: 'Roadmaps',
        tags: [
          TagEntity(id: 't-1', name: 'release', color: 0xFFE91E63, createdAt: now),
        ],
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(createTestWidget(
        NoteCard(
          note: note,
          onTap: () {},
        ),
      ));

      expect(find.text('Project Roadmap'), findsOneWidget);
      expect(find.text('Sprint 1: Architecture, Sprint 2: UI, Sprint 3: Release.'), findsOneWidget);
      expect(find.text('Roadmaps'), findsOneWidget);
      expect(find.text('#release'), findsOneWidget);
      expect(find.byIcon(Icons.push_pin_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });

    testWidgets('FolderCard displays folder name, count, and custom color icon', (tester) async {
      final folder = FolderEntity(
        id: 'f-test',
        name: 'Design System',
        color: 0xFF9C27B0,
        icon: 'folder',
        noteCount: 8,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(createTestWidget(
        FolderCard(
          folder: folder,
          onTap: () {},
        ),
      ));

      expect(find.text('Design System'), findsOneWidget);
      expect(find.text('8 notes'), findsOneWidget);
      expect(find.byIcon(Icons.folder_rounded), findsOneWidget);
    });

    testWidgets('TagChip renders tag label with delete button when onDeleted provided', (tester) async {
      bool deleted = false;
      final tag = TagEntity(
        id: 't-chip',
        name: 'flutter',
        color: 0xFF00BCD4,
        createdAt: now,
      );

      await tester.pumpWidget(createTestWidget(
        TagChip(
          tag: tag,
          onDeleted: () => deleted = true,
        ),
      ));

      expect(find.text('#flutter'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(deleted, isTrue);
    });

    testWidgets('SearchField handles text entry and clear button properly', (tester) async {
      final controller = TextEditingController(text: 'initial search');

      await tester.pumpWidget(createTestWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return SearchField(
              controller: controller,
              hintText: 'Search notes...',
              onChanged: (_) => setState(() {}),
              onClear: () => setState(() {}),
            );
          },
        ),
      ));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(controller.text, isEmpty);
    });

    testWidgets('ColorPickerRow allows selecting a note color palette item', (tester) async {
      int selectedColorId = 0;

      await tester.pumpWidget(createTestWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return ColorPickerRow(
              selectedColorId: selectedColorId,
              onColorSelected: (colorId) {
                setState(() => selectedColorId = colorId);
              },
            );
          },
        ),
      ));

      expect(find.byType(GestureDetector), findsWidgets);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });
}
