import 'package:flutter/material.dart';
import 'package:raspberry_lights_controller/models/pattern_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pattern.g.dart';

@riverpod
class SelectedPattern extends _$SelectedPattern {
  static const defaultPattern = null;

  @override
  PatternInfo? build() => defaultPattern;

  void setPattern(PatternInfo? pattern) => state = pattern;
  void reset() => setPattern(defaultPattern);
}

@riverpod
class AnimationSpeed extends _$AnimationSpeed {
  static const defaultSpeed = 1;

  @override
  int build() => defaultSpeed;

  void setSpeed(int speed) => state = speed;
  void reset() => setSpeed(defaultSpeed);
}

@riverpod
class PatternBrightness extends _$PatternBrightness {
  static const defaultBrightness = 1.0;

  @override
  double build() => defaultBrightness;

  void setBrightness(double brightness) =>
      state = brightness.clamp(0.1, 1).toDouble();

  void reset() => setBrightness(defaultBrightness);
}

@riverpod
class PatternColors extends _$PatternColors {
  static const defaultColors = [Color(0xFF942cff)];

  @override
  List<Color> build() => defaultColors;

  void setColor({required Color color, required int index}) {
    final newColors = [...super.state];
    newColors[index] = color;

    state = newColors;
  }

  void setColors(List<Color> colors) {
    state = [...colors];
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

  void reset() => setColors(defaultColors);
}
