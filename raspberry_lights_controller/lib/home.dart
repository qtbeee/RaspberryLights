import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/widgets/loading.dart';
import 'package:raspberry_lights_controller/providers/pattern.dart';
import 'package:raspberry_lights_controller/widgets/pattern_form.dart';

class Home extends ConsumerWidget {
  const Home({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patternInfo = ref.watch(patternInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(animationSpeedProvider.notifier).reset();
              ref
                  .read(selectedPatternProvider.notifier)
                  .update((state) => null);
              ref.read(colorsProvider.notifier).reset();
              ref.refresh(patternInfoProvider);
            },
          )
        ],
      ),
      body: patternInfo.when(
        data: (data) => PatternForm(data: data),
        error: (_, __) => const Center(
          child: Text(
            'No data, try again later.',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        loading: () => const Loading(),
      ),
    );
  }
}
