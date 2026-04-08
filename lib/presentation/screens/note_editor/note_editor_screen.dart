import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:notevault/core/constants/app_colors.dart';
import 'package:notevault/core/constants/app_dimensions.dart';
import 'package:notevault/core/extensions/date_extensions.dart';
import 'package:notevault/core/extensions/string_extensions.dart';
import 'package:notevault/core/utils/debouncer.dart';
import 'package:notevault/core/utils/validators.dart';
import 'package:notevault/domain/entities/note_entity.dart';
import 'package:notevault/domain/entities/tag_entity.dart';
import 'package:notevault/services/export_service.dart';
import 'package:notevault/presentation/providers/folders_provider.dart';
import 'package:notevault/presentation/providers/notes_provider.dart';
import 'package:notevault/presentation/providers/settings_provider.dart';
import 'package:notevault/presentation/providers/tags_provider.dart';
import 'package:notevault/presentation/widgets/color_picker_row.dart';
import 'package:notevault/presentation/widgets/confirmation_dialog.dart';
import 'package:notevault/presentation/widgets/tag_chip.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteEntity? initialNote;
  final String? preselectedFolderId;
  final String? preselectedTagId;

  const NoteEditorScreen({
    super.key,
    this.initialNote,
    this.preselectedFolderId,
    this.preselectedTagId,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final Uuid _uuid = const Uuid();
  final ExportService _exportService = ExportService();
  final Debouncer _autoSaveDebouncer =
      Debouncer(delay: const Duration(milliseconds: 700));

  late String _noteId;
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late FocusNode _titleFocusNode;
  late FocusNode _bodyFocusNode;

  String? _folderId;
  int _colorId = 0;
  bool _isPinned = false;
  bool _isFavorite = false;
  bool _isArchived = false;
  DateTime? _reminderAt;
  late DateTime _createdAt;
  late DateTime _updatedAt;
  List<TagEntity> _assignedTags = [];

  bool _isSaving = false;
  bool _hasSaved = false;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    final note = widget.initialNote;

    if (note != null) {
      _noteId = note.id;
      _titleController = TextEditingController(text: note.title);
      _bodyController = TextEditingController(text: note.body);
      _folderId = note.folderId;
      _colorId = note.color;
      _isPinned = note.isPinned;
      _isFavorite = note.isFavorite;
      _isArchived = note.isArchived;
      _reminderAt = note.reminderAt;
      _createdAt = note.createdAt;
      _updatedAt = note.updatedAt;
      _assignedTags = List.from(note.tags);
    } else {
      _noteId = _uuid.v4();
      _titleController = TextEditingController();
      _bodyController = TextEditingController();
      _folderId = widget.preselectedFolderId;
      _colorId = 0;
      _createdAt = DateTime.now();
      _updatedAt = DateTime.now();

      // Read default color from Settings
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        setState(() {
          _colorId = settings.defaultNoteColor;
        });
        if (widget.preselectedTagId != null) {
          final tagsProvider = Provider.of<TagsProvider>(context, listen: false);
          final preTag = tagsProvider.tags
              .where((t) => t.id == widget.preselectedTagId)
              .firstOrNull;
          if (preTag != null) {
            setState(() {
              _assignedTags.add(preTag);
            });
          }
        }
      });
    }

    _titleFocusNode = FocusNode();
    _bodyFocusNode = FocusNode();

    _titleController.addListener(_onTextChanged);
    _bodyController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _isDirty = true;
      _hasSaved = false;
    });

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (settings.isAutoSaveEnabled) {
      setState(() => _isSaving = true);
      _autoSaveDebouncer.run(() {
        _autoSave();
      });
    }
  }

  Future<void> _autoSave() async {
    final title = _titleController.text;
    final body = _bodyController.text;

    if (!Validators.isValidNote(title: title, body: body)) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
      return;
    }

    _updatedAt = DateTime.now();
    final noteToSave = NoteEntity(
      id: _noteId,
      folderId: _folderId,
      title: title.trim(),
      body: body.trim(),
      color: _colorId,
      isPinned: _isPinned,
      isFavorite: _isFavorite,
      isArchived: _isArchived,
      reminderAt: _reminderAt,
      createdAt: _createdAt,
      updatedAt: _updatedAt,
      tags: _assignedTags,
    );

    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    final tagIds = _assignedTags.map((t) => t.id).toList();

    if (widget.initialNote == null && !_hasSaved) {
      await notesProvider.createNote(noteToSave, tagIds: tagIds);
    } else {
      await notesProvider.updateNote(noteToSave, tagIds: tagIds);
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
        _hasSaved = true;
        _isDirty = false;
      });
    }
  }

  Future<void> _manualSaveAndClose() async {
    _autoSaveDebouncer.cancel();
    final title = _titleController.text;
    final body = _bodyController.text;

    if (!Validators.isValidNote(title: title, body: body)) {
      Navigator.of(context).pop();
      return;
    }

    if (_isDirty) {
      await _autoSave();
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickReminder() async {
    final now = DateTime.now();
    final initialDate = _reminderAt ?? now.add(const Duration(hours: 1));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now) ? initialDate : now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null || !mounted) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (combined.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a future time.')),
      );
      return;
    }

    setState(() {
      _reminderAt = combined;
    });
    _onTextChanged();
  }

  void _removeReminder() {
    setState(() {
      _reminderAt = null;
    });
    _onTextChanged();
  }

  void _showTagSelector() {
    final tagsProvider = Provider.of<TagsProvider>(context, listen: false);
    final allTags = tagsProvider.tags;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(AppDimensions.p20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Assign Tags',
                        style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (allTags.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: Text('No tags created yet.')),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allTags.map((tag) {
                        final isAssigned =
                            _assignedTags.any((t) => t.id == tag.id);
                        return TagChip(
                          tag: tag,
                          isSelected: isAssigned,
                          onTap: () {
                            setModalState(() {
                              if (isAssigned) {
                                _assignedTags.removeWhere((t) => t.id == tag.id);
                              } else {
                                _assignedTags.add(tag);
                              }
                            });
                            setState(() {});
                            _onTextChanged();
                          },
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFolderSelector() {
    final foldersProvider = Provider.of<FoldersProvider>(context, listen: false);
    final folders = foldersProvider.folders;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppDimensions.p20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Move to Folder',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.folder_off_outlined),
                title: const Text('Unfiled (No Folder)'),
                selected: _folderId == null,
                onTap: () {
                  setState(() => _folderId = null);
                  _onTextChanged();
                  Navigator.of(ctx).pop();
                },
              ),
              ...folders.map((f) => ListTile(
                    leading: Icon(Icons.folder_rounded, color: Color(f.color)),
                    title: Text(f.name),
                    selected: _folderId == f.id,
                    onTap: () {
                      setState(() => _folderId = f.id);
                      _onTextChanged();
                      Navigator.of(ctx).pop();
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteNote() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (settings.isConfirmDeleteEnabled) {
      final confirmed = await ConfirmationDialog.show(
        context,
        title: 'Move to Trash?',
        message: 'This note will be moved to Trash and can be restored anytime.',
        confirmLabel: 'Move to Trash',
        isDestructive: true,
      );
      if (confirmed != true) return;
    }

    if (!mounted) return;
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    await notesProvider.softDeleteNote(_noteId);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _autoSaveDebouncer.cancel();
    _titleController.dispose();
    _bodyController.dispose();
    _titleFocusNode.dispose();
    _bodyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorOption = AppColors.getNoteColorById(_colorId);
    final pageBgColor = colorOption.resolve(isDark);
    final settings = Provider.of<SettingsProvider>(context);

    final contentText = '${_titleController.text} ${_bodyController.text}';
    final wordCount = contentText.wordCount;
    final charCount = contentText.charCount;
    final readingTime = contentText.readingTimeFormatted;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _manualSaveAndClose();
        }
      },
      child: Scaffold(
        backgroundColor: pageBgColor,
        appBar: AppBar(
          backgroundColor: pageBgColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _manualSaveAndClose,
          ),
          title: Row(
            children: [
              if (_isSaving)
                Text(
                  'Saving...',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else if (_hasSaved)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      'Saved',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          actions: [
            // Pin Toggle
            IconButton(
              icon: Icon(
                _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                color: _isPinned ? AppColors.pinned : null,
              ),
              onPressed: () {
                setState(() => _isPinned = !_isPinned);
                _onTextChanged();
              },
            ),
            // Favorite Toggle
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _isFavorite ? AppColors.favorite : null,
              ),
              onPressed: () {
                setState(() => _isFavorite = !_isFavorite);
                _onTextChanged();
              },
            ),
            // Reminder
            IconButton(
              icon: Icon(
                _reminderAt != null ? Icons.alarm_on_rounded : Icons.alarm_rounded,
                color: _reminderAt != null ? AppColors.reminder : null,
              ),
              onPressed: _reminderAt != null
                  ? () => _showReminderActions()
                  : _pickReminder,
            ),
            // More menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (val) {
                if (val == 'folder') _showFolderSelector();
                if (val == 'tags') _showTagSelector();
                if (val == 'export_pdf') _exportPdf();
                if (val == 'export_txt') _exportTxt();
                if (val == 'share') _shareNote();
                if (val == 'delete') _deleteNote();
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'folder',
                  child: Row(
                    children: [
                      Icon(Icons.folder_outlined, size: 20),
                      SizedBox(width: 10),
                      Text('Folder'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'tags',
                  child: Row(
                    children: [
                      Icon(Icons.label_outline_rounded, size: 20),
                      SizedBox(width: 10),
                      Text('Tags'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export_pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf_outlined, size: 20),
                      SizedBox(width: 10),
                      Text('Export as PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export_txt',
                  child: Row(
                    children: [
                      Icon(Icons.text_snippet_outlined, size: 20),
                      SizedBox(width: 10),
                      Text('Export as TXT'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share_outlined, size: 20),
                      SizedBox(width: 10),
                      Text('Share'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Move to Trash', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Color picker row
            ColorPickerRow(
              selectedColorId: _colorId,
              onColorSelected: (id) {
                setState(() => _colorId = id);
                _onTextChanged();
              },
            ),

            // Metadata Chips (Folder, Reminder, Tags)
            if (_folderId != null || _reminderAt != null || _assignedTags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (_folderId != null) ...[
                      Consumer<FoldersProvider>(
                        builder: (ctx, fp, _) {
                          final f = fp.folders.where((x) => x.id == _folderId).firstOrNull;
                          return Chip(
                            avatar: const Icon(Icons.folder_rounded, size: 16),
                            label: Text(f?.name ?? 'Folder'),
                            onDeleted: () {
                              setState(() => _folderId = null);
                              _onTextChanged();
                            },
                          );
                        },
                      ),
                    ],
                    if (_reminderAt != null)
                      Chip(
                        avatar: const Icon(Icons.alarm_rounded, size: 16, color: AppColors.reminder),
                        label: Text(_reminderAt!.formatRelative()),
                        onDeleted: _removeReminder,
                      ),
                    ..._assignedTags.map((tag) => TagChip(
                          tag: tag,
                          onDeleted: () {
                            setState(() {
                              _assignedTags.removeWhere((t) => t.id == tag.id);
                            });
                            _onTextChanged();
                          },
                        )),
                  ],
                ),
              ),

            // Editor Text Fields
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                    const Divider(height: 16, thickness: 0.5),
                    TextField(
                      controller: _bodyController,
                      focusNode: _bodyFocusNode,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: settings.editorFontSize,
                        height: 1.5,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Start writing your thoughts...',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Productivity Bar: Word count, Char count, Reading time
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$wordCount words  •  $charCount characters',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    readingTime,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderActions() {
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
                leading: const Icon(Icons.edit_calendar_rounded),
                title: const Text('Change Reminder Time'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickReminder();
                },
              ),
              ListTile(
                leading: const Icon(Icons.alarm_off_rounded, color: Colors.red),
                title: const Text('Remove Reminder', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _removeReminder();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  NoteEntity _buildCurrentNote() {
    return NoteEntity(
      id: _noteId,
      folderId: _folderId,
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      color: _colorId,
      isPinned: _isPinned,
      isFavorite: _isFavorite,
      isArchived: _isArchived,
      reminderAt: _reminderAt,
      createdAt: _createdAt,
      updatedAt: _updatedAt,
      tags: _assignedTags,
    );
  }

  Future<void> _exportPdf() async {
    final note = _buildCurrentNote();
    await _exportService.exportAndSharePdf(note);
  }

  Future<void> _exportTxt() async {
    final note = _buildCurrentNote();
    await _exportService.saveAsTxtFile(note);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note exported as TXT file to app storage.')),
      );
    }
  }

  Future<void> _shareNote() async {
    final note = _buildCurrentNote();
    await _exportService.shareAsText(note);
  }
}
