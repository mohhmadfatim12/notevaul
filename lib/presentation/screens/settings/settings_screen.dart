import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notevault/core/constants/app_colors.dart';
import 'package:notevault/core/theme/app_theme.dart';
import 'package:notevault/data/datasources/local/note_local_datasource.dart';
import 'package:notevault/services/database_service.dart';
import 'package:notevault/services/preference_service.dart';
import 'package:notevault/presentation/providers/folders_provider.dart';
import 'package:notevault/presentation/providers/notes_provider.dart';
import 'package:notevault/presentation/providers/search_provider.dart';
import 'package:notevault/presentation/providers/security_provider.dart';
import 'package:notevault/presentation/providers/settings_provider.dart';
import 'package:notevault/presentation/providers/tags_provider.dart';
import 'package:notevault/presentation/screens/about/about_screen.dart';
import 'package:notevault/presentation/screens/backup/backup_screen.dart';
import 'package:notevault/presentation/screens/security/pin_setup_screen.dart';
import 'package:notevault/presentation/widgets/color_picker_row.dart';
import 'package:notevault/presentation/widgets/confirmation_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showThemeDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                settings.themeMode == ThemeMode.system
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('System Default'),
              onTap: () {
                settings.setThemeMode(ThemeMode.system);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: Icon(
                settings.themeMode == ThemeMode.light
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Light'),
              onTap: () {
                settings.setThemeMode(ThemeMode.light);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: Icon(
                settings.themeMode == ThemeMode.dark
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Dark'),
              onTap: () {
                settings.setThemeMode(ThemeMode.dark);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Default Note Sort Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                settings.defaultSort == NoteSortOption.newestUpdated
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Newest Updated'),
              onTap: () {
                settings.setDefaultSort(NoteSortOption.newestUpdated);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: Icon(
                settings.defaultSort == NoteSortOption.oldestUpdated
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Oldest Updated'),
              onTap: () {
                settings.setDefaultSort(NoteSortOption.oldestUpdated);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: Icon(
                settings.defaultSort == NoteSortOption.newestCreated
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Newest Created'),
              onTap: () {
                settings.setDefaultSort(NoteSortOption.newestCreated);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: Icon(
                settings.defaultSort == NoteSortOption.titleAsc
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Title A → Z'),
              onTap: () {
                settings.setDefaultSort(NoteSortOption.titleAsc);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, SettingsProvider settings) {
    double currentSize = settings.editorFontSize;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Editor Font Size'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${currentSize.toInt()} pt',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Slider(
                  value: currentSize,
                  min: 12.0,
                  max: 28.0,
                  divisions: 8,
                  label: '${currentSize.toInt()} pt',
                  onChanged: (val) {
                    setDialogState(() => currentSize = val);
                    settings.setEditorFontSize(val);
                  },
                ),
                Text(
                  'Quick brown fox jumps over the lazy dog.',
                  style: TextStyle(fontSize: currentSize),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Done'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _resetAllData(BuildContext context) async {
    final firstConfirm = await ConfirmationDialog.show(
      context,
      title: 'Reset All App Data?',
      message:
          'This will permanently erase all notes, notebooks, tags, and settings. This action is irreversible.',
      confirmLabel: 'Proceed to Reset',
      isDestructive: true,
    );

    if (firstConfirm != true || !context.mounted) return;

    final secondConfirm = await ConfirmationDialog.show(
      context,
      title: 'FINAL CONFIRMATION',
      message:
          'Are you 100% sure? All your offline records and backups in the app database will be wiped clean.',
      confirmLabel: 'Wipe Everything',
      isDestructive: true,
    );

    if (secondConfirm != true || !context.mounted) return;

    final dbService = Provider.of<DatabaseService>(context, listen: false);
    final prefService = Provider.of<PreferenceService>(context, listen: false);

    await dbService.clearAllData();
    await prefService.clearAll();

    if (context.mounted) {
      await Future.wait([
        Provider.of<NotesProvider>(context, listen: false).loadAll(),
        Provider.of<FoldersProvider>(context, listen: false).loadFolders(),
        Provider.of<TagsProvider>(context, listen: false).loadTags(),
      ]);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data successfully reset.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final security = Provider.of<SecurityProvider>(context);
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme & Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          ListTile(
            leading: const Icon(Icons.brightness_medium_rounded),
            title: const Text('Theme Mode'),
            subtitle: Text(
              settings.themeMode == ThemeMode.system
                  ? 'System Default'
                  : (settings.themeMode == ThemeMode.dark ? 'Dark' : 'Light'),
            ),
            onTap: () => _showThemeDialog(context, settings),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Accent Color'),
            subtitle: const Text('Personalize app highlights'),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: settings.accentColor,
                shape: BoxShape.circle,
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Choose Accent Color'),
                  content: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: AppTheme.accentColorOptions.map((c) {
                      final isSelected = c.toARGB32() == settings.accentColor.toARGB32();
                      return GestureDetector(
                        onTap: () {
                          settings.setAccentColor(c);
                          Navigator.of(ctx).pop();
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.format_size_rounded),
            title: const Text('Editor Font Size'),
            subtitle: Text('${settings.editorFontSize.toInt()} pt'),
            onTap: () => _showFontSizeDialog(context, settings),
          ),

          const Divider(),

          // Note Defaults Section
          _buildSectionHeader(context, 'Note Preferences'),
          ListTile(
            leading: const Icon(Icons.sort_rounded),
            title: const Text('Default Sort Order'),
            subtitle: Text(_getSortName(settings.defaultSort)),
            onTap: () => _showSortDialog(context, settings),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('Default Note Color'),
            subtitle: Text(
                AppColors.getNoteColorById(settings.defaultNoteColor).name),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.getNoteColorById(settings.defaultNoteColor)
                    .lightColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Default Color',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ColorPickerRow(
                        selectedColorId: settings.defaultNoteColor,
                        onColorSelected: (id) {
                          settings.setDefaultNoteColor(id);
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.sync_rounded),
            title: const Text('Auto-Save While Editing'),
            subtitle: const Text('Debounced automatic saving as you type'),
            value: settings.isAutoSaveEnabled,
            onChanged: settings.setAutoSaveEnabled,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.warning_amber_rounded),
            title: const Text('Confirm Before Deletion'),
            subtitle: const Text('Prompt before moving notes to Trash'),
            value: settings.isConfirmDeleteEnabled,
            onChanged: settings.setConfirmDeleteEnabled,
          ),

          const Divider(),

          // Security Section
          _buildSectionHeader(context, 'Security & Privacy'),
          SwitchListTile(
            secondary: const Icon(Icons.lock_outline_rounded),
            title: const Text('App PIN Lock'),
            subtitle: const Text('Require PIN to open NoteVault'),
            value: settings.isPinLockEnabled,
            onChanged: (enabled) async {
              if (enabled) {
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const PinSetupScreen()),
                );
                if (result == true) {
                  settings.setPinLockEnabled(true);
                }
              } else {
                await security.removePin();
                settings.setPinLockEnabled(false);
              }
            },
          ),
          if (settings.isPinLockEnabled) ...[
            ListTile(
              leading: const Icon(Icons.pin_rounded),
              title: const Text('Change PIN'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PinSetupScreen(isChangingPin: true),
                  ),
                );
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint_rounded),
              title: const Text('Biometric Unlock'),
              subtitle: const Text('Use fingerprint or face recognition'),
              value: settings.isBiometricEnabled,
              onChanged: settings.setBiometricEnabled,
            ),
          ],

          const Divider(),

          // Data Management Section
          _buildSectionHeader(context, 'Data Management'),
          ListTile(
            leading: const Icon(Icons.backup_rounded),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Export or import complete offline JSON archives'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BackupScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.manage_search_rounded),
            title: const Text('Clear Search History'),
            onTap: () async {
              await searchProvider.clearRecentSearches();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search history cleared.')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep_rounded),
            title: const Text('Empty Trash'),
            onTap: () async {
              final confirmed = await ConfirmationDialog.show(
                context,
                title: 'Empty Trash?',
                message: 'All trashed notes will be permanently erased.',
                confirmLabel: 'Empty Trash',
                isDestructive: true,
              );
              if (confirmed == true) {
                await notesProvider.emptyTrash();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Trash emptied.')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
            title: const Text('Reset All App Data', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Erase all notes, settings, and local database'),
            onTap: () => _resetAllData(context),
          ),

          const Divider(),

          // About Section
          _buildSectionHeader(context, 'Information'),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About NoteVault'),
            subtitle: const Text('Version 1.0.0 • Offline Smart Notes'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  String _getSortName(NoteSortOption option) {
    switch (option) {
      case NoteSortOption.newestUpdated:
        return 'Newest Updated';
      case NoteSortOption.oldestUpdated:
        return 'Oldest Updated';
      case NoteSortOption.newestCreated:
        return 'Newest Created';
      case NoteSortOption.oldestCreated:
        return 'Oldest Created';
      case NoteSortOption.titleAsc:
        return 'Title A → Z';
      case NoteSortOption.titleDesc:
        return 'Title Z → A';
    }
  }
}
