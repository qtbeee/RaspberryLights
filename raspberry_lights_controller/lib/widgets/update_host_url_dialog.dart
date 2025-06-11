import 'dart:developer';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/providers/network.dart';

void openUpdateHostUrlDialog(BuildContext context, WidgetRef ref) async {
  final host = ref.read(hostProvider);
  final result = await showDialog<(String, int)>(
    builder: (BuildContext context) => UpdateHostUrlDialog(host),
    context: context,
  );
  if (result != null) {
    ref.read(hostProvider.notifier).setHostUrl(result);
  }
}

class UpdateHostUrlDialog extends StatefulWidget {
  final (String, int)? initialHost;

  const UpdateHostUrlDialog(this.initialHost, {super.key});

  @override
  State<StatefulWidget> createState() => _UpdateHostUrlDialogState();
}

class _UpdateHostUrlDialogState extends State<UpdateHostUrlDialog> {
  final TextEditingController _ipController = TextEditingController(text: "");
  final TextEditingController _portController = TextEditingController(text: "");
  String? resolvedHost;

  bool isValidHost = false;
  bool isValidPort = false;

  bool get isAllValid =>
      isValidHost && _ipController.text == resolvedHost && isValidPort;

  final _bonsoirClient = BonsoirDiscovery(type: "_workstation._tcp");
  final _hostnames = <String, String>{};

  @override
  initState() {
    if (widget.initialHost != null) {
      _ipController.text = widget.initialHost?.$1 ?? "";
      _portController.text = widget.initialHost?.$2.toString() ?? "";
    }

    setupBonsoir();

    checkAddress();
    checkPort();
    super.initState();
  }

  Future<void> setupBonsoir() async {
    await _bonsoirClient.ready;
    _bonsoirClient.eventStream?.listen((event) {
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        log('Service found : ${event.service?.toJson()}');
        event.service!.resolve(
          _bonsoirClient.serviceResolver,
        ); // Should be called when the user wants to connect to this service.
      } else if (event.type ==
          BonsoirDiscoveryEventType.discoveryServiceResolved) {
        final jsonService = event.service!.toJson();
        log('Service resolved : $jsonService');
        log(
          "${jsonService.toString()} ${jsonService["service.name"]} ${jsonService["service.host"]}",
        );
        setState(() {
          _hostnames[jsonService["service.name"]] = jsonService["service.host"];
        });
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        final jsonService = event.service!.toJson();
        log('Service lost : $jsonService');
        setState(() {
          _hostnames.remove(jsonService["service.name"]);
        });
      }
    });

    await _bonsoirClient.start();
  }

  @override
  void dispose() {
    _bonsoirClient.stop();
    super.dispose();
  }

  void checkAddress() async {
    log("current ip field: ${_ipController.text}");
    try {
      final isValidAsIp = InternetAddress.tryParse(_ipController.text) != null;
      log("is she valid? $isValidAsIp");
      if (isValidAsIp) {
        setState(() {
          isValidHost = true;
          resolvedHost = _ipController.text;
        });
      } else {
        final a = await InternetAddress.lookup(_ipController.text);
        log(a.toString());
        setState(() {
          isValidHost = true;
          resolvedHost = a.first.address;
        });
      }
    } catch (e) {
      setState(() {
        isValidHost = false;
        resolvedHost = null;
      });
    }
  }

  void checkPort() {
    try {
      final parsedPort = int.parse(_portController.text);
      // 65535 is the max allowed port number
      if (parsedPort > 0 && parsedPort < 65535) {
        setState(() {
          isValidPort = true;
        });
      } else {
        setState(() {
          isValidPort = false;
        });
      }
    } catch (e) {
      setState(() {
        isValidPort = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final indexedHostnames = _hostnames.entries.toList(growable: false);

    return AlertDialog(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _ipController,
            decoration: InputDecoration(labelText: 'Host IP'),
            onChanged: (_) => checkAddress(),
          ),
          TextField(
            controller: _portController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: 'Host Port'),
            onChanged: (_) => checkPort(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Tap below to autofill IP",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // NOTE: If only I could remember how to make a ListView.builder work nicely with nested scrolling???
          // Thankfully most people shouldn't have rendering issues with having too many things in the list... right?
          for (var item in indexedHostnames)
            ListTile(
              title: Text(item.key),
              subtitle: Text(item.value),
              onTap: () {
                setState(() {
                  _ipController.text = item.value;
                });
                checkAddress();
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: isAllValid
              ? () {
                  Navigator.of(
                    context,
                  ).pop((resolvedHost, int.parse(_portController.text)));
                }
              : null,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
