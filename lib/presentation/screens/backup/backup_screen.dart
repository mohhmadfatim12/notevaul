import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notevault/core/constants/app_colors.dart';
import 'package:notevault/core/constants/app_dimensions.dart';
import 'package:notevault/services/backup_service.dart';
import 'package:notevault/presentation/providers/folders_provider.dart';
import 'package:notevault/presentation/providers/notes_provider.dart';
import 'package:notevault/presentation/providers/tags_provider.dart';
import 'package:notevault/presentation/widgets/confirmation_dialog.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isProcessing = false;
  String? _statusMessage;

  Future<void> _exportBackup() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Compiling and packaging backup...';
    });

    final backupService = Provider.of<BackupService>(context, listen: false);
    final result = await backupService.exportBackupToFile();

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _statusMessage = null;
    });

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup exported successfully.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(result.errorOrNull ?? 'Backup failed.'),
        ),
      );
    }
  }

  Future<void> _restoreBackup() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Restore Backup File?',
      message:
          'Restoring will replace existing notes, notebooks, and tags with the contents of the backup file. Do you want to proceed?',
      confirmLabel: 'Restore Data',
      isDestructive: true,
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Verifying and restoring database...';
    });

    final backupService = Provider.of<BackupService>(context, listen: false);
    final result = await backupService.pickAndRestoreBackup();

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _statusMessage = null;
    });

    if (result.isSuccess) {
      // Reload all providers with fresh data
      await Future.wait([
        Provider.of<NotesProvider>(context, listen: false).loadAll(),
        Provider.of<FoldersProvider>(context, listen: false).loadFolders(),
        Provider.of<TagsProvider>(context, listen: false).loadTags(),
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data successfully restored!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(result.errorOrNull ?? 'Restore failed.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_statusMessage ?? 'Processing...'),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppDimensions.p16),
              children: [
                // Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.p16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.security_rounded,
                            size: 28, color: AppColors.secondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Local Data Portability',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your data stays under your control. Create single-file JSON backups to transfer between devices or safeguard your vault.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Backup Action
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.file_upload_outlined,
                          color: theme.colorScheme.primary),
                    ),
                    title: const Text('Export Local Backup',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text(
                      'Save all notes, folders, tags, and relations into an offline JSON file.',
                    ),
                    onTap: _exportBackup,
                  ),
                ),

                const SizedBox(height: 12),

                // Restore Action
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.reminder.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.file_download_outlined,
                          color: AppColors.reminder),
                    ),
                    title: const Text('Restore From Backup',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text(
                      'Select a verified NoteVault JSON backup file to restore your vault.',
                    ),
                    onTap: _restoreBackup,
                  ),
                ),
              ],
            ),
    );
  }
}
