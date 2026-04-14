import 'package:flutter/material.dart';
import 'package:notevault/core/constants/app_colors.dart';
import 'package:notevault/core/constants/app_dimensions.dart';
import 'package:notevault/core/extensions/date_extensions.dart';
import 'package:notevault/domain/entities/note_entity.dart';
import 'tag_chip.dart';

class NoteCard extends StatelessWidget {
  final NoteEntity note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isMultiSelect;
  final ValueChanged<bool?>? onSelectChanged;
  final VoidCallback? onPinToggle;
  final VoidCallback? onFavoriteToggle;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isMultiSelect = false,
    this.onSelectChanged,
    this.onPinToggle,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorOption = AppColors.getNoteColorById(note.color);
    final cardColor = colorOption.resolve(isDark);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.p16,
        vertical: AppDimensions.p6,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : (note.color != 0
                  ? colorOption.borderColor
                  : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder)),
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.r16),
          onTap: isMultiSelect ? () => onSelectChanged?.call(!isSelected) : onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: Checkbox/Pin/Favorite/Folder
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isMultiSelect) ...[
                      Checkbox(
                        value: isSelected,
                        onChanged: onSelectChanged,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.r4),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.p4),
                    ],
                    if (note.folderName != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.p8,
                          vertical: AppDimensions.p2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppDimensions.r4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.folder_outlined,
                              size: 13,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: AppDimensions.p4),
                            Text(
                              note.folderName!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ] else ...[
                      const Spacer(),
                    ],
                    if (note.hasReminder) ...[
                      Icon(
                        Icons.alarm_rounded,
                        size: 16,
                        color: note.isOverdueReminder
                            ? theme.colorScheme.error
                            : AppColors.reminder,
                      ),
                      const SizedBox(width: AppDimensions.p4),
                      Text(
                        note.reminderAt!.formatTime(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: note.isOverdueReminder
                              ? theme.colorScheme.error
                              : AppColors.reminder,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.p8),
                    ],
                    if (note.isPinned)
                      GestureDetector(
                        onTap: onPinToggle,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.push_pin_rounded,
                            size: 18,
                            color: AppColors.pinned,
                          ),
                        ),
                      ),
                    if (note.isFavorite)
                      GestureDetector(
                        onTap: onFavoriteToggle,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.favorite_rounded,
                            size: 18,
                            color: AppColors.favorite,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppDimensions.p8),

                // Note Title
                if (note.title.isNotEmpty)
                  Text(
                    note.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),

                if (note.title.isNotEmpty && note.body.isNotEmpty)
                  const SizedBox(height: AppDimensions.p6),

                // Note Body Preview
                if (note.body.isNotEmpty)
                  Text(
                    note.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                      height: 1.35,
                    ),
                  ),

                // Tags chips
                if (note.tags.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.p12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: note.tags
                        .take(3)
                        .map((t) => TagChip(tag: t))
                        .toList(),
                  ),
                ],

                const SizedBox(height: AppDimensions.p12),

                // Bottom row: Date & Reading Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      note.updatedAt.formatRelative(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      note.readingTimeFormatted,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
