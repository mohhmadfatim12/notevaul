import 'package:flutter/material.dart';
import 'package:notevault/core/constants/app_dimensions.dart';
import 'package:notevault/domain/entities/tag_entity.dart';

class TagChip extends StatelessWidget {
  final TagEntity tag;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  const TagChip({
    super.key,
    required this.tag,
    this.isSelected = false,
    this.onTap,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tagColor = Color(tag.color);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.rCircle),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.p12,
            vertical: onDeleted != null ? AppDimensions.p4 : AppDimensions.p6,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? tagColor.withValues(alpha: 0.22)
                : tagColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.rCircle),
            border: Border.all(
              color: isSelected ? tagColor : tagColor.withValues(alpha: 0.35),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: tagColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimensions.p6),
              Text(
                '#${tag.name}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (onDeleted != null) ...[
                const SizedBox(width: AppDimensions.p4),
                GestureDetector(
                  onTap: onDeleted,
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
