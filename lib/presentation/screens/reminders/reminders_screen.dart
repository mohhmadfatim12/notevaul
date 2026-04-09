import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notevault/core/constants/app_colors.dart';
import 'package:notevault/core/constants/app_dimensions.dart';
import 'package:notevault/core/extensions/date_extensions.dart';
import 'package:notevault/domain/entities/note_entity.dart';
import 'package:notevault/presentation/providers/notes_provider.dart';
import 'package:notevault/presentation/screens/notes/note_details_screen.dart';
import 'package:notevault/presentation/widgets/empty_state.dart';
import 'package:notevault/presentation/widgets/loading_indicator.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotesProvider>(context, listen: false).loadReminders();
    });
  }

  void _openDetails(NoteEntity note) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NoteDetailsScreen(note: note)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notesProvider = Provider.of<NotesProvider>(context);
    final allReminders = notesProvider.reminderNotes;

    final now = DateTime.now();
    final upcoming = allReminders
        .where((n) => n.reminderAt != null && n.reminderAt!.isAfter(now))
        .toList();
    final overdue = allReminders
        .where((n) => n.reminderAt != null && n.reminderAt!.isBefore(now))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
      ),
      body: notesProvider.isLoading
          ? const LoadingIndicator(message: 'Loading reminders...')
          : allReminders.isEmpty
              ? const EmptyState(
                  icon: Icons.alarm_outlined,
                  title: 'No Active Reminders',
                  subtitle:
                      'Schedule local notifications while editing notes to stay on top of deadlines.',
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    if (overdue.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                size: 18, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              'Overdue (${overdue.length})',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...overdue.map((n) => _buildReminderTile(context, n, true)),
                      const SizedBox(height: 16),
                    ],
                    if (upcoming.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.alarm_on_rounded,
                                size: 18, color: AppColors.reminder),
                            const SizedBox(width: 8),
                            Text(
                              'Upcoming (${upcoming.length})',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: AppColors.reminder,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...upcoming.map((n) => _buildReminderTile(context, n, false)),
                    ],
                  ],
                ),
    );
  }

  Widget _buildReminderTile(BuildContext context, NoteEntity note, bool isOverdue) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.p16,
        vertical: AppDimensions.p4,
      ),
      child: ListTile(
        onTap: () => _openDetails(note),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (isOverdue ? Colors.red : AppColors.reminder)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppDimensions.r10),
          ),
          child: Icon(
            isOverdue ? Icons.alarm_off_rounded : Icons.alarm_rounded,
            color: isOverdue ? Colors.red : AppColors.reminder,
            size: 22,
          ),
        ),
        title: Text(
          note.title.isNotEmpty ? note.title : 'Untitled Note',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          note.reminderAt!.formatRelative(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: isOverdue ? Colors.red : AppColors.reminder,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    );
  }
}
