import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/providers/pattern.dart';
import 'package:raspberry_lights_controller/widgets/color_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

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
  late Color color = widget.color;
  List<String> history = [];

  @override
  void initState() {
    fetchSavedColors();
    super.initState();
  }

  Future<void> fetchSavedColors() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      history = prefs.getStringList("savedColors") ?? [];
    });
  }

  void saveColor(Color color) async {
    final changedHistory = history.toSet();

    if (changedHistory.add(color.hex)) {
      var prefs = await SharedPreferences.getInstance();

      final newHistory = changedHistory.toList();
      await prefs.setStringList("savedColors", newHistory);
      setState(() {
        history = newHistory;
      });
    }
  }

  void removeSavedColor(String color) async {
    var prefs = await SharedPreferences.getInstance();
    history.remove(color);
    await prefs.setStringList("savedColors", history);

    setState(() {});
  }

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
              Navigator.of(context).pop(color);
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
            ColorPicker(
              color: color,
              onColorChanged: (newColor) {
                setState(() {
                  debugPrint(newColor.toString());
                  color = newColor;
                });
              },
              borderRadius: 4,
              pickersEnabled: const {
                ColorPickerType.primary: false,
                ColorPickerType.accent: false,
                ColorPickerType.custom: true,
                ColorPickerType.wheel: true,
              },
              customColorSwatchesAndNames: {
                const ColorSwatch(
                  0xFFA71010,
                  {500: Color(0xFFA71010)},
                ): 'Red',
                const ColorSwatch(
                  0xFFA14A0C,
                  {500: Color(0xFFA14A0C)},
                ): 'Orange',
                const ColorSwatch(
                  0xFF999726,
                  {500: Color(0xFF999726)},
                ): 'Yellow',
                const ColorSwatch(
                  0xFF18993f,
                  {500: Color(0xFF18993f)},
                ): 'Green',
                const ColorSwatch(
                  0xFF189999,
                  {500: Color(0xFF189999)},
                ): 'Cyan',
                const ColorSwatch(
                  0xFF183f99,
                  {500: Color(0xFF183f99)},
                ): 'Blue',
                const ColorSwatch(
                  0xFF672699,
                  {500: Color(0xFF672699)},
                ): 'Purple',
                const ColorSwatch(
                  0xFF992656,
                  {500: Color(0xFF992656)},
                ): 'Pink',
                const ColorSwatch(
                  0xFFFFFFFF,
                  {
                    500: Color(0xFFFFFFFF),
                    400: Color(0xFFAAAAAA),
                    300: Color(0xFF888888),
                    200: Color(0xFF555555),
                    100: Color(0xFF111111),
                  },
                ): 'White',
              },
              subheading: const Text('Shades'),
              enableShadesSelection: true,
              hasBorder: true,
              showColorCode: true,
              colorCodeHasColor: true,
              copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                copyFormat: ColorPickerCopyFormat.numHexRRGGBB,
              ),
              // showColorName: true,
              wheelDiameter: 250,
              wheelSquarePadding: 16,
              wheelWidth: 16,
            ),
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
                      setState(() {
                        saveColor(color);
                      });
                    },
                  ),
                ],
              ),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final itemColor = item.toColor;

                return ColorTile(
                  color: itemColor,
                  key: Key(item),
                  onTap: () {
                    setState(() {
                      color = itemColor;
                    });
                  },
                  onDelete: () {
                    removeSavedColor(item);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
