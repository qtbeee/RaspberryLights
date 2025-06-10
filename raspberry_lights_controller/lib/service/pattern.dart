import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/providers/network.dart';
import 'package:raspberry_lights_controller/providers/pattern.dart';
import 'package:raspberry_lights_controller/utils/color.dart';

void setLightPattern(WidgetRef ref) {
  final selectedPattern = ref.read(selectedPatternProvider);
  final selectedColors = ref.read(patternColorsProvider);
  final brightness = ref.read(patternBrightnessProvider);
  final client = ref.read(networkClientProvider);

  if (selectedPattern == null) {
    return;
  }
  final data = {
    "pattern": selectedPattern.pattern,
    "colors": selectedPattern.canChooseColor
        ? selectedColors.map((c) => c.toHexString()).toList()
        : null,
    "animationSpeed": selectedPattern.animationSpeeds > 1
        ? ref.read(animationSpeedProvider) - 1
        : null,
    "brightness": brightness,
  };

  client.post(
    "pattern",
    data: data,
    options: Options(contentType: ContentType.json.toString()),
  );
}
