import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/models/pattern_info.dart';
import 'package:raspberry_lights_controller/util.dart';

final selectedPatternProvider = StateProvider<PatternInfo?>((ref) {
  return null;
});

final animationSpeedProvider =
    StateNotifierProvider<AnimationSpeedNotifier, int>((ref) {
  return AnimationSpeedNotifier();
});

class AnimationSpeedNotifier extends StateNotifier<int> {
  AnimationSpeedNotifier() : super(1);

  void setSpeed(int speed) {
    state = speed;
  }

  void reset() {
    state = 1;
  }
}

final brightnessProvider =
    StateNotifierProvider<BrightnessNotifier, double>((ref) {
  return BrightnessNotifier();
});

class BrightnessNotifier extends StateNotifier<double> {
  BrightnessNotifier() : super(1);

  void setBrightness(double brightness) {
    state = brightness.clamp(0.1, 1).toDouble();
  }

  void reset() {
    state = 1;
  }
}

final colorsProvider =
    StateNotifierProvider<ColorsNotifier, List<Color>>((ref) {
  return ColorsNotifier();
});

class ColorsNotifier extends StateNotifier<List<Color>> {
  ColorsNotifier() : super([defaultColor]);

  static const defaultColor = Color(0xFF942cff);

  void reset() {
    state = [defaultColor];
  }

  void setColor({required Color color, required int index}) {
    final newColors = [...state];
    newColors[index] = color;

    state = newColors;
  }

  void addColor({required Color color}) {
    state = [...state, color];
  }

  void moveColor({required int oldIndex, required int newIndex}) {
    final newColors = [...state];
    final movedColor = newColors.removeAt(oldIndex);
    final insertionIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    newColors.insert(insertionIndex, movedColor);

    state = newColors;
  }

  void removeColor({required int index}) {
    final updated = [...state..removeAt(index)];

    state = updated;
  }
}

final patternInfoProvider = FutureProvider((ref) async {
  var response = await client.get("pattern");
  return List.from(response.data['patterns'])
      .map((v) => PatternInfo.fromJson(v))
      .toList();
});
