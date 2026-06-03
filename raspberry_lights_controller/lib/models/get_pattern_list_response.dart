import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:raspberry_lights_controller/models/pattern_info.dart';

part 'get_pattern_list_response.g.dart';

@JsonSerializable(createToJson: false)
@immutable
class GetPatternListResponse {
  final List<PatternInfo> patterns;

  const GetPatternListResponse({
    required this.patterns,
  });

  factory GetPatternListResponse.fromJson(Map<String, dynamic> json) =>
      _$GetPatternListResponseFromJson(json);
}
