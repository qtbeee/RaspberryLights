import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raspberry_lights_controller/utils/color.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
    (_) async => await SharedPreferences.getInstance());

final savedColorsProvider =
    StateNotifierProvider<SavedColorsNotifier, List<Color>>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider).maybeWhen(
        data: (data) => data,
        orElse: () => null,
      );
  return SavedColorsNotifier(preferences);
});

class SavedColorsNotifier extends StateNotifier<List<Color>> {
  SavedColorsNotifier(this.preferences)
      : super(_preferencesToColorList(preferences));

  static const String savedColorKey = "savedColors";
  SharedPreferences? preferences;

  static List<Color> _preferencesToColorList(SharedPreferences? preferences) =>
      preferences
          ?.getStringList(savedColorKey)
          ?.map((item) => LedColor.fromShortHex(item))
          .toList() ??
      [];

  List<String> _stateToStringList() =>
      state.map((color) => color.toHexString()).toList();

  void saveColor(Color color) async {
    if (!state.contains(color)) {
      state = [...state, color];
    }
    await preferences?.setStringList(savedColorKey, _stateToStringList());
  }

  void removeSavedColor(Color color) async {
    final newState = state.toList()..remove(color);
    state = newState;
    await preferences?.setStringList(savedColorKey, _stateToStringList());
  }
}
