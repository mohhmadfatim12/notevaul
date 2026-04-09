import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notevault/domain/entities/note_entity.dart';
import 'package:notevault/presentation/providers/notes_provider.dart';
import 'package:notevault/presentation/screens/notes/note_details_screen.dart';
import 'package:notevault/presentation/widgets/empty_state.dart';
import 'package:notevault/presentation/widgets/loading_indicator.dart';
import 'package:notevault/presentation/widgets/note_card.dart';

class PinnedNotesScreen extends StatefulWidget {
  const PinnedNotesScreen({super.key});

  @override
  State<PinnedNotesScreen> createState() => _PinnedNotesScreenState();
}

class _PinnedNotesScreenState extends State<PinnedNotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotesProvider>(context, listen: false).loadPinnedNotes();
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
    final pinned = notesProvider.pinnedNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pinned Notes'),
      ),
      body: notesProvider.isLoading
          ? const LoadingIndicator(message: 'Loading pinned notes...')
          : pinned.isEmpty
              ? const EmptyState(
                  icon: Icons.push_pin_outlined,
                  title: 'No Pinned Notes',
                  subtitle: 'Pin important notes to keep them on top of your lists.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: pinned.length,
                  itemBuilder: (ctx, index) {
                    final note = pinned[index];
                    return NoteCard(
                      note: note,
                      onTap: () => _openDetails(note),
                      onPinToggle: () => notesProvider.togglePin(note),
                    );
                  },
                ),
    );
  }
}
