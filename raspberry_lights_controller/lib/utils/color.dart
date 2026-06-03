import 'dart:ui';

extension LedColor on Color {
  // Input must be in the format #RRGGBB
  static Color fromShortHex(String hex) {
    assert(hex.length == 7, 'invalid format');

    final hexMinuxHash = hex.substring(1);
    final red = int.parse(hexMinuxHash.substring(0, 2), radix: 16);
    final green = int.parse(hexMinuxHash.substring(2, 4), radix: 16);
    final blue = int.parse(hexMinuxHash.substring(4), radix: 16);

    return Color.fromARGB(255, red, green, blue);
  }

  String toHexString() {
    final argb = toARGB32().toRadixString(16);

    return '#${argb.substring(2)}'.toUpperCase();
  }
}
