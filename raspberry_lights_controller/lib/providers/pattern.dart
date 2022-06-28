import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/pattern_info.dart';
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

final colorsProvider =
    StateNotifierProvider<ColorsNotifier, List<Color>>((ref) {
  return ColorsNotifier();
});

class ColorsNotifier extends StateNotifier<List<Color>> {
  ColorsNotifier() : super([Colors.white]);

  void reset() {
    state = [Colors.white];
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
