import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/widgets/palette_list.dart';

Future<List<Color>?> openPalettePicker(BuildContext context) async {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (context) => const PalettePicker()));
}

class PalettePicker extends ConsumerWidget {
  const PalettePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Palette"),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.close),
        ),
      ),
      body: SingleChildScrollView(
        child: PaletteList(
          onPaletteSelected: (newColors) {
            Navigator.of(context).pop(newColors);
          },
        ),
      ),
    );
  }
}
