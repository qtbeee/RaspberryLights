import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/providers/network.dart';
import 'package:raspberry_lights_controller/widgets/update_host_url_dialog.dart';

class AppSettings extends ConsumerWidget {
  const AppSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final host = ref.watch(hostProvider)?.info;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const .symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      const Text(
                        'Connection Information',
                        style: TextStyle(
                          fontWeight: .bold,
                          fontSize: 18,
                        ),
                      ),
                      DisplayUrl(host: host),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await openUpdateHostUrlDialog(context, ref);
                  },
                ),
              ],
            ),
          ],
        ),
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
      return Text('${host.$1}:${host.$2}');
    } else {
      return const Text(
        'Not Configured',
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    }
  }
}
