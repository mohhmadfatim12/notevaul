import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notevault/core/constants/app_colors.dart';
import 'package:notevault/core/constants/app_dimensions.dart';
import 'package:notevault/core/extensions/date_extensions.dart';
import 'package:notevault/domain/entities/note_entity.dart';
import 'package:notevault/services/export_service.dart';
import 'package:notevault/presentation/providers/notes_provider.dart';
import 'package:notevault/presentation/providers/settings_provider.dart';
import 'package:notevault/presentation/screens/note_editor/note_editor_screen.dart';
import 'package:notevault/presentation/widgets/confirmation_dialog.dart';
import 'package:notevault/presentation/widgets/tag_chip.dart';

class NoteDetailsScreen extends StatelessWidget {
  final NoteEntity note;
  final ExportService _exportService = ExportService();

  NoteDetailsScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorOption = AppColors.getNoteColorById(note.color);
    final cardColor = colorOption.resolve(isDark);
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        actions: [
          // Pin
          Consumer<NotesProvider>(
            builder: (ctx, np, _) {
              final current = np.notes.where((n) => n.id == note.id).firstOrNull ?? note;
              return IconButton(
                icon: Icon(
                  current.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  color: current.isPinned ? AppColors.pinned : null,
                ),
                onPressed: () => np.togglePin(current),
              );
            },
          ),
          // Favorite
          Consumer<NotesProvider>(
            builder: (ctx, np, _) {
              final current = np.notes.where((n) => n.id == note.id).firstOrNull ?? note;
              return IconButton(
                icon: Icon(
                  current.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: current.isFavorite ? AppColors.favorite : null,
                ),
                onPressed: () => np.toggleFavorite(current),
              );
            },
          ),
          // Share
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _exportService.shareAsText(note),
          ),
          // More Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) async {
              if (val == 'export_pdf') {
                await _exportService.exportAndSharePdf(note);
              } else if (val == 'export_txt') {
                await _exportService.saveAsTxtFile(note);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note exported as TXT to app storage.')),
                  );
                }
              } else if (val == 'archive') {
                final np = Provider.of<NotesProvider>(context, listen: false);
                await np.toggleArchive(note);
                if (context.mounted) Navigator.of(context).pop();
              } else if (val == 'trash') {
                if (settings.isConfirmDeleteEnabled) {
                  final confirmed = await ConfirmationDialog.show(
                    context,
                    title: 'Move to Trash?',
                    message: 'This note will be moved to Trash.',
                    confirmLabel: 'Move to Trash',
                    isDestructive: true,
                  );
                  if (confirmed != true) return;
                }
                if (context.mounted) {
                  final np = Provider.of<NotesProvider>(context, listen: false);
                  await np.softDeleteNote(note.id);
                  if (context.mounted) Navigator.of(context).pop();
                }
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'export_pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Export as PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_txt',
                child: Row(
                  children: [
                    Icon(Icons.text_snippet_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Export as TXT'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(note.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(note.isArchived ? 'Unarchive' : 'Archive'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'trash',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Move to Trash', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metadata Badges (Folder, Reminder)
            if (note.folderName != null || note.hasReminder)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (note.folderName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.p12,
                          vertical: AppDimensions.p4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppDimensions.r8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.folder_rounded,
                                size: 14, color: theme.colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              note.folderName!,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (note.hasReminder)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.p12,
                          vertical: AppDimensions.p4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.reminder.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppDimensions.r8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.alarm_rounded,
                                size: 14, color: AppColors.reminder),
                            const SizedBox(width: 6),
                            Text(
                              note.reminderAt!.formatRelative(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.reminder,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

            // Note Title
            if (note.title.isNotEmpty)
              SelectableText(
                note.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),

            if (note.title.isNotEmpty) const SizedBox(height: AppDimensions.p12),

            // Timestamps & Metrics
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  'Updated ${note.updatedAt.formatRelative()}  •  ${note.wordCount} words  •  ${note.readingTimeFormatted}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.p16),
            const Divider(height: 1),
            const SizedBox(height: AppDimensions.p16),

            // Note Body
            SelectableText(
              note.body,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: settings.editorFontSize,
                height: 1.6,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
              ),
            ),

            // Tags
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.p24),
              const Divider(height: 1),
              const SizedBox(height: AppDimensions.p12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: note.tags.map((t) => TagChip(tag: t)).toList(),
              ),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => NoteEditorScreen(initialNote: note),
            ),
          );
        },
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Edit Note'),
      ),
    );
  }
}
