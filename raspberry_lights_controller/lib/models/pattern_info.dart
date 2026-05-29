import 'package:json_annotation/json_annotation.dart';
import 'package:raspberry_lights_controller/models/pattern_setting.dart';

part 'pattern_info.g.dart';

@JsonSerializable()
class PatternInfo {
  final String pattern;
  final String description;
  final bool canChooseColor;
  final int animationSpeeds;
  final List<PatternSetting> additionalSettings;

  PatternInfo({
    required this.pattern,
    required this.description,
    required this.canChooseColor,
    required this.animationSpeeds,
    this.additionalSettings = const [],
  });

  factory PatternInfo.fromJson(Map<String, dynamic> json) =>
      _$PatternInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PatternInfoToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatternInfo &&
          runtimeType == other.runtimeType &&
          pattern == other.pattern;

  @override
  int get hashCode => pattern.hashCode;

  @override
  String toString() {
    return """{
      name: $pattern,
      description: $description,
      canChooseColor: $canChooseColor,
      animationSpeeds: $animationSpeeds,
      additionalSettings: $additionalSettings,
    }""";
  }
}
