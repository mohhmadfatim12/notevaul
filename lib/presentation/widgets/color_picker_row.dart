import 'package:flutter/material.dart';
import 'package:notevault/core/constants/app_colors.dart';
import 'package:notevault/core/constants/app_dimensions.dart';

class ColorPickerRow extends StatelessWidget {
  final int selectedColorId;
  final ValueChanged<int> onColorSelected;

  const ColorPickerRow({
    super.key,
    required this.selectedColorId,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.p16,
        vertical: AppDimensions.p8,
      ),
      child: Row(
        children: AppColors.noteColors.map((option) {
          final isSelected = option.id == selectedColorId;
          final color = option.resolve(isDark);

          return Padding(
            padding: const EdgeInsets.only(right: AppDimensions.p12),
            child: GestureDetector(
              onTap: () => onColorSelected(option.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : option.borderColor,
                    width: isSelected ? 2.5 : 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: isDark ? Colors.white : Colors.black87,
                      )
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
