import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/providers/pattern.dart';
import 'package:raspberry_lights_controller/widgets/palette_list.dart';

void openPalettePicker(BuildContext context) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const PalettePicker(),
    ),
  );
}

class PalettePicker extends ConsumerWidget {
  const PalettePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Palette"),
      ),
      body: SingleChildScrollView(
        child: PaletteList(
          onPaletteSelected: (newColors) {
            ref.read(patternColorsProvider.notifier).setColors(newColors);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
