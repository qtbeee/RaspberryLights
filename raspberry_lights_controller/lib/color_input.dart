import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorInput extends StatefulWidget {
  const ColorInput({
    Key key,
    @required this.color,
    @required this.enabled,
    @required this.onChanged,
  }) : super(key: key);

  final Color color;
  final bool enabled;
  final void Function(Color) onChanged;

  @override
  _ColorInputState createState() => _ColorInputState();
}

class _ColorInputState extends State<ColorInput> {
  Color pickerColor;

  @override
  void initState() {
    pickerColor = Colors.white;
    super.initState();
  }

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
                      activateColorPicker(context);
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

  void activateColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (newColor) {
                setState(() {
                  pickerColor = newColor;
                });
              },
              paletteType: PaletteType.hsl,
              enableAlpha: false,
              displayThumbColor: true,
              showLabel: true,
            ),
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                widget.onChanged(pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}