import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/providers/pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    if (changedHistory.add(colorToHex(color, enableAlpha: false))) {
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
            HueRingPicker(
              pickerColor: color,
              onColorChanged: (newColor) {
                setState(() {
                  color = newColor;
                });
              },
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
                final itemColor = colorFromHex(item)!;

                return ListTile(
                  key: Key(item),
                  leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: itemColor,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.black38, width: 2),
                    ),
                  ),
                  title: Text(item),
                  onTap: () {
                    setState(() {
                      color = itemColor;
                    });
                  },
                  onLongPress: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return ListTile(
                          leading: const Icon(Icons.delete),
                          title: const Text("Remove"),
                          onTap: () {
                            removeSavedColor(item);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    );
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
