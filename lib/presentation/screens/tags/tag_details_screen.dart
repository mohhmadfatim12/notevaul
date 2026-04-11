import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notevault/domain/entities/note_entity.dart';
import 'package:notevault/domain/entities/tag_entity.dart';
import 'package:notevault/presentation/providers/notes_provider.dart';
import 'package:notevault/presentation/screens/note_editor/note_editor_screen.dart';
import 'package:notevault/presentation/screens/notes/note_details_screen.dart';
import 'package:notevault/presentation/widgets/empty_state.dart';
import 'package:notevault/presentation/widgets/note_card.dart';

class TagDetailsScreen extends StatefulWidget {
  final TagEntity tag;

  const TagDetailsScreen({super.key, required this.tag});

  @override
  State<TagDetailsScreen> createState() => _TagDetailsScreenState();
}

class _TagDetailsScreenState extends State<TagDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotesProvider>(context, listen: false)
          .setTagFilter(widget.tag.id);
    });
  }

  void _openNoteDetails(NoteEntity note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteDetailsScreen(note: note),
      ),
    );
  }

  void _createNoteWithTag() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(preselectedTagId: widget.tag.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    final tagColor = Color(widget.tag.color);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: tagColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text('#${widget.tag.name}'),
          ],
        ),
      ),
      body: notesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notesProvider.notes.isEmpty
              ? EmptyState(
                  icon: Icons.label_off_outlined,
                  title: 'No notes with #${widget.tag.name}',
                  subtitle: 'Create a note or assign this tag to existing notes.',
                  actionLabel: 'New Note',
                  onAction: _createNoteWithTag,
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 88),
                  itemCount: notesProvider.notes.length,
                  itemBuilder: (ctx, index) {
                    final note = notesProvider.notes[index];
                    return NoteCard(
                      note: note,
                      onTap: () => _openNoteDetails(note),
                      onPinToggle: () => notesProvider.togglePin(note),
                      onFavoriteToggle: () => notesProvider.toggleFavorite(note),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNoteWithTag,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Note'),
      ),
    );
  }
}
