import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/models/pattern_configuration.dart';
import 'package:raspberry_lights_controller/models/pattern_configuration_setting.dart';
import 'package:raspberry_lights_controller/models/pattern_setting.dart';
import 'package:raspberry_lights_controller/providers/current_pattern.dart';
import 'package:raspberry_lights_controller/providers/pattern_list.dart';
import 'package:raspberry_lights_controller/screens/colors_editor.dart';
import 'package:raspberry_lights_controller/screens/pattern_settings_editor.dart';
import 'package:raspberry_lights_controller/service/pattern.dart';
import 'package:raspberry_lights_controller/widgets/color_square.dart';

class CurrentPattern extends ConsumerStatefulWidget {
  const CurrentPattern({super.key});

  @override
  ConsumerState<CurrentPattern> createState() => _CurrentPatternState();
}

class _CurrentPatternState extends ConsumerState<CurrentPattern> {
  late PatternConfiguration patternConfiguration;
  late List<Color> holdoverColors;

  @override
  void initState() {
    super.initState();
    final currentPatternConfig = ref.read(currentPatternProvider).requireValue;
    patternConfiguration = currentPatternConfig;
    holdoverColors = currentPatternConfig.colors ?? [const Color(0xFF942cff)];
  }

  @override
  Widget build(BuildContext context) {
    final patternList = ref.watch(patternListProvider).requireValue;
    final selectedPattern = patternList.firstWhere(
      (p) => p.patternId == patternConfiguration.patternId,
    );
    final currentPattern = ref.watch(currentPatternProvider).requireValue;

    final hasChanges = patternConfiguration != currentPattern;

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        _SummaryCard(
          child: Padding(
            padding: const .only(left: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Row(
                  children: [
                    const Text(
                      'Pattern',
                      style: .new(fontWeight: .bold),
                    ),
                    const Spacer(),
                    Text(selectedPattern.name),
                    PopupMenuButton(
                      position: PopupMenuPosition.under,
                      onSelected: onChangeSelectedPattern,
                      icon: const Icon(Icons.edit),
                      itemBuilder: (context) {
                        return patternList.map((p) {
                          final (patternId, name) = (
                            p.patternId,
                            p.name,
                          );
                          return PopupMenuItem(
                            value: patternId,
                            child: Row(
                              children: [
                                Text(name),
                                const Spacer(),
                                if (patternId == patternConfiguration.patternId)
                                  const Icon(Icons.check),
                              ],
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    selectedPattern.description,
                    style: const .new(fontSize: 12),
                    textAlign: .start,
                  ),
                ),
              ],
            ),
          ),
        ),
        _SummaryCard(
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              Stack(
                alignment: .centerEnd,
                children: [
                  const Center(
                    child: Text(
                      'Main Settings',
                      style: TextStyle(fontWeight: .bold),
                      textAlign: .center,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final newSettings = await openPatternSettingsEditor(
                        context,
                        brightness: patternConfiguration.brightness,
                        animationSpeed: patternConfiguration.animationSpeed,
                        additionalSettings:
                            patternConfiguration.additionalSettings,
                        patternInfo: selectedPattern,
                      );
                      if (newSettings != null) {
                        setState(() {
                          patternConfiguration = patternConfiguration.copyWith(
                            brightness: newSettings.brightness,
                            animationSpeed: newSettings.animationSpeed,
                            additionalSettings: newSettings.additionalSettings,
                          );
                        });
                      }
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),
              _BrightnessEntry(brightness: patternConfiguration.brightness),
              if (patternConfiguration.animationSpeed != null)
                _AnimationSpeedEntry(
                  animationSpeed: patternConfiguration.animationSpeed!,
                ),
              for (final setting in patternConfiguration.additionalSettings)
                _AdditionalSettingEntry(
                  name: setting.name,
                  value: setting.value,
                  patternSettingInfo: selectedPattern.additionalSettings
                      .firstWhere((s) => s.name == setting.name),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        if (patternConfiguration.colors != null)
          _SummaryCard(
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Stack(
                  alignment: .centerEnd,
                  children: [
                    const Center(
                      child: Text(
                        'Colors',
                        style: TextStyle(fontWeight: .bold),
                        textAlign: .center,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final colors = await openColorsEditor(
                          context,
                          patternConfiguration.colors!,
                        );
                        if (colors != null) {
                          setState(() {
                            patternConfiguration = patternConfiguration
                                .copyWith(colors: colors);
                            holdoverColors = [...colors];
                          });
                        }
                      },
                      icon: const Icon(Icons.edit),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const .symmetric(horizontal: 16),
                  child: Wrap(
                    runSpacing: 8,
                    spacing: 8,
                    children: [
                      ...patternConfiguration.colors!.map(
                        (color) => ColorSquare(onTap: null, color: color),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        const Spacer(),
        SafeArea(
          child: Padding(
            padding: const .only(left: 16, right: 16),
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              offset: hasChanges
                  ? Offset.zero
                  : Offset.fromDirection(pi * 0.5, 2),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: hasChanges
                          ? () => setLightPattern(ref, patternConfiguration)
                          : null,
                      label: const Text('Save Changes'),
                      icon: const Icon(Icons.check),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: hasChanges
                          ? () => setState(() {
                              patternConfiguration = currentPattern;
                            })
                          : null,
                      icon: const Icon(Icons.undo),
                      label: const Text('Clear Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void onChangeSelectedPattern(String newPatternId) {
    final newSelectedPattern = ref
        .read(patternListProvider)
        .requireValue
        .firstWhere((p) => p.patternId == newPatternId);
    final newConfiguration = PatternConfiguration.colorBased(
      patternId: newPatternId,
      animationSpeed: newSelectedPattern.animationSpeeds > 1 ? 0 : null,
      brightness: 100,
      colors: newSelectedPattern.canChooseColor
          ? patternConfiguration.colors ?? holdoverColors
          : null,
      additionalSettings: newSelectedPattern.additionalSettings
          .map(
            (s) => switch (s) {
              MultipleChoiceSetting() => PatternConfigurationSetting(
                name: s.name,
                value: s.defaultValue,
              ),
              NumberSetting() => PatternConfigurationSetting(
                name: s.name,
                value: s.defaultValue,
              ),
              BooleanSetting() => PatternConfigurationSetting(
                name: s.name,
                value: s.defaultValue,
              ),
            },
          )
          .toList(),
    );

    setState(() {
      patternConfiguration = newConfiguration;
    });
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(left: 16, top: 8, right: 16),
      child: Card(child: child),
    );
  }
}

class _SummaryEntry extends StatelessWidget {
  const _SummaryEntry({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: .bold)),
          Text(value),
        ],
      ),
    );
  }
}

class _BrightnessEntry extends StatelessWidget {
  const _BrightnessEntry({required this.brightness});
  final int brightness;

  @override
  Widget build(BuildContext context) {
    return _SummaryEntry(title: 'Brightness', value: '$brightness%');
  }
}

class _AnimationSpeedEntry extends StatelessWidget {
  const _AnimationSpeedEntry({required this.animationSpeed});
  final int animationSpeed;

  @override
  Widget build(BuildContext context) {
    // Shifting from 0-indexed to 1-indexed here because 0 implies no movement
    final value = animationSpeed + 1;

    return _SummaryEntry(title: 'Animation Speed', value: '$value');
  }
}

class _AdditionalSettingEntry extends StatelessWidget {
  const _AdditionalSettingEntry({
    required this.name,
    required this.value,
    required this.patternSettingInfo,
  });

  final String name;
  final dynamic value;
  final PatternSetting patternSettingInfo;

  @override
  Widget build(BuildContext context) {
    final valueText = switch (patternSettingInfo) {
      MultipleChoiceSetting() =>
        (patternSettingInfo as MultipleChoiceSetting).options[value as int],
      NumberSetting() =>
        (patternSettingInfo as NumberSetting).isPercent
            ? '$value%'
            : value.toString(),
      BooleanSetting() => value as bool ? 'Yes' : 'No',
    };

    return _SummaryEntry(title: name, value: valueText);
  }
}
