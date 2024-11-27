import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/providers/network.dart';
import 'package:raspberry_lights_controller/providers/pattern_info.dart';
import 'package:raspberry_lights_controller/widgets/loading.dart';
import 'package:raspberry_lights_controller/providers/pattern.dart';
import 'package:raspberry_lights_controller/widgets/pattern_form.dart';
import 'package:raspberry_lights_controller/widgets/update_host_url_dialog.dart';

class Home extends ConsumerWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patternInfo = ref.watch(patternInfoProvider);
    final host = ref.watch(hostProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(animationSpeedProvider.notifier).reset();
              ref.read(selectedPatternProvider.notifier).reset();
              ref.read(patternColorsProvider.notifier).reset();
              ref.invalidate(patternInfoProvider);
            },
          )
        ],
      ),
      body: patternInfo.when(
        data: (data) => PatternForm(data: data),
        error: (_, __) => Center(
          child: Column(
            children: [
              const Text(
                'Failed to fetch data.',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextButton(
                  onPressed: () async {
                    final result = await showDialog<(String, int)>(
                      builder: (BuildContext context) =>
                          UpdateHostUrlDialog(host),
                      context: context,
                    );
                    if (result != null) {
                      ref.read(hostProvider.notifier).setHostUrl(result);
                    }
                  },
                  child: const Text('Edit Connection')),
            ],
          ),
        ),
        loading: () => const Loading(),
      ),
    );
  }
}
