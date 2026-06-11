import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:raspberry_lights_controller/models/pattern_setting.dart';

part 'pattern_info.g.dart';

@JsonSerializable(createToJson: false)
@immutable
class PatternInfo {
  final String patternId;
  final String name;
  final String description;
  final bool canChooseColor;
  final int animationSpeeds;
  @JsonKey(fromJson: _patternSettingsFromJson)
  final List<PatternSetting> additionalSettings;

  const PatternInfo({
    required this.patternId,
    required this.name,
    required this.description,
    required this.canChooseColor,
    required this.animationSpeeds,
    this.additionalSettings = const [],
  });

  factory PatternInfo.fromJson(Map<String, dynamic> json) =>
      _$PatternInfoFromJson(json);

  static List<PatternSetting> _patternSettingsFromJson(
    List<dynamic> json,
  ) => [
    for (final s in json) patternSettingFromJson(s as Map<String, dynamic>),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PatternInfo &&
          runtimeType == other.runtimeType &&
          patternId == other.patternId);

  @override
  int get hashCode => patternId.hashCode;

  @override
  String toString() {
    return '''
{
      patternId: $patternId,
      name: $name,
      description: $description,
      canChooseColor: $canChooseColor,
      animationSpeeds: $animationSpeeds,
      additionalSettings: $additionalSettings,
}''';
  }
}
