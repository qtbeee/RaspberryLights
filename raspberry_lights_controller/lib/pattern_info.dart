import 'package:json_annotation/json_annotation.dart';

part 'pattern_info.g.dart';

@JsonSerializable()
class PatternInfo {
  final String pattern;
  final bool canChooseColor;

  PatternInfo({this.pattern, this.canChooseColor});

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
}
