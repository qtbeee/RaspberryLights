import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/models/pattern_configuration.dart';
import 'package:raspberry_lights_controller/providers/current_pattern.dart';
import 'package:raspberry_lights_controller/providers/network.dart';
import 'package:raspberry_lights_controller/providers/pattern_list.dart';
import 'package:raspberry_lights_controller/utils/color.dart';

Future<void> setLightPattern(
  WidgetRef ref,
  PatternConfiguration patternConfiguration,
) async {
  final client = ref.read(networkClientProvider);
  final patternList = ref.read(patternListProvider).requireValue;
  final selectedPattern = patternList.firstWhere(
    (p) => p.patternId == patternConfiguration.patternId,
  );

  final data = {
    'patternId': patternConfiguration.patternId,
    'colors': selectedPattern.canChooseColor
        ? patternConfiguration.colors?.map((c) => c.toHexString()).toList()
        : null,
    'animationSpeed': selectedPattern.animationSpeeds > 1
        ? patternConfiguration.animationSpeed
        : null,
    'brightness': patternConfiguration.brightness,
    'additionalSettings': selectedPattern.additionalSettings.isNotEmpty
        ? patternConfiguration.additionalSettings
              .map(
                (setting) => PatternConfigurationSetting(
                  name: setting.name,
                  value: setting.value,
                ),
              )
              .toList()
        : <PatternConfiguration>[],
  };

  await client.post<void>(
    'pattern',
    data: data,
    options: Options(contentType: ContentType.json.toString()),
  );
  ref.invalidate(currentPatternProvider);
}
