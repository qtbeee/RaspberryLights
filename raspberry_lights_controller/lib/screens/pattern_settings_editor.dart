import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/models/pattern_configuration_setting.dart';
import 'package:raspberry_lights_controller/models/pattern_info.dart';
import 'package:raspberry_lights_controller/models/pattern_setting.dart';

Future<
  ({
    int brightness,
    int? animationSpeed,
    List<PatternConfigurationSetting> additionalSettings,
  })?
>
openPatternSettingsEditor(
  BuildContext context, {
  required int brightness,
  required int? animationSpeed,
  required List<PatternConfigurationSetting> additionalSettings,
  required PatternInfo patternInfo,
}) async {
  return Navigator.of(context).push<
    ({
      int brightness,
      int? animationSpeed,
      List<PatternConfigurationSetting> additionalSettings,
    })?
  >(
    MaterialPageRoute(
      builder: (context) => PatternSettingsEditor(
        animationSpeed: animationSpeed,
        brightness: brightness,
        additionalSettings: additionalSettings,
        patternInfo: patternInfo,
      ),
    ),
  );
}

class PatternSettingsEditor extends ConsumerStatefulWidget {
  final int? animationSpeed;
  final int brightness;
  final List<PatternConfigurationSetting> additionalSettings;
  final PatternInfo patternInfo;

  const PatternSettingsEditor({
    required this.animationSpeed,
    required this.brightness,
    required this.additionalSettings,
    required this.patternInfo,
    super.key,
  });

  @override
  ConsumerState<PatternSettingsEditor> createState() =>
      _PatternSettingsEditorState();
}

class _PatternSettingsEditorState extends ConsumerState<PatternSettingsEditor> {
  late int? animationSpeed = widget.animationSpeed;
  late int brightness = widget.brightness;
  late List<PatternConfigurationSetting> additionalSettings =
      widget.additionalSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop<
                ({
                  int brightness,
                  int? animationSpeed,
                  List<PatternConfigurationSetting> additionalSettings,
                })?
              >((
                animationSpeed: animationSpeed,
                brightness: brightness,
                additionalSettings: additionalSettings,
              ));
            },
            icon: const Icon(Icons.check),
          ),
        ],
        title: const Text('Edit Pattern Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const .symmetric(horizontal: 16),
          child: Column(
            spacing: 4,
            children: [
              _BrightnessSlider(
                value: brightness,
                onChanged: onBrightnessChanged,
              ),
              if (animationSpeed != null)
                _AnimationSpeedSlider(
                  value: animationSpeed!,
                  speedCount: widget.patternInfo.animationSpeeds,
                  onChanged: onAnimationSpeedChanged,
                ),
              ...additionalSettings.map((setting) {
                final settingInfo = widget.patternInfo.additionalSettings
                    .firstWhere((s) => s.name == setting.name);

                switch (settingInfo) {
                  case MultipleChoiceSetting():
                    return _DropdownSetting(
                      name: setting.name,
                      value: setting.value as int,
                      options: settingInfo.options,
                      onChanged: makeOnChanged(setting.name),
                      description: settingInfo.description,
                    );
                  case NumberSetting():
                    return _SliderSetting(
                      name: setting.name,
                      value: setting.value as int,
                      min: settingInfo.min,
                      max: settingInfo.max,
                      isPercent: settingInfo.isPercent,
                      onChanged: makeOnChanged(setting.name),
                      description: settingInfo.description,
                      stepSize: settingInfo.stepSize,
                    );
                  case BooleanSetting():
                    return _ToggleSetting(
                      name: setting.name,
                      value: setting.value as bool,
                      description: settingInfo.description,
                      onChanged: makeOnChanged(setting.name),
                    );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  void onBrightnessChanged(int newValue) {
    setState(() => brightness = newValue);
  }

  void onAnimationSpeedChanged(int newValue) {
    setState(() => animationSpeed = newValue);
  }

  void Function(dynamic newValue) makeOnChanged(String settingName) {
    return (newValue) {
      final newSettings = [...additionalSettings];
      final index = newSettings.indexWhere((s) => s.name == settingName);
      newSettings[index] = PatternConfigurationSetting(
        name: settingName,
        value: newValue,
      );
      setState(() => additionalSettings = newSettings);
    };
  }
}

class _DropdownSetting extends StatelessWidget {
  final String name;
  final int value;
  final String? description;
  final List<String> options;
  final void Function(int newValue) onChanged;

  const _DropdownSetting({
    required this.name,
    required this.value,
    required this.options,
    required this.onChanged,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const .symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Row(
              children: [
                Text(name, style: const TextStyle(fontWeight: .bold)),
                if (description != null) _Description(description: description),
                const Spacer(),
              ],
            ),
            DropdownMenu(
              dropdownMenuEntries: options.indexed
                  .map(
                    (a) => DropdownMenuEntry(
                      value: a.$1,
                      label: a.$2,
                      trailingIcon: value == a.$1
                          ? const Icon(Icons.check)
                          : null,
                    ),
                  )
                  .toList(),
              initialSelection: value,
              onSelected: (choice) {
                if (choice != null) {
                  onChanged(choice);
                }
              },
              expandedInsets: .zero,
              inputDecorationTheme: const InputDecorationTheme(
                isCollapsed: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderSetting extends StatelessWidget {
  final String name;
  final int value;
  final int min;
  final int max;
  final String? description;

  final bool isPercent;
  final String? minLabel;
  final String? maxLabel;
  final bool showLabel;
  final int? stepSize;

  final void Function(int newValue) onChanged;

  const _SliderSetting({
    required this.name,
    required this.value,
    required this.min,
    required this.max,
    required this.isPercent,
    required this.onChanged,
    this.description,
    this.minLabel,
    this.maxLabel,
    this.showLabel = true,
    this.stepSize,
  });

  @override
  Widget build(BuildContext context) {
    final label = showLabel ? (isPercent ? '$value%' : '$value') : null;
    final minLabel = this.minLabel ?? (isPercent ? '$min%' : '$min');
    final maxLabel = this.maxLabel ?? (isPercent ? '$max%' : '$max');
    final divisions = (max - min) ~/ (stepSize ?? 1);

    return Card(
      child: Padding(
        padding: const .symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Row(
              children: [
                Text(name, style: const TextStyle(fontWeight: .bold)),
                if (description != null) _Description(description: description),
                const Spacer(),
              ],
            ),
            Column(
              children: [
                Slider(
                  min: min.toDouble(),
                  max: max.toDouble(),
                  label: label,
                  value: value.toDouble(),
                  divisions: divisions,
                  onChanged: (value) => onChanged(value.toInt()),
                ),
                Row(children: [Text(minLabel), const Spacer(), Text(maxLabel)]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleSetting extends StatelessWidget {
  final String name;
  final bool value;
  final String? description;
  final ValueChanged<bool> onChanged;

  const _ToggleSetting({
    required this.name,
    required this.value,
    required this.onChanged,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const .symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Row(
              children: [
                Text(name, style: const TextStyle(fontWeight: .bold)),
                if (description != null) _Description(description: description),
                const Spacer(),
                Switch(value: value, onChanged: onChanged),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimationSpeedSlider extends StatelessWidget {
  final int value;
  final int speedCount;
  final void Function(int newValue) onChanged;

  const _AnimationSpeedSlider({
    required this.value,
    required this.speedCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SliderSetting(
      name: 'Animation Speed',
      value: value,
      min: 0,
      max: speedCount - 1,
      isPercent: false,
      onChanged: onChanged,
      minLabel: 'Slower',
      maxLabel: 'Faster',
      showLabel: false,
    );
  }
}

class _BrightnessSlider extends StatelessWidget {
  final int value;
  final void Function(int newValue) onChanged;

  const _BrightnessSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _SliderSetting(
      name: 'Brightness',
      value: value,
      min: 10,
      max: 100,
      isPercent: true,
      onChanged: onChanged,
      stepSize: 10,
    );
  }
}

class _Description extends StatelessWidget {
  final String? description;

  const _Description({
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Tooltip(
        showDuration: const .new(seconds: 30),
        message: description,
        triggerMode: .tap,
        child: const Icon(
          Icons.help_outline,
          size: 20,
        ),
      ),
    );
  }
}
