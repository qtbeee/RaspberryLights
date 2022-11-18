import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/providers/pattern.dart';
import 'package:raspberry_lights_controller/providers/saved_color.dart';
import 'package:raspberry_lights_controller/widgets/hsv_color_slider.dart';
import 'package:raspberry_lights_controller/widgets/color_tile.dart';
import 'package:raspberry_lights_controller/utils/color.dart';
import 'package:raspberry_lights_controller/widgets/palette_list.dart';

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

class _ColorPickerPageState extends State<ColorPickerPage>
    with TickerProviderStateMixin {
  late HSVColor color = HSVColor.fromColor(widget.color);
  Color get rgbColor => color.toColor();
  late final TabController _controller = TabController(length: 2, vsync: this);

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
        bottom: TabBar(
          tabs: const [Tab(text: "Custom"), Tab(text: "From Palette")],
          controller: _controller,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop(rgbColor);
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints.expand(height: 80),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: rgbColor,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          offset: Offset(3, 3),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  rgbColor.toHexString().toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ThemeData.estimateBrightnessForColor(rgbColor) ==
                            Brightness.light
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _controller,
              children: [
                Column(
                  children: [
                    HSVColorSlider(
                      color: color,
                      onColorChanged: (newColor) {
                        setState(() {
                          color = newColor;
                        });
                      },
                    ),
                    Expanded(
                      child: _SavedColorList(
                        color: rgbColor,
                        onTapColor: (newColor) {
                          setState(() {
                            color = HSVColor.fromColor(newColor);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  child: PaletteList(
                    onColorSelected: (newColor) {
                      setState(() {
                        color = HSVColor.fromColor(newColor);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
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
                "Favorite Colors:",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 18),
              ),
              const Spacer(),
              TextButton(
                child: const Text("Add to Favorites"),
                onPressed: () {
                  ref.read(savedColorsProvider.notifier).saveColor(color);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
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
        ),
      ],
    );
  }
}
