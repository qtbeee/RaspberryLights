import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/providers/pattern.dart';

import 'color_picker.dart';

class ColorInput extends ConsumerWidget {
  const ColorInput({
    Key? key,
    required this.index,
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedColors = ref.watch(colorsProvider);
    final color = selectedColors[index];
    final foregroundColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black;

    return ListTile(
      key: key,
      tileColor: color,
      title: Text(
        colorToHex(
          color,
          includeHashSign: true,
          enableAlpha: false,
        ),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: foregroundColor,
        ),
      ),
      trailing: selectedColors.length > 1
          ? IconButton(
              icon: const Icon(Icons.delete),
              color: foregroundColor,
              onPressed: () {
                ref.read(colorsProvider.notifier).removeColor(index: index);
              },
            )
          : null,
      onTap: () {
        openColorPicker(context, ref, index: index);
      },
    );
  }
}
