import 'package:flutter/material.dart';

class PaletteList extends StatelessWidget {
  const PaletteList({
    super.key,
    this.onColorSelected,
    this.onPaletteSelected,
  }) : assert(onColorSelected != null || onPaletteSelected != null);

  final ValueChanged<Color>? onColorSelected;
  final ValueChanged<List<Color>>? onPaletteSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The raspberry pi doesn't like anything near white @ full brightness on the entire 50 led strip...
        // And I don't know enough about hardware to understand why.
        // Palette(
        //   onColorSelected: onColorSelected,
        //   title: "Color temperature",
        //   colors: const [
        //     Colors.white,
        //     Color.fromARGB(255, 255, 195, 83),
        //   ],
        // ),
        Palette(
          onColorSelected: onColorSelected,
          onPaletteSelected: onPaletteSelected,
          title: "Critmas",
          colors: const [
            Color(0xFFFF5aA0),
            Color(0xFFdda019),
            Color(0xff6ebee6),
            Color(0xffff4b32),
            Color(0xff3d9c17),
          ],
        ),
        Palette(
          onColorSelected: onColorSelected,
          onPaletteSelected: onPaletteSelected,
          title: "Pride Flag",
          colors: const [
            Color(0xFFE50000),
            Color(0xFFff8d00),
            Color(0xFFffee00),
            Color(0xFF028121),
            Color(0xFF004cff),
            Color(0xFF770088),
          ],
        ),
        Palette(
          onColorSelected: onColorSelected,
          onPaletteSelected: onPaletteSelected,
          title: "Trans Flag",
          colors: const [
            Color(0xFF74d7ec),
            Colors.white,
            Color(0xFFffafc7),
          ],
        ),
        Palette(
          onColorSelected: onColorSelected,
          onPaletteSelected: onPaletteSelected,
          title: "Bisexual Flag",
          colors: const [
            Color(0xFFd60270),
            Color(0xFF9b4f96),
            Color(0xFF0038a8),
          ],
        ),
        Palette(
          onColorSelected: onColorSelected,
          onPaletteSelected: onPaletteSelected,
          title: "Lesbian Flag",
          colors: const [
            Color(0xFFd62800),
            Color(0xFFff9b56),
            Colors.white,
            Color(0xFFd462a6),
            Color(0xFFa40062),
          ],
        ),
        Palette(
          onColorSelected: onColorSelected,
          onPaletteSelected: onPaletteSelected,
          title: "Gay Flag",
          colors: const [
            Color(0xFF078d70),
            Color(0xFF26ceaa),
            Color(0xFF98e8c1),
            Colors.white,
            Color(0xFF7bade2),
            Color(0xFF5049cc),
            Color(0xFF3d1a78),
          ],
        ),
        Palette(
          onColorSelected: onColorSelected,
          onPaletteSelected: onPaletteSelected,
          title: "Pansexual Flag",
          colors: const [
            Color(0xFFff1c8d),
            Color(0xFFffd700),
            Color(0xFF1ab3ff),
          ],
        ),
        Palette(
          onColorSelected: onColorSelected,
          onPaletteSelected: onPaletteSelected,
          title: "Genderqueer Flag",
          colors: const [
            Color(0xFFb57fdd),
            Colors.white,
            Color(0xFF49821e),
          ],
        ),
        Palette(
          onColorSelected: onColorSelected,
          onPaletteSelected: onPaletteSelected,
          title: "Intersex Flag",
          colors: const [
            Color(0xFFffd800),
            Color(0xFF7902aa),
          ],
        ),
      ],
    );
  }
}

class Palette extends StatelessWidget {
  const Palette({
    super.key,
    required this.title,
    required this.colors,
    this.onColorSelected,
    this.onPaletteSelected,
  }) : assert(onColorSelected != null || onPaletteSelected != null);

  final String title;
  final List<Color> colors;
  final ValueChanged<Color>? onColorSelected;
  final ValueChanged<List<Color>>? onPaletteSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap:
            onPaletteSelected != null ? () => onPaletteSelected!(colors) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (final color in colors)
                    ColorSquare(
                      color: color,
                      onTap: onColorSelected,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorSquare extends StatelessWidget {
  const ColorSquare({super.key, required this.color, required this.onTap});

  final Color color;
  final ValueChanged<Color>? onTap;

  @override
  Widget build(BuildContext context) {
    return Ink(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            offset: Offset(3, 3),
            blurRadius: 1,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap != null ? () => onTap!(color) : null,
      ),
    );
  }
}
