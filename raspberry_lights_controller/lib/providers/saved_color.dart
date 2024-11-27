import 'dart:ui';

import 'package:raspberry_lights_controller/providers/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:raspberry_lights_controller/utils/color.dart';

part 'saved_color.g.dart';

@riverpod
class SavedColors extends _$SavedColors {
  static const String savedColorKey = "savedColors";

  @override
  List<Color> build() {
    final preferences = ref.watch(sharedPreferencesProvider).valueOrNull;
    return preferences
            ?.getStringList(savedColorKey)
            ?.map((item) => LedColor.fromShortHex(item))
            .toList() ??
        [];
  }

  List<String> _stateToStringList() =>
      state.map((color) => color.toHexString()).toList();

  void saveColor(Color color) async {
    if (!state.contains(color)) {
      state = [...state, color];
    }

    final preferences = ref.read(sharedPreferencesProvider).valueOrNull;
    await preferences?.setStringList(savedColorKey, _stateToStringList());
  }

  void removeSavedColor(Color color) async {
    final newState = state.toList()..remove(color);
    state = newState;

    final preferences = ref.read(sharedPreferencesProvider).valueOrNull;
    await preferences?.setStringList(savedColorKey, _stateToStringList());
  }
}
