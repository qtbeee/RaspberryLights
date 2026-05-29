import 'package:flutter/material.dart';

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
          BoxShadow(color: Colors.black38, offset: Offset(3, 3), blurRadius: 1),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap != null ? () => onTap!(color) : null,
      ),
    );
  }
}
