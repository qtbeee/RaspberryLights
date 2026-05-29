import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/models/pattern_configuration.dart';
import 'package:raspberry_lights_controller/providers/network.dart';
import 'package:raspberry_lights_controller/utils/no_base_url_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_pattern.g.dart';

@riverpod
Future<PatternConfiguration> currentPattern(Ref ref) async {
  final client = ref.watch(networkClientProvider);
  if (client.options.baseUrl.isEmpty) {
    throw NoBaseUrlException();
  }

  var response = await client.get("pattern");
  print(response);
  return PatternConfiguration.fromJson(response.data);
}
