import 'package:flutter/material.dart';

class HSVColorSlider extends StatefulWidget {
  const HSVColorSlider({
    super.key,
    required this.onColorChanged,
    required this.color,
  });

  final ValueChanged<HSVColor> onColorChanged;
  final HSVColor color;

  @override
  HSVColorSliderState createState() => HSVColorSliderState();
}

class HSVColorSliderState extends State<HSVColorSlider> {
  double hue = 0;
  double saturation = 1;

  @override
  void initState() {
    super.initState();

    setComponentsFromColor(widget.color);
  }

  @override
  void didUpdateWidget(covariant HSVColorSlider oldWidget) {
    if (widget.color != oldWidget.color) {
      setComponentsFromColor(widget.color);
    }

    super.didUpdateWidget(oldWidget);
  }

  void setComponentsFromColor(HSVColor color) {
    hue = color.hue;
    saturation = color.saturation;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GradientSlider(
          value: hue,
          min: 0,
          max: 360,
          thumbColor: HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF0000),
              Color(0xFFFFFF00),
              Color(0xFF00FF00),
              Color(0xFF00FFFF),
              Color(0xFF0000FF),
              Color(0xFFFF00FF),
              Color(0xFFFF0000),
            ],
          ),
          onChanged: (newHue) {
            setState(() {
              hue = newHue;
            });
            widget.onColorChanged(
              HSVColor.fromAHSV(1, hue, saturation, 1),
            );
          },
        ),
        _GradientSlider(
          value: saturation,
          min: 0,
          max: 1,
          thumbColor: HSVColor.fromAHSV(1, hue, saturation, 1).toColor(),
          gradient: LinearGradient(
            colors: [
              HSVColor.fromAHSV(1, hue, 0, 1).toColor(),
              HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
            ],
          ),
          onChanged: (newSaturation) {
            setState(() {
              saturation = newSaturation;
            });
            widget.onColorChanged(
              HSVColor.fromAHSV(1, hue, saturation, 1),
            );
          },
        ),
      ],
    );
  }
}

class _GradientSlider extends StatelessWidget {
  const _GradientSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.thumbColor,
    required this.gradient,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final Color thumbColor;
  final Gradient gradient;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Slider does not take a gradient, so we will make our own to sit underneath it
        // And also hide the normal colors of the slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 21),
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: gradient,
            ),
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          thumbColor: thumbColor,
          activeColor: Colors.transparent,
          inactiveColor: Colors.transparent,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
