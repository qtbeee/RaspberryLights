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

  var response = await client.get('patterns');
  return List.from(
    response.data['patterns'],
  ).map((v) => PatternInfo.fromJson(v)).toList();
}
