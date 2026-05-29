import 'package:json_annotation/json_annotation.dart';

part 'pattern_configuration.g.dart';

@JsonSerializable(createToJson: false)
class RGBColor {
  final int red;
  final int green;
  final int blue;

  const RGBColor({required this.red, required this.green, required this.blue});

  factory RGBColor.fromJson(Map<String, dynamic> json) =>
      _$RGBColorFromJson(json);
}

@JsonSerializable(createToJson: false)
class PatternConfigurationSetting {
  final String name;
  final dynamic value;
  final bool? isPercent;

  const PatternConfigurationSetting({
    required this.name,
    required this.value,
    required this.isPercent,
  });

  factory PatternConfigurationSetting.fromJson(Map<String, dynamic> json) =>
      _$PatternConfigurationSettingFromJson(json);
}

@JsonSerializable(createToJson: false)
class PatternConfiguration {
  final String name;
  final int? animationSpeed;
  final int brightness;
  final List<RGBColor>? colors;
  final List<PatternConfigurationSetting> additionalSettings;

  PatternConfiguration({
    required this.name,
    required this.animationSpeed,
    required this.brightness,
    required this.colors,
    required this.additionalSettings,
  });

  factory PatternConfiguration.fromJson(Map<String, dynamic> json) =>
      _$PatternConfigurationFromJson(json);
}
