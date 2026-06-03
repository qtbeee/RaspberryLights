import 'package:raspberry_lights_controller/models/get_pattern_list_response.dart';
import 'package:raspberry_lights_controller/models/pattern_info.dart';
import 'package:raspberry_lights_controller/providers/network.dart';
import 'package:raspberry_lights_controller/utils/exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pattern_list.g.dart';

@riverpod
Future<List<PatternInfo>> patternList(Ref ref) async {
  final client = ref.watch(networkClientProvider);
  if (client.options.baseUrl.isEmpty) {
    throw NoBaseUrlException();
  }

  final response = await client.get<Map<String, dynamic>>('patterns');
  return GetPatternListResponse.fromJson(response.data!).patterns;
}
