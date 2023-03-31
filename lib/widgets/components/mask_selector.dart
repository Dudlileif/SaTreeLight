import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/models/coverage_colors.dart';
import 'package:satreelight/models/coverage_type.dart';
import 'package:satreelight/providers/providers.dart';

/// A dialog that containts toggles for the mask layers.
class MaskSelector extends ConsumerStatefulWidget {
  const MaskSelector({super.key});

  @override
  ConsumerState<MaskSelector> createState() => _MaskSelectorState();
}

class _MaskSelectorState extends ConsumerState<MaskSelector> {
  final icons = [
    Icons.close,
    Icons.dark_mode,
    Icons.cloud,
    Icons.grass,
    Icons.business_outlined,
    Icons.water_drop,
    Icons.question_mark,
    Icons.cloud,
    Icons.cloud,
    Icons.cloud,
    Icons.snowing
  ];

  @override
  Widget build(BuildContext context) {
    List<bool> enabledMasks = ref.watch(maskSelectionProvider).masks;
    final colors = CoverageColors.colorMapWithOpacity(
      dark: Theme.of(context).brightness == Brightness.dark,
      opacity: 0.5,
    );
    final shadowBlendColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final items = List.generate(CoverageType.values.length, (index) {
      final enabled = enabledMasks[index];
      final color = enabled ? colors.values.elementAt(index) : null;

      return CheckboxListTile(
        value: enabled,
        onChanged: (newValue) => ref
            .read(maskSelectionProvider.notifier)
            .updateMask(index, newValue ?? true),
        title: Text(CoverageType.values[index].capitalizedString()),
        secondary: Stack(children: [
          DecoratedIcon(
            icons[index],
            color: color,
            shadows: enabled
                ? [
                    Shadow(
                        blurRadius: 0.5,
                        offset: const Offset(1, 1),
                        color:
                            Color.lerp(colors[index], shadowBlendColor, 0.33) ??
                                shadowBlendColor)
                  ]
                : null,
          ),
        ]),
      );
    });
    return SimpleDialog(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Center(
                child: Text(
                  'Mask selection',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Align(
                  alignment: Alignment.centerRight, child: CloseButton())
            ],
          ),
        ),
        const Divider(),
        CheckboxListTile(
          secondary: DecoratedIcon(
            Icons.done,
            shadows: !enabledMasks.contains(false)
                ? [
                    Shadow(
                        blurRadius: 0.5,
                        offset: const Offset(1, 1),
                        color: Color.lerp(Theme.of(context).iconTheme.color,
                                shadowBlendColor, 0.33) ??
                            shadowBlendColor)
                  ]
                : null,
          ),
          title: const Text('Toggle all'),
          value: !enabledMasks.contains(false),
          onChanged: (value) => value ?? true
              ? ref.read(maskSelectionProvider.notifier).enableAll()
              : ref.read(maskSelectionProvider.notifier).disableAll(),
        ),
        const Divider(),
        ...items
      ],
    );
  }
}
