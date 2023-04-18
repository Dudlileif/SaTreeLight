import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/src/features/mask_selection/mask_selection.dart';

/// A dialog that containts toggles for the mask layers.
class MaskSelectionDialog extends ConsumerStatefulWidget {
  const MaskSelectionDialog({super.key});

  @override
  ConsumerState<MaskSelectionDialog> createState() =>
      _MaskSelectionDialogState();
}

class _MaskSelectionDialogState extends ConsumerState<MaskSelectionDialog> {
  @override
  Widget build(BuildContext context) {
    final selectedMasks = ref.watch(selectedMasksProvider);
    final colors = CoverageColors.colorMapWithOpacity(
      dark: Theme.of(context).brightness == Brightness.dark,
      opacity: 0.5,
    );
    final shadowBlendColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final items = CoverageType.values.map((mask) {
      final enabled = selectedMasks.contains(mask);
      final color = enabled ? colors[mask] : null;

      return CheckboxListTile(
        value: enabled,
        onChanged: (newValue) =>
            ref.read(selectedMasksProvider.notifier).update(mask),
        title: Text(mask.capitalizedString()),
        secondary: Stack(
          children: [
            DecoratedIcon(
              mask.icon,
              color: color,
              shadows: enabled
                  ? [
                      Shadow(
                        blurRadius: 0.5,
                        offset: const Offset(1, 1),
                        color: Color.lerp(
                              colors[mask],
                              shadowBlendColor,
                              0.33,
                            ) ??
                            shadowBlendColor,
                      )
                    ]
                  : null,
            ),
          ],
        ),
      );
    });
    return SimpleDialog(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Stack(
            children: [
              Center(
                child: Text(
                  'Mask selection',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: CloseButton(),
              )
            ],
          ),
        ),
        const Divider(),
        CheckboxListTile(
          secondary: DecoratedIcon(
            Icons.done,
            shadows: selectedMasks.join() == CoverageType.values.join()
                ? [
                    Shadow(
                      blurRadius: 0.5,
                      offset: const Offset(1, 1),
                      color: Color.lerp(
                            Theme.of(context).iconTheme.color,
                            shadowBlendColor,
                            0.33,
                          ) ??
                          shadowBlendColor,
                    )
                  ]
                : null,
          ),
          title: const Text('Toggle all'),
          value: selectedMasks.join() == CoverageType.values.join(),
          onChanged: (value) {
            if (value != null) {
              if (value) {
                ref.read(selectedMasksProvider.notifier).enableAll();
              } else {
                ref.read(selectedMasksProvider.notifier).disableAll();
              }
            }
          },
        ),
        const Divider(),
        ...items
      ],
    );
  }
}
