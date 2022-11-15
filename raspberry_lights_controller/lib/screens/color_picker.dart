import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/providers/pattern.dart';
import 'package:raspberry_lights_controller/providers/saved_color.dart';
import 'package:raspberry_lights_controller/widgets/hsv_color_slider.dart';
import 'package:raspberry_lights_controller/widgets/color_tile.dart';
import 'package:raspberry_lights_controller/models/color.dart';

void openColorPicker(
  BuildContext context,
  WidgetRef ref, {
  int? index,
}) async {
  var color = await Navigator.of(context).push<Color>(
    MaterialPageRoute(
      builder: (context) => ColorPickerPage(
        color: index != null ? ref.read(colorsProvider)[index] : Colors.white,
      ),
    ),
  );
  if (color != null) {
    if (index == null) {
      ref.read(colorsProvider.notifier).addColor(color: color);
    } else {
      ref.read(colorsProvider.notifier).setColor(color: color, index: index);
    }
  }
}

class ColorPickerPage extends StatefulWidget {
  const ColorPickerPage({
    Key? key,
    required this.color,
  }) : super(key: key);

  final Color color;

  @override
  State<ColorPickerPage> createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> {
  late HSVColor color = HSVColor.fromColor(widget.color);
  Color get rgbColor => color.toColor();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close),
        ),
        title: const Text("Choose a Color"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop(rgbColor);
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                height: 80,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: rgbColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white24,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            HSVColorSlider(
              color: color,
              onColorChanged: (newColor) {
                setState(() {
                  color = newColor;
                });
              },
            ),
            _SavedColorList(
              color: rgbColor,
              onTapColor: (newColor) {
                setState(() {
                  color = HSVColor.fromColor(newColor);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedColorList extends ConsumerWidget {
  const _SavedColorList({required this.onTapColor, required this.color});

  final ValueChanged<Color> onTapColor;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedColors = ref.watch(savedColorsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                "Saved Colors:",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 18),
              ),
              const Spacer(),
              TextButton(
                child: const Text("Save Current Color"),
                onPressed: () {
                  ref.read(savedColorsProvider.notifier).saveColor(color);
                },
              ),
            ],
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: savedColors.length,
          itemBuilder: (context, index) {
            final item = savedColors[index];

            return ColorTile(
              color: item,
              key: Key(item.toHexString()),
              onTap: () => onTapColor(item),
              onDelete: () {
                ref.read(savedColorsProvider.notifier).removeSavedColor(item);
              },
            );
          },
        ),
      ],
    );
  }
}
