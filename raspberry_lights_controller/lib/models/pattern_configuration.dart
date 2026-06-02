import 'dart:ui';

import 'package:flutter/foundation.dart';
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

@JsonSerializable()
class PatternConfigurationSetting {
  final String name;
  final int value;

  const PatternConfigurationSetting({required this.name, required this.value});

  factory PatternConfigurationSetting.fromJson(Map<String, dynamic> json) =>
      _$PatternConfigurationSettingFromJson(json);

  Map<String, dynamic> toJson() => _$PatternConfigurationSettingToJson(this);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PatternConfigurationSetting &&
            name == other.name &&
            value == other.value);
  }

  @override
  int get hashCode => Object.hashAll([name, value]);

  @override
  String toString() {
    return "{ name: $name, value: $value }";
  }
}

@JsonSerializable(createToJson: false)
class PatternConfiguration {
  final String patternId;
  final int? animationSpeed;
  final int brightness;
  final List<Color>? colors;
  final List<PatternConfigurationSetting> additionalSettings;

  PatternConfiguration({
    required this.patternId,
    required this.animationSpeed,
    required this.brightness,
    required List<RGBColor>? colors,
    required this.additionalSettings,
  }) : colors = colors
           ?.map((c) => Color.fromRGBO(c.red, c.green, c.blue, 1))
           .toList();

  PatternConfiguration.colorBased({
    required this.patternId,
    required this.animationSpeed,
    required this.brightness,
    required this.colors,
    required this.additionalSettings,
  });

  PatternConfiguration copyWith({
    final int? animationSpeed,
    final int? brightness,
    final List<Color>? colors,
    final List<PatternConfigurationSetting>? additionalSettings,
  }) {
    return PatternConfiguration.colorBased(
      patternId: patternId,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      brightness: brightness ?? this.brightness,
      colors: colors ?? this.colors,
      additionalSettings: additionalSettings ?? this.additionalSettings,
    );
  }

  factory PatternConfiguration.fromJson(Map<String, dynamic> json) =>
      _$PatternConfigurationFromJson(json);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PatternConfiguration &&
            patternId == other.patternId &&
            animationSpeed == other.animationSpeed &&
            brightness == other.brightness &&
            listEquals(colors, other.colors) &&
            listEquals(additionalSettings, other.additionalSettings));
  }

  @override
  int get hashCode => Object.hashAll([
    patternId,
    animationSpeed,
    brightness,
    ...?colors,
    ...additionalSettings,
  ]);

  @override
  String toString() {
    return """
{
patternId: $patternId,
animationSpeed: $animationSpeed,
brightness: $brightness,
colors: $colors,
additionalSettings: $additionalSettings,
}
""";
  }
}
