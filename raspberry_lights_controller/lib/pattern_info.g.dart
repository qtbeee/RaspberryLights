// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatternInfo _$PatternInfoFromJson(Map<String, dynamic> json) {
  return PatternInfo(
    pattern: json['pattern'] as String,
    canChooseColor: json['canChooseColor'] as bool,
    animationSpeeds: json['animationSpeeds'] as int,
  );
}

Map<String, dynamic> _$PatternInfoToJson(PatternInfo instance) =>
    <String, dynamic>{
      'pattern': instance.pattern,
      'canChooseColor': instance.canChooseColor,
      'animationSpeeds': instance.animationSpeeds,
    };
