import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notevault/domain/entities/folder_entity.dart';
import 'package:notevault/presentation/providers/folders_provider.dart';
import 'package:notevault/presentation/providers/notes_provider.dart';
import 'package:notevault/presentation/widgets/empty_state.dart';
import 'package:notevault/presentation/widgets/folder_card.dart';
import 'package:notevault/presentation/widgets/loading_indicator.dart';
import 'create_edit_folder_dialog.dart';
import 'folder_details_screen.dart';

class FolderListScreen extends StatelessWidget {
  const FolderListScreen({super.key});

  Future<void> _createFolder(BuildContext context) async {
    final folder = await CreateEditFolderDialog.show(context);
    if (folder != null && context.mounted) {
      final foldersProvider = Provider.of<FoldersProvider>(context, listen: false);
      await foldersProvider.createFolder(folder);
      if (context.mounted) {
        Provider.of<NotesProvider>(context, listen: false).loadDashboardStats();
      }
    }
  }

  Future<void> _editFolder(BuildContext context, FolderEntity folder) async {
    final updated = await CreateEditFolderDialog.show(context, folder: folder);
    if (updated != null && context.mounted) {
      final foldersProvider = Provider.of<FoldersProvider>(context, listen: false);
      await foldersProvider.updateFolder(updated);
      if (context.mounted) {
        Provider.of<NotesProvider>(context, listen: false).loadAll();
      }
    }
  }

  Future<void> _confirmDeleteFolder(BuildContext context, FolderEntity folder) async {
    final decision = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${folder.name}"?'),
        content: const Text(
          'What would you like to do with the notes inside this folder?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('unfiled'),
            child: const Text('Move to Unfiled'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop('delete_notes'),
            child: const Text('Delete Notes'),
          ),
        ],
      ),
    );

    if (decision == null || decision == 'cancel' || !context.mounted) return;

    final moveToUnfiled = decision == 'unfiled';
    final foldersProvider = Provider.of<FoldersProvider>(context, listen: false);
    await foldersProvider.deleteFolder(folder.id, moveToUnfiled: moveToUnfiled);

    if (context.mounted) {
      Provider.of<NotesProvider>(context, listen: false).loadAll();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Folder "${folder.name}" deleted.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final foldersProvider = Provider.of<FoldersProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
      ),
      body: foldersProvider.isLoading
          ? const LoadingIndicator(message: 'Loading folders...')
          : foldersProvider.folders.isEmpty
              ? EmptyState(
                  icon: Icons.folder_outlined,
                  title: 'No Folders Created',
                  subtitle:
                      'Group your notes into organized notebooks for projects, work, or personal ideas.',
                  actionLabel: 'New Folder',
                  onAction: () => _createFolder(context),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 88),
                  itemCount: foldersProvider.folders.length,
                  itemBuilder: (ctx, index) {
                    final folder = foldersProvider.folders[index];
                    return FolderCard(
                      folder: folder,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FolderDetailsScreen(folder: folder),
                          ),
                        );
                      },
                      onEdit: () => _editFolder(context, folder),
                      onDelete: () => _confirmDeleteFolder(context, folder),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createFolder(context),
        icon: const Icon(Icons.create_new_folder_rounded),
        label: const Text('New Folder'),
      ),
    );
  }
}
