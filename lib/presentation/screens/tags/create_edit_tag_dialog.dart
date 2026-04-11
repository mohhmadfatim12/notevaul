import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:notevault/core/constants/app_dimensions.dart';
import 'package:notevault/core/utils/validators.dart';
import 'package:notevault/domain/entities/tag_entity.dart';

class CreateEditTagDialog extends StatefulWidget {
  final TagEntity? initialTag;

  const CreateEditTagDialog({super.key, this.initialTag});

  static Future<TagEntity?> show(BuildContext context, {TagEntity? tag}) {
    return showDialog<TagEntity>(
      context: context,
      builder: (ctx) => CreateEditTagDialog(initialTag: tag),
    );
  }

  @override
  State<CreateEditTagDialog> createState() => _CreateEditTagDialogState();
}

class _CreateEditTagDialogState extends State<CreateEditTagDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late int _selectedColor;

  static const List<int> _tagColors = [
    0xFF3F51B5, // Indigo
    0xFF1E88E5, // Blue
    0xFF00897B, // Teal
    0xFF43A047, // Green
    0xFFFFB300, // Amber
    0xFFE53935, // Red
    0xFF8E24AA, // Purple
    0xFF546E7A, // Slate
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialTag?.name ?? '');
    _selectedColor = widget.initialTag?.color ?? _tagColors[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final tag = TagEntity(
      id: widget.initialTag?.id ?? const Uuid().v4(),
      name: _nameController.text.trim().replaceAll('#', ''),
      color: _selectedColor,
      createdAt: widget.initialTag?.createdAt ?? now,
      noteCount: widget.initialTag?.noteCount ?? 0,
    );

    Navigator.of(context).pop(tag);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initialTag != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Tag' : 'New Tag'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Tag Name',
                hintText: 'e.g. urgent, project, research',
                prefixText: '#',
              ),
              validator: Validators.validateTagName,
            ),
            const SizedBox(height: AppDimensions.p20),
            Text(
              'Tag Color',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.p8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tagColors.map((colorVal) {
                final isSelected = colorVal == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = colorVal),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(colorVal),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Color(colorVal).withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _onSave,
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
