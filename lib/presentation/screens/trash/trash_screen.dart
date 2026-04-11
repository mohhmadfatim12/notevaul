import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notevault/core/constants/app_dimensions.dart';
import 'package:notevault/core/extensions/date_extensions.dart';
import 'package:notevault/domain/entities/note_entity.dart';
import 'package:notevault/presentation/providers/notes_provider.dart';
import 'package:notevault/presentation/widgets/confirmation_dialog.dart';
import 'package:notevault/presentation/widgets/empty_state.dart';
import 'package:notevault/presentation/widgets/loading_indicator.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotesProvider>(context, listen: false).loadTrashNotes();
    });
  }

  Future<void> _restoreNote(String id) async {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    await notesProvider.restoreNote(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note restored to active vault.')),
      );
    }
  }

  Future<void> _permanentlyDeleteNote(NoteEntity note) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Permanently Delete Note?',
      message: 'This cannot be undone. All data for this note will be erased forever.',
      confirmLabel: 'Delete Forever',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final notesProvider = Provider.of<NotesProvider>(context, listen: false);
      await notesProvider.permanentlyDeleteNote(note.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note permanently deleted.')),
        );
      }
    }
  }

  Future<void> _emptyTrash() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Empty Entire Trash?',
      message: 'All trashed notes will be permanently erased. This cannot be undone.',
      confirmLabel: 'Empty Trash',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final notesProvider = Provider.of<NotesProvider>(context, listen: false);
      await notesProvider.emptyTrash();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trash emptied successfully.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notesProvider = Provider.of<NotesProvider>(context);
    final trashNotes = notesProvider.trashNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          if (trashNotes.isNotEmpty)
            TextButton.icon(
              onPressed: _emptyTrash,
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
              label: const Text('Empty', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Informational Banner about 30-day auto cleanup
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: theme.colorScheme.error.withValues(alpha: 0.08),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: theme.colorScheme.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Notes in Trash are automatically deleted forever after 30 days.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: notesProvider.isLoading
                ? const LoadingIndicator(message: 'Loading trash...')
                : trashNotes.isEmpty
                    ? const EmptyState(
                        icon: Icons.delete_outline_rounded,
                        title: 'Trash is Empty',
                        subtitle:
                            'Deleted notes are kept here for 30 days before being permanently removed.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        itemCount: trashNotes.length,
                        itemBuilder: (ctx, index) {
                          final note = trashNotes[index];
                          final daysLeft = note.deletedAt != null
                              ? note.deletedAt!.daysRemainingInTrash()
                              : 30;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.p16,
                              vertical: AppDimensions.p6,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppDimensions.p16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          note.title.isNotEmpty
                                              ? note.title
                                              : 'Untitled Note',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '$daysLeft ${daysLeft == 1 ? 'day' : 'days'} left',
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (note.body.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      note.body,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _restoreNote(note.id),
                                        icon: const Icon(Icons.restore_rounded, size: 18),
                                        label: const Text('Restore'),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () => _permanentlyDeleteNote(note),
                                        icon: const Icon(Icons.delete_forever_rounded,
                                            size: 18, color: Colors.red),
                                        label: const Text('Delete Forever',
                                            style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
