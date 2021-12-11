import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorInput extends StatefulWidget {
  const ColorInput({
    this.color = Colors.white,
    required this.enabled,
    required this.onChanged,
  });

  final Color color;
  final bool enabled;
  final void Function(Color) onChanged;

  @override
  _ColorInputState createState() => _ColorInputState();
}

class _ColorInputState extends State<ColorInput> {
  var hexInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(children: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: ElevatedButton.icon(
              onPressed: widget.enabled
                  ? () {
                      openColorPicker(context);
                    }
                  : null,
              icon: const Icon(Icons.palette),
              label: const Text('Choose a color')),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: widget.color,
              border: Border.all(color: Colors.black38, width: 3),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            height: 37,
          ),
        ),
      ]),
    );
  }

  // open a new page method
  void openColorPicker(BuildContext context) async {
    var color = await Navigator.of(context).push<Color>(
      MaterialPageRoute(
        builder: (context) => ColorPickerPage(
          color: widget.color,
        ),
      ),
    );
    if (color != null) {
      widget.onChanged(color);
    }
  }
}

class ColorPickerPage extends StatefulWidget {
  const ColorPickerPage({
    required this.color,
  });

  final Color color;

  @override
  State<ColorPickerPage> createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> {
  late Color color;
  List<String> history = [];

  @override
  void initState() {
    color = widget.color;
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

      final newHistory = history.toList();
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
