import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notevault/domain/entities/folder_entity.dart';
import 'package:notevault/domain/entities/note_entity.dart';
import 'package:notevault/presentation/providers/notes_provider.dart';
import 'package:notevault/presentation/screens/note_editor/note_editor_screen.dart';
import 'package:notevault/presentation/screens/notes/note_details_screen.dart';
import 'package:notevault/presentation/widgets/empty_state.dart';
import 'package:notevault/presentation/widgets/note_card.dart';

class FolderDetailsScreen extends StatefulWidget {
  final FolderEntity folder;

  const FolderDetailsScreen({super.key, required this.folder});

  @override
  State<FolderDetailsScreen> createState() => _FolderDetailsScreenState();
}

class _FolderDetailsScreenState extends State<FolderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotesProvider>(context, listen: false)
          .setFolderFilter(widget.folder.id);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openNoteDetails(NoteEntity note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteDetailsScreen(note: note),
      ),
    );
  }

  void _createNoteInFolder() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(preselectedFolderId: widget.folder.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    final folderColor = Color(widget.folder.color);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: folderColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(widget.folder.name),
          ],
        ),
      ),
      body: notesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notesProvider.notes.isEmpty
              ? EmptyState(
                  icon: Icons.folder_open_rounded,
                  title: 'No notes in this folder',
                  subtitle: 'Create notes and file them under ${widget.folder.name}.',
                  actionLabel: 'New Note',
                  onAction: _createNoteInFolder,
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
        onPressed: _createNoteInFolder,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Note'),
      ),
    );
  }
}
