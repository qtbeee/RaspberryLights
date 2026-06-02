import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/screens/color_picker.dart';
import 'package:raspberry_lights_controller/screens/palette_picker.dart';
import 'package:raspberry_lights_controller/widgets/color_tile.dart';

Future<List<Color>?> openColorsEditor(
  BuildContext context,
  List<Color> initialColors,
) async {
  return Navigator.of(context).push<List<Color>?>(
    MaterialPageRoute(
      builder: (context) => ColorsEditorPage(initialColors: initialColors),
    ),
  );
}

class ColorsEditorPage extends ConsumerStatefulWidget {
  final List<Color> initialColors;
  const ColorsEditorPage({super.key, required this.initialColors});

  @override
  ConsumerState<ColorsEditorPage> createState() => _ColorsEditorPageState();
}

class _ColorsEditorPageState extends ConsumerState<ColorsEditorPage> {
  late List<Color> colors;

  @override
  void initState() {
    super.initState();
    colors = widget.initialColors;
  }

  void setColor({required Color newColor, required int index}) {
    final newColors = [...colors];
    newColors[index] = newColor;

    setState(() => colors = newColors);
  }

  void setColors(List<Color> newColors) {
    setState(() => colors = newColors);
  }

  void addColor({required Color color}) {
    setState(() => colors = [...colors, color]);
  }

  void moveColor({required int oldIndex, required int newIndex}) {
    final newColors = [...colors];
    final movedColor = newColors.removeAt(oldIndex);
    final insertionIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    newColors.insert(insertionIndex, movedColor);

    setState(() => colors = newColors);
  }

  void removeColor({required int index}) {
    // Failsafe: I've only been able to trigger this if the emulator was
    // lagging like hell and I was spamming click over the delete color buttons
    if (colors.length <= 1 || index < 0 || index >= colors.length) {
      return;
    }

    final updated = [...colors]..removeAt(index);

    setState(() => colors = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Colors"),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.close),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(colors),
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final colors = await openPalettePicker(context);
                        if (colors != null) {
                          setColors(colors);
                        }
                      },
                      label: const Text('Set from Palette'),
                      icon: Icon(Icons.palette),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final color = await openColorPicker(
                          context,
                          Colors.white,
                        );
                        if (color != null) {
                          addColor(color: color);
                        }
                      },
                      label: const Text("Add Color"),
                      icon: Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemBuilder: (context, index) {
                return ColorTile(
                  key: ValueKey('${colors[index]} $index'),
                  color: colors[index],
                  onTap: () async {
                    final color = await openColorPicker(context, colors[index]);
                    if (color != null) {
                      setColor(newColor: color, index: index);
                    }
                  },
                  onDelete: colors.length > 1
                      ? () => removeColor(index: index)
                      : null,
                );
              },
              itemCount: colors.length,
              onReorder: (oldIndex, newIndex) {
                moveColor(oldIndex: oldIndex, newIndex: newIndex);
              },
            ),
          ),
        ],
      ),
    );
  }
}
