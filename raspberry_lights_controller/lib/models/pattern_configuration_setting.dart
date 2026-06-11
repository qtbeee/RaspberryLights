import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pattern_configuration_setting.g.dart';

@JsonSerializable()
@immutable
class PatternConfigurationSetting {
  final String name;
  final dynamic value;

  const PatternConfigurationSetting({required this.name, required this.value});

  factory PatternConfigurationSetting.fromJson(Map<String, dynamic> json) =>
      _$PatternConfigurationSettingFromJson(json);

  Map<String, dynamic> toJson() => _$PatternConfigurationSettingToJson(this);

  @override
  bool operator ==(Object other) {
    return super == other ||
        (other is PatternConfigurationSetting &&
            name == other.name &&
            value == other.value);
  }

  @override
  int get hashCode => Object.hashAll([name, value]);
}
