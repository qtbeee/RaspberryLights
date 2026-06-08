import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/providers/current_pattern.dart';
import 'package:raspberry_lights_controller/providers/network.dart';
import 'package:raspberry_lights_controller/providers/pattern_list.dart';
import 'package:raspberry_lights_controller/screens/app_settings.dart';
import 'package:raspberry_lights_controller/widgets/current_pattern.dart';
import 'package:raspberry_lights_controller/widgets/update_host_url_dialog.dart';

class Home extends ConsumerWidget {
  const Home({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final host = ref.watch(hostProvider);
    final patternList = ref.watch(patternListProvider);
    final currentPattern = ref.watch(currentPatternProvider);

    final isLoading = patternList.isLoading || currentPattern.isLoading;
    final hasError =
        !isLoading && (patternList.hasError || currentPattern.hasError);
    final error = patternList.error ?? currentPattern.error;

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
      body: buildBody(
        isLoading: isLoading,
        hasError: hasError,
        host: host,
        error: error,
      ),
    );
  }
}

Widget buildBody({
  required bool isLoading,
  required bool hasError,
  required ConnectionInfo? host,
  required Object? error,
}) {
  if (host == null) {
    return const Center(child: CircularProgressIndicator());
  }

  if (host.info == null) {
    return const _NoBaseUrl();
  }

  if (isLoading) {
    return const _Loading();
  }

  if (hasError) {
    return _FailedToFetch(error: error.toString());
  }

  return const CurrentPattern();
}

class _NoBaseUrl extends ConsumerWidget {
  const _NoBaseUrl();

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

class _FailedToFetch extends ConsumerWidget {
  final String error;

  const _FailedToFetch({required this.error});

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

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: .center,
      children: [
        LinearProgressIndicator(),
        Expanded(
          child: Center(child: Text('Fetching available light patterns...')),
        ),
      ],
    );
  }
}
