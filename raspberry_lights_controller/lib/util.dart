import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/providers/pattern.dart';

final client = Dio()..options.baseUrl = "http://192.168.0.199:5000/";

void setLightPattern(WidgetRef ref) {
  final selectedPattern = ref.read(selectedPatternProvider);
  final selectedColors = ref.read(colorsProvider);

  if (selectedPattern == null) {
    return;
  }

  final data = {
    "pattern": selectedPattern.pattern,
    "colors": selectedPattern.canChooseColor
        ? selectedColors
            .map((c) => colorToHex(
                  c,
                  includeHashSign: true,
                  enableAlpha: false,
                ))
            .toList()
        : null,
    "animationSpeed": selectedPattern.animationSpeeds > 1
        ? ref.read(animationSpeedProvider) - 1
        : null,
  };

  client.post("pattern",
      data: data, options: Options(contentType: ContentType.json.toString()));
}
