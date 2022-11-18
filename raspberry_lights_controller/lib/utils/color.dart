import 'dart:ui';

extension LedColor on Color {
  // Input must be in the format #RRGGBB
  static Color fromShortHex(String hex) {
    assert(hex.length == 7);

    hex = hex.substring(1);
    final red = int.parse(hex.substring(0, 2), radix: 16);
    final green = int.parse(hex.substring(2, 4), radix: 16);
    final blue = int.parse(hex.substring(4), radix: 16);

    return Color.fromARGB(255, red, green, blue);
  }

  String _componentToHex(int component) {
    return component.toRadixString(16).padLeft(2, "0");
  }

  String toHexString() {
    final red = _componentToHex(this.red);
    final green = _componentToHex(this.green);
    final blue = _componentToHex(this.blue);

    return "#$red$green$blue".toUpperCase();
  }
}
