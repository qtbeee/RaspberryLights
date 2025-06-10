import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/screens/color_picker.dart';
import 'package:raspberry_lights_controller/screens/palette_picker.dart';
import 'package:raspberry_lights_controller/widgets/color_tile.dart';
import 'package:raspberry_lights_controller/models/pattern_info.dart';
import 'package:raspberry_lights_controller/providers/pattern.dart';
import 'package:raspberry_lights_controller/service/pattern.dart';
import 'package:recase/recase.dart';

class PatternForm extends ConsumerWidget {
  const PatternForm({super.key, required this.data});

  final List<PatternInfo> data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPattern = ref.watch(selectedPatternProvider);
    final animationSpeed = ref.watch(animationSpeedProvider);
    final selectedColors = ref.watch(patternColorsProvider);
    final brightness = ref.watch(patternBrightnessProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: DropdownButton<PatternInfo>(
            hint: const Text("Select a pattern"),
            value: selectedPattern,
            onChanged: (newValue) {
              ref.read(animationSpeedProvider.notifier).reset();
              ref.read(selectedPatternProvider.notifier).setPattern(newValue);
            },
            isExpanded: true,
            underline: Container(
              height: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
            items: data
                .map(
                  (info) => DropdownMenuItem(
                    value: info,
                    child: Text(info.pattern.titleCase),
                  ),
                )
                .toList(),
          ),
        ),
        if (selectedPattern != null && selectedPattern.animationSpeeds > 1) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Speed:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Slider(
                  min: 1,
                  max: selectedPattern.animationSpeeds.toDouble(),
                  label: '$animationSpeed',
                  value: animationSpeed.toDouble(),
                  divisions: selectedPattern.animationSpeeds - 1,
                  onChanged: (value) {
                    ref
                        .read(animationSpeedProvider.notifier)
                        .setSpeed(value.toInt());
                  },
                ),
                const Row(children: [Text('Slower'), Spacer(), Text('Faster')]),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (selectedPattern != null) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Brightness:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Slider(
                  min: 0.1,
                  max: 1,
                  label: '${(brightness * 100).toInt()}%',
                  value: brightness,
                  divisions: 9,
                  onChanged: (value) {
                    ref
                        .read(patternBrightnessProvider.notifier)
                        .setBrightness(value);
                  },
                ),
                const Row(children: [Text('10%'), Spacer(), Text('100%')]),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (selectedPattern?.canChooseColor ?? false) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              children: [
                const Text(
                  'Colors:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        openPalettePicker(context);
                      },
                      child: const Text('Set from Palette'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        openColorPicker(context, ref);
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.palette),
                          Icon(Icons.add, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemBuilder: (context, index) {
                return ColorTile(
                  key: ValueKey('${selectedColors[index]} $index'),
                  color: selectedColors[index],
                  onTap: () {
                    openColorPicker(context, ref, index: index);
                  },
                  onDelete: selectedColors.length > 1
                      ? () {
                          ref
                              .read(patternColorsProvider.notifier)
                              .removeColor(index: index);
                        }
                      : null,
                );
              },
              itemCount: selectedColors.length,
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(patternColorsProvider.notifier)
                    .moveColor(oldIndex: oldIndex, newIndex: newIndex);
              },
            ),
          ),
        ] else
          const Spacer(),
        Padding(
          padding: const EdgeInsets.only(
            top: 8,
            left: 16,
            right: 16,
            bottom: 20,
          ),
          child: ElevatedButton(
            onPressed: selectedPattern != null
                ? () => setLightPattern(ref)
                : null,
            child: const Text("Set Pattern"),
          ),
        ),
      ],
    );
  }
}
