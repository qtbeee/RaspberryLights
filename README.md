# raspberry_lights_controller

A Flutter app and tiny Rust API for controlling an led light strip on a Raspberry Pi.

## Developing
There's 2 parts to this project - a flutter app, and a rust server.

### Flutter app

_Requirements_

- Flutter :)

### Building

- Generate code for PatternInfo model

```bash
flutter pub run build_runner build
```

### Rust Server

_Requirements_

- Rust/Cargo
- Cross (for cross-compiling to raspberry pi because the poor device is too slow to do it alone)
