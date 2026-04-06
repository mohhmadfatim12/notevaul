import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notevault/domain/entities/note_entity.dart';
import 'package:notevault/presentation/providers/notes_provider.dart';
import 'package:notevault/presentation/screens/notes/note_details_screen.dart';
import 'package:notevault/presentation/widgets/empty_state.dart';
import 'package:notevault/presentation/widgets/loading_indicator.dart';
import 'package:notevault/presentation/widgets/note_card.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotesProvider>(context, listen: false).loadArchivedNotes();
    });
  }

  void _openDetails(NoteEntity note) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NoteDetailsScreen(note: note)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    final archived = notesProvider.archivedNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Notes'),
      ),
      body: notesProvider.isLoading
          ? const LoadingIndicator(message: 'Loading archive...')
          : archived.isEmpty
              ? const EmptyState(
                  icon: Icons.archive_outlined,
                  title: 'Archive is Empty',
                  subtitle: 'Notes you archive to clear clutter will be preserved here.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: archived.length,
                  itemBuilder: (ctx, index) {
                    final note = archived[index];
                    return NoteCard(
                      note: note,
                      onTap: () => _openDetails(note),
                    );
                  },
                ),
    );
  }
}
