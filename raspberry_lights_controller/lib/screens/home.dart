import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/providers/current_pattern.dart';
import 'package:raspberry_lights_controller/providers/pattern_list.dart';
import 'package:raspberry_lights_controller/screens/app_settings.dart';
import 'package:raspberry_lights_controller/utils/exception.dart';
import 'package:raspberry_lights_controller/widgets/current_pattern.dart';
import 'package:raspberry_lights_controller/widgets/loading.dart';
import 'package:raspberry_lights_controller/widgets/update_host_url_dialog.dart';

class Home extends ConsumerWidget {
  const Home({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patternList = ref.watch(patternListProvider);
    final currentPattern = ref.watch(currentPatternProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                ..invalidate(patternListProvider)
                ..invalidate(currentPatternProvider);
            },
          ),
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const AppSettings(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: switch ((currentPattern, patternList)) {
        (AsyncValue(hasError: true, :final error), _) => onError(error!),
        (_, AsyncValue(hasError: true, :final error)) => onError(error!),
        (AsyncValue(hasValue: true), AsyncValue(hasValue: true)) =>
          const CurrentPattern(),
        _ => const Loading(),
      },
    );
  }
}

Widget onError(Object error) {
  if (error is NoBaseUrlException) {
    return const NoBaseUrl();
  }
  return FailedToFetch(error: error.toString());
}

class NoBaseUrl extends ConsumerWidget {
  const NoBaseUrl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: .stretch,
      mainAxisAlignment: .center,
      children: [
        const Text(
          'No Saved Connection',
          style: TextStyle(fontSize: 24, fontWeight: .bold),
          textAlign: TextAlign.center,
        ),
        TextButton(
          onPressed: () async {
            await openUpdateHostUrlDialog(context, ref);
          },
          child: const Text('Setup'),
        ),
      ],
    );
  }
}

class FailedToFetch extends ConsumerWidget {
  final String error;

  const FailedToFetch({required this.error, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: .center,
      crossAxisAlignment: .stretch,
      children: [
        const Text(
          'Failed to fetch data.',
          style: TextStyle(fontSize: 24, fontWeight: .bold),
          textAlign: TextAlign.center,
        ),
        Text(error, textAlign: TextAlign.center),
        TextButton(
          onPressed: () async {
            await openUpdateHostUrlDialog(context, ref);
          },
          child: const Text('Edit Connection'),
        ),
      ],
    );
  }
}
