import 'package:json_annotation/json_annotation.dart';

part 'pattern_setting.g.dart';

PatternSetting patternSettingFromJson(Map<String, dynamic> json) {
  if (json['options'] != null) {
    return MultipleChoiceSetting.fromJson(json);
  } else if (json['min'] != null) {
    return NumberSetting.fromJson(json);
  } else {
    return BooleanSetting.fromJson(json);
  }
}

sealed class PatternSetting {
  final String name;
  final String? description;

  const PatternSetting({
    required this.name,
    required this.description,
  });
}

@JsonSerializable(createToJson: false)
class MultipleChoiceSetting extends PatternSetting {
  final List<String> options;
  final int defaultValue;

  const MultipleChoiceSetting({
    required super.name,
    required super.description,
    required this.options,
    required this.defaultValue,
  });

  factory MultipleChoiceSetting.fromJson(Map<String, dynamic> json) =>
      _$MultipleChoiceSettingFromJson(json);
}

@JsonSerializable(createToJson: false)
class NumberSetting extends PatternSetting {
  final int min;
  final int max;
  final bool isPercent;
  final int defaultValue;

  const NumberSetting({
    required super.name,
    required super.description,
    required this.min,
    required this.max,
    required this.isPercent,
    required this.defaultValue,
  });

  factory NumberSetting.fromJson(Map<String, dynamic> json) =>
      _$NumberSettingFromJson(json);
}

@JsonSerializable(createToJson: false)
class BooleanSetting extends PatternSetting {
  final bool defaultValue;

  const BooleanSetting({
    required super.name,
    required super.description,
    required this.defaultValue,
  });

  factory BooleanSetting.fromJson(Map<String, dynamic> json) =>
      _$BooleanSettingFromJson(json);
}
