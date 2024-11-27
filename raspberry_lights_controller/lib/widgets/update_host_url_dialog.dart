import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UpdateHostUrlDialog extends StatefulWidget {
  final (String, int)? initialHost;

  const UpdateHostUrlDialog(this.initialHost, {super.key});

  @override
  State<StatefulWidget> createState() => _UpdateHostUrlDialogState();
}

class _UpdateHostUrlDialogState extends State<UpdateHostUrlDialog> {
  late TextEditingController _ipController;
  late TextEditingController _portController;

  @override
  void initState() {
    if (widget.initialHost != null) {}
    _ipController = TextEditingController.fromValue(
        TextEditingValue(text: widget.initialHost?.$1 ?? ""));
    _portController = TextEditingController.fromValue(
        TextEditingValue(text: widget.initialHost?.$2.toString() ?? ""));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        children: [
          TextField(
            controller: _ipController,
            decoration: InputDecoration(labelText: 'Host IP'),
          ),
          TextField(
            controller: _portController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: 'Host Port'),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel")),
        TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pop((_ipController.text, int.parse(_portController.text)));
            },
            child: const Text("Save"))
      ],
    );
  }
}
