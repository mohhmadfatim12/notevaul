import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notevault/core/constants/app_dimensions.dart';
import 'package:notevault/domain/entities/tag_entity.dart';
import 'package:notevault/presentation/providers/notes_provider.dart';
import 'package:notevault/presentation/providers/tags_provider.dart';
import 'package:notevault/presentation/widgets/confirmation_dialog.dart';
import 'package:notevault/presentation/widgets/empty_state.dart';
import 'package:notevault/presentation/widgets/loading_indicator.dart';
import 'create_edit_tag_dialog.dart';
import 'tag_details_screen.dart';

class TagListScreen extends StatelessWidget {
  const TagListScreen({super.key});

  Future<void> _createTag(BuildContext context) async {
    final tag = await CreateEditTagDialog.show(context);
    if (tag != null && context.mounted) {
      final tagsProvider = Provider.of<TagsProvider>(context, listen: false);
      final success = await tagsProvider.createTag(tag);
      if (context.mounted) {
        if (!success && tagsProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tagsProvider.errorMessage!)),
          );
        } else {
          Provider.of<NotesProvider>(context, listen: false).loadDashboardStats();
        }
      }
    }
  }

  Future<void> _editTag(BuildContext context, TagEntity tag) async {
    final updated = await CreateEditTagDialog.show(context, tag: tag);
    if (updated != null && context.mounted) {
      final tagsProvider = Provider.of<TagsProvider>(context, listen: false);
      final success = await tagsProvider.updateTag(updated);
      if (context.mounted) {
        if (!success && tagsProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tagsProvider.errorMessage!)),
          );
        } else {
          Provider.of<NotesProvider>(context, listen: false).loadAll();
        }
      }
    }
  }

  Future<void> _deleteTag(BuildContext context, TagEntity tag) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Tag #${tag.name}?',
      message:
          'This will remove the tag from all associated notes. The notes themselves will not be deleted.',
      confirmLabel: 'Delete Tag',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final tagsProvider = Provider.of<TagsProvider>(context, listen: false);
      await tagsProvider.deleteTag(tag.id);
      if (context.mounted) {
        Provider.of<NotesProvider>(context, listen: false).loadAll();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tag #${tag.name} deleted.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tagsProvider = Provider.of<TagsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
      ),
      body: tagsProvider.isLoading
          ? const LoadingIndicator(message: 'Loading tags...')
          : tagsProvider.tags.isEmpty
              ? EmptyState(
                  icon: Icons.label_outline_rounded,
                  title: 'No Tags Created',
                  subtitle:
                      'Create custom tags like #ideas, #todo, or #project to easily categorize notes.',
                  actionLabel: 'New Tag',
                  onAction: () => _createTag(context),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 88),
                  itemCount: tagsProvider.tags.length,
                  itemBuilder: (ctx, index) {
                    final tag = tagsProvider.tags[index];
                    final tagColor = Color(tag.color);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.p16,
                        vertical: AppDimensions.p6,
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TagDetailsScreen(tag: tag),
                            ),
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.r16),
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: tagColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppDimensions.r12),
                          ),
                          child: Icon(
                            Icons.tag_rounded,
                            color: tagColor,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          '#${tag.name}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          '${tag.noteCount} ${tag.noteCount == 1 ? 'note' : 'notes'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => _editTag(context, tag),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  size: 20, color: Colors.red),
                              onPressed: () => _deleteTag(context, tag),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createTag(context),
        icon: const Icon(Icons.new_label_rounded),
        label: const Text('New Tag'),
      ),
    );
  }
}
