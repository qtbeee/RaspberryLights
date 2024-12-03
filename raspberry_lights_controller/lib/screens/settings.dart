import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/providers/network.dart';
import 'package:raspberry_lights_controller/widgets/update_host_url_dialog.dart';

class Settings extends ConsumerWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final host = ref.watch(hostProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        leading: BackButton(),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Connection Information",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  DisplayUrl(host: host),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                ),
                onPressed: () {
                  openUpdateHostUrlDialog(context, ref);
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}

class DisplayUrl extends StatelessWidget {
  final (String, int)? host;

  const DisplayUrl({super.key, this.host});

  @override
  Widget build(BuildContext context) {
    final host = this.host;
    if (host != null) {
      return Text("${host.$1}:${host.$2}");
    } else {
      return Text(
        "Not Configured",
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    }
  }
}
