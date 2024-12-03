import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/providers/pattern_info.dart';
import 'package:raspberry_lights_controller/screens/settings.dart';
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
          ),
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Settings()));
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: patternInfo.when(
        data: (data) => PatternForm(data: data),
        error: (error, __) {
          if (error is NoBaseUrlException) {
            return NoBaseUrl();
          }
          return FailedToFetch();
        },
        loading: () => const Loading(),
        skipLoadingOnRefresh: false,
      ),
    );
  }
}

class NoBaseUrl extends ConsumerWidget {
  const NoBaseUrl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "No Saved Connection",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        TextButton(
            onPressed: () {
              openUpdateHostUrlDialog(context, ref);
            },
            child: const Text('Setup')),
      ],
    );
  }
}

class FailedToFetch extends ConsumerWidget {
  const FailedToFetch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Failed to fetch data.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        TextButton(
            onPressed: () {
              openUpdateHostUrlDialog(context, ref);
            },
            child: const Text('Edit Connection')),
      ],
    );
  }
}
