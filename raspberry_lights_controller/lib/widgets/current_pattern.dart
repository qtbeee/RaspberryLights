import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/providers/current_pattern.dart';
import 'package:raspberry_lights_controller/providers/pattern_list.dart';
import 'package:raspberry_lights_controller/widgets/color_square.dart';
import 'package:recase/recase.dart';

class CurrentPattern extends ConsumerWidget {
  const CurrentPattern({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patternConfiguration = ref.watch(currentPatternProvider).requireValue;
    final patternList = ref.watch(patternListProvider).requireValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SummaryCard(
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Text("Pattern", style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text(patternConfiguration.name.titleCase),
                IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
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
                      "Main Settings",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
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
                  isPercent: setting.isPercent ?? false,
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
                        "Colors",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
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
                        (color) => ColorSquare(
                          onTap: null,
                          color: Color.fromARGB(
                            255,
                            color.red,
                            color.green,
                            color.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
      ],
    );
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
    return SummaryEntry(title: "Brightness", value: "$brightness%");
  }
}

class AnimationSpeedEntry extends StatelessWidget {
  final int animationSpeed;

  const AnimationSpeedEntry({super.key, required this.animationSpeed});

  @override
  Widget build(BuildContext context) {
    // Shifting from 0-indexed to 1-indexed here because 0 implies no movement
    final value = animationSpeed + 1;

    return SummaryEntry(title: "Animation Speed", value: "$value");
  }
}

class AdditionalSettingEntry extends StatelessWidget {
  final String name;
  final dynamic value;
  final bool isPercent;

  const AdditionalSettingEntry({
    super.key,
    required this.name,
    required this.value,
    required this.isPercent,
  });

  @override
  Widget build(BuildContext context) {
    final valueText = isPercent ? "$value%" : value.toString();

    return SummaryEntry(title: name, value: valueText);
  }
}
