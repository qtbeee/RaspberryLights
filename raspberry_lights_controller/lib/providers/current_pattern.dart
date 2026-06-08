import 'dart:developer';

import 'package:raspberry_lights_controller/models/pattern_configuration.dart';
import 'package:raspberry_lights_controller/providers/network.dart';
import 'package:raspberry_lights_controller/utils/exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_pattern.g.dart';

@riverpod
Future<PatternConfiguration> currentPattern(Ref ref) async {
  final client = ref.watch(networkClientProvider);
  log(client.options.baseUrl.isEmpty ? 'no baseurl' : 'baseurl is set');
  if (client.options.baseUrl.isEmpty) {
    throw NoBaseUrlException();
  }

  final response = await client.get<Map<String, dynamic>>('pattern');
  return PatternConfiguration.fromJson(response.data!);
}
