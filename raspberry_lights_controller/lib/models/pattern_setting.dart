import 'package:json_annotation/json_annotation.dart';

part 'pattern_setting.g.dart';

@JsonSerializable()
class PatternSetting {
  final String name;
  final String? description;

  final int? min;
  final int? max;
  final bool isPercent;
  final List<String>? options;

  PatternSetting({
    required this.name,
    required this.description,
    this.min,
    this.max,
    this.isPercent = false,
    this.options,
  });

  factory PatternSetting.fromJson(Map<String, dynamic> json) =>
      _$PatternSettingFromJson(json);

  Map<String, dynamic> toJson() => _$PatternSettingToJson(this);

  String get settingType =>
      min != null && max != null ? "Number" : "Multiple Choice";

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PatternSetting && name == other.name);

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() =>
      "{ name: $name, description: $description, isPercent: $isPercent, type: $settingType }";
}
