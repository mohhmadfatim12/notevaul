import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notevault/core/constants/app_dimensions.dart';
import 'package:notevault/data/datasources/local/note_local_datasource.dart';
import 'package:notevault/domain/entities/note_entity.dart';
import 'package:notevault/presentation/providers/folders_provider.dart';
import 'package:notevault/presentation/providers/notes_provider.dart';
import 'package:notevault/presentation/providers/tags_provider.dart';
import 'package:notevault/presentation/screens/note_editor/note_editor_screen.dart';
import 'package:notevault/presentation/screens/notes/note_details_screen.dart';
import 'package:notevault/presentation/screens/search/search_screen.dart';
import 'package:notevault/presentation/widgets/confirmation_dialog.dart';
import 'package:notevault/presentation/widgets/empty_state.dart';
import 'package:notevault/presentation/widgets/loading_indicator.dart';
import 'package:notevault/presentation/widgets/note_card.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  void _openEditor({NoteEntity? note}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(initialNote: note),
      ),
    );
  }

  void _openDetails(NoteEntity note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteDetailsScreen(note: note),
      ),
    );
  }

  void _showSortDialog() {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.p20),
                child: Text(
                  'Sort Notes',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              _buildSortTile(ctx, notesProvider, NoteSortOption.newestUpdated,
                  'Newest Updated', Icons.update_rounded),
              _buildSortTile(ctx, notesProvider, NoteSortOption.oldestUpdated,
                  'Oldest Updated', Icons.history_rounded),
              _buildSortTile(ctx, notesProvider, NoteSortOption.newestCreated,
                  'Newest Created', Icons.date_range_rounded),
              _buildSortTile(ctx, notesProvider, NoteSortOption.oldestCreated,
                  'Oldest Created', Icons.calendar_today_rounded),
              _buildSortTile(ctx, notesProvider, NoteSortOption.titleAsc,
                  'Title A → Z', Icons.sort_by_alpha_rounded),
              _buildSortTile(ctx, notesProvider, NoteSortOption.titleDesc,
                  'Title Z → A', Icons.sort_by_alpha_rounded),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortTile(BuildContext ctx, NotesProvider provider,
      NoteSortOption option, String title, IconData icon) {
    final isSelected = provider.currentSort == option;
    return ListTile(
      leading: Icon(icon,
          color: isSelected ? Theme.of(ctx).colorScheme.primary : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
          color: isSelected ? Theme.of(ctx).colorScheme.primary : null,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: Theme.of(ctx).colorScheme.primary)
          : null,
      onTap: () {
        provider.setSortOption(option);
        Navigator.of(ctx).pop();
      },
    );
  }

  void _showBulkMoveFolderSheet(NotesProvider notesProvider) {
    final folders =
        Provider.of<FoldersProvider>(context, listen: false).folders;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Move to Unfiled'),
                onTap: () {
                  notesProvider.bulkMoveToFolder(null);
                  Navigator.of(ctx).pop();
                },
              ),
              ...folders.map((f) => ListTile(
                    leading: Icon(Icons.folder_rounded, color: Color(f.color)),
                    title: Text(f.name),
                    onTap: () {
                      notesProvider.bulkMoveToFolder(f.id);
                      Navigator.of(ctx).pop();
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _showBulkAddTagSheet(NotesProvider notesProvider) {
    final tags = Provider.of<TagsProvider>(context, listen: false).tags;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.p20),
                child: Text('Add Tag to Selected',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
              ),
              if (tags.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('No tags created yet.'),
                )
              else
                ...tags.map((t) => ListTile(
                      leading: Icon(Icons.label_rounded, color: Color(t.color)),
                      title: Text(t.name),
                      onTap: () {
                        notesProvider.bulkAddTag(t.id);
                        Navigator.of(ctx).pop();
                      },
                    )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);

    return Scaffold(
      appBar: notesProvider.isMultiSelect
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: notesProvider.clearSelection,
              ),
              title: Text('${notesProvider.selectedCount} selected'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.select_all_rounded),
                  tooltip: 'Select All',
                  onPressed: notesProvider.selectAll,
                ),
                IconButton(
                  icon: const Icon(Icons.push_pin_outlined),
                  tooltip: 'Pin',
                  onPressed: () => notesProvider.bulkPin(true),
                ),
                IconButton(
                  icon: const Icon(Icons.archive_outlined),
                  tooltip: 'Archive',
                  onPressed: () => notesProvider.bulkArchive(true),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (val) async {
                    if (val == 'favorite') notesProvider.bulkFavorite(true);
                    if (val == 'move') _showBulkMoveFolderSheet(notesProvider);
                    if (val == 'tag') _showBulkAddTagSheet(notesProvider);
                    if (val == 'delete') {
                      final confirmed = await ConfirmationDialog.show(
                        context,
                        title: 'Delete Selected Notes?',
                        message:
                            'Selected notes will be moved to Trash and can be restored.',
                        confirmLabel: 'Move to Trash',
                        isDestructive: true,
                      );
                      if (confirmed == true) {
                        notesProvider.bulkDelete();
                      }
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                        value: 'favorite', child: Text('Add to Favorites')),
                    const PopupMenuItem(
                        value: 'move', child: Text('Move to Folder')),
                    const PopupMenuItem(
                        value: 'tag', child: Text('Assign Tag')),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Move to Trash',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            )
          : AppBar(
              title: const Text('NoteVault'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  tooltip: 'Search',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SearchScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.sort_rounded),
                  tooltip: 'Sort Notes',
                  onPressed: _showSortDialog,
                ),
              ],
            ),
      body: Column(
        children: [
          // Filter Chips Row (Folders, Tags, Color)
          if (notesProvider.selectedFolderId != null ||
              notesProvider.selectedTagId != null ||
              notesProvider.selectedColorId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text('Active filter: ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Chip(
                    label: const Text('Clear all'),
                    onDeleted: notesProvider.clearFilters,
                  ),
                ],
              ),
            ),

          // Note List
          Expanded(
            child: notesProvider.isLoading
                ? const LoadingIndicator(message: 'Loading notes...')
                : notesProvider.notes.isEmpty
                    ? EmptyState(
                        icon: Icons.note_alt_outlined,
                        title: 'No Notes Found',
                        subtitle:
                            'Capture your thoughts, ideas, and checklists safely offline.',
                        actionLabel: 'New Note',
                        onAction: () => _openEditor(),
                      )
                    : RefreshIndicator(
                        onRefresh: notesProvider.loadAll,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                              top: 8, bottom: 88),
                          itemCount: notesProvider.notes.length,
                          itemBuilder: (ctx, index) {
                            final note = notesProvider.notes[index];
                            final isSelected =
                                notesProvider.selectedIds.contains(note.id);

                            return NoteCard(
                              note: note,
                              isSelected: isSelected,
                              isMultiSelect: notesProvider.isMultiSelect,
                              onTap: () => _openDetails(note),
                              onLongPress: () {
                                if (!notesProvider.isMultiSelect) {
                                  notesProvider.enterMultiSelect(note.id);
                                }
                              },
                              onSelectChanged: (_) {
                                notesProvider.toggleSelection(note.id);
                              },
                              onPinToggle: () => notesProvider.togglePin(note),
                              onFavoriteToggle: () =>
                                  notesProvider.toggleFavorite(note),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: notesProvider.isMultiSelect
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Note'),
            ),
    );
  }
}
