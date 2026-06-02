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
  const Home({super.key, required this.title});

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
              ref.invalidate(patternListProvider);
              ref.invalidate(currentPatternProvider);
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => AppSettings()));
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: currentPattern.when(
        data: (_) => patternList.when(
          data: (data) => CurrentPattern(),
          error: onError,
          loading: onLoading,
          skipLoadingOnRefresh: false,
        ),
        error: onError,
        loading: onLoading,
        skipLoadingOnRefresh: false,
      ),
    );
  }
}

Widget onError(Object error, StackTrace _) {
  if (error is NoBaseUrlException) {
    return const NoBaseUrl();
  }
  return FailedToFetch(error: error.toString());
}

Widget onLoading() => const Loading();

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
          child: const Text('Setup'),
        ),
      ],
    );
  }
}

class FailedToFetch extends ConsumerWidget {
  final String error;
  const FailedToFetch({super.key, required this.error});

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
        Text(error, textAlign: TextAlign.center),
        TextButton(
          onPressed: () {
            openUpdateHostUrlDialog(context, ref);
          },
          child: const Text('Edit Connection'),
        ),
      ],
    );
  }
}
