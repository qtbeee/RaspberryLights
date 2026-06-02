import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/models/pattern_configuration.dart';
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
    holdoverColors = currentPatternConfig.colors ?? [Color(0xFF942cff)];
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SummaryCard(
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Text('Pattern', style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text(selectedPattern.name),
                PopupMenuButton(
                  position: PopupMenuPosition.under,
                  onSelected: onChangeSelectedPattern,
                  icon: Icon(Icons.edit),
                  itemBuilder: (context) {
                    return patternList.map((p) {
                      final (patternId, name, desc) = (
                        p.patternId,
                        p.name,
                        p.description,
                      );
                      return PopupMenuItem(
                        value: patternId,
                        child: Row(
                          children: [
                            Text(name),
                            Spacer(),
                            if (patternId == patternConfiguration.patternId)
                              Icon(Icons.check),
                          ],
                        ),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          ),
        ),
        SummaryCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                alignment: AlignmentDirectional.centerEnd,
                children: [
                  Center(
                    child: Text(
                      'Main Settings',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
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
                    icon: Icon(Icons.edit),
                  ),
                ],
              ),
              BrightnessEntry(brightness: patternConfiguration.brightness),
              if (patternConfiguration.animationSpeed != null)
                AnimationSpeedEntry(
                  animationSpeed: patternConfiguration.animationSpeed!,
                ),
              for (final setting in patternConfiguration.additionalSettings)
                AdditionalSettingEntry(
                  name: setting.name,
                  value: setting.value,
                  patternSettingInfo: selectedPattern.additionalSettings
                      .firstWhere((s) => s.name == setting.name),
                ),
              SizedBox(height: 16),
            ],
          ),
        ),
        if (patternConfiguration.colors != null)
          SummaryCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  alignment: AlignmentDirectional.centerEnd,
                  children: [
                    Center(
                      child: Text(
                        'Colors',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
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
                      icon: Icon(Icons.edit),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    direction: Axis.horizontal,
                    runSpacing: 8,
                    spacing: 8,
                    children: [
                      ...patternConfiguration.colors!.map(
                        (color) => ColorSquare(onTap: null, color: color),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        Spacer(),
        SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: AnimatedSlide(
              duration: Duration(milliseconds: 500),
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
                      label: Text('Save Changes'),
                      icon: Icon(Icons.check),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: hasChanges
                          ? () => setState(() {
                              patternConfiguration = currentPattern;
                            })
                          : null,
                      icon: Icon(Icons.undo),
                      label: Text('Clear Changes'),
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
    PatternConfiguration newConfiguration = PatternConfiguration.colorBased(
      patternId: newPatternId,
      animationSpeed: newSelectedPattern.animationSpeeds > 1 ? 0 : null,
      brightness: 100,
      colors: newSelectedPattern.canChooseColor
          ? patternConfiguration.colors ?? holdoverColors
          : null,
      additionalSettings: newSelectedPattern.additionalSettings
          .map(
            (s) => PatternConfigurationSetting(name: s.name, value: s.min ?? 0),
          )
          .toList(),
    );

    setState(() {
      patternConfiguration = newConfiguration;
    });
  }
}

class SummaryCard extends StatelessWidget {
  final Widget child;

  const SummaryCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
      child: Card(child: child),
    );
  }
}

class SummaryEntry extends StatelessWidget {
  final String title;
  final String value;

  const SummaryEntry({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

class BrightnessEntry extends StatelessWidget {
  final int brightness;

  const BrightnessEntry({super.key, required this.brightness});

  @override
  Widget build(BuildContext context) {
    return SummaryEntry(title: 'Brightness', value: '$brightness%');
  }
}

class AnimationSpeedEntry extends StatelessWidget {
  final int animationSpeed;

  const AnimationSpeedEntry({super.key, required this.animationSpeed});

  @override
  Widget build(BuildContext context) {
    // Shifting from 0-indexed to 1-indexed here because 0 implies no movement
    final value = animationSpeed + 1;

    return SummaryEntry(title: 'Animation Speed', value: '$value');
  }
}

class AdditionalSettingEntry extends StatelessWidget {
  final String name;
  final int value;
  final PatternSetting patternSettingInfo;

  const AdditionalSettingEntry({
    super.key,
    required this.name,
    required this.value,
    required this.patternSettingInfo,
  });

  @override
  Widget build(BuildContext context) {
    final String valueText;

    if (patternSettingInfo.settingType == 'Number') {
      valueText = patternSettingInfo.isPercent ? '$value%' : value.toString();
    } else {
      valueText = patternSettingInfo.options![value];
    }

    return SummaryEntry(title: name, value: valueText);
  }
}
