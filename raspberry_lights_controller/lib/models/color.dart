import 'dart:ui';

extension LedColor on Color {
  String _componentToHex(int component) {
    return component.toRadixString(16).padLeft(2, "0");
  }

  String toHexString() {
    final red = _componentToHex(this.red);
    final green = _componentToHex(this.green);
    final blue = _componentToHex(this.blue);

    return "#$red$green$blue";
  }
}
