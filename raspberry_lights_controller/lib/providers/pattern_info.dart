import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/models/pattern_info.dart';
import 'package:raspberry_lights_controller/providers/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pattern_info.g.dart';

@riverpod
Future<List<PatternInfo>> patternInfo(Ref ref) async {
  final client = ref.watch(networkClientProvider);
  var response = await client.get("pattern");
  return List.from(response.data['patterns'])
      .map((v) => PatternInfo.fromJson(v))
      .toList();
}
