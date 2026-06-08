A Flutter app and tiny Rust API for controlling a WS2811 led light strip on a Raspberry Pi.

#### Q: Why not run a locally-hosted website on the pi instead?

A: Practice. This would have taken a lot less effort and time if I had just made a silly little Flask app for example. I wanted to have more practice with Flutter and I specifically wanted to be able to quickly find my pi on the network via ZeroConf/Avahi instead of having to require access to the router in order to have a fixed IP address for it.

#### Q: What are the limitations of this project?

A: I can think of a few inherent issues, first one being the light strip this is made for. It turns out it's really hard to accurately represent an RGB color when you don't have separate control over the brightness of an led, because then the only way to decrease the brightness of an led is to scale the RGB values, which are integers. Consequently you get weird color changes when the color is fading to and from "black".

## Developing

There's 2 parts to this project - a flutter app, and a rust server.

### Flutter app

_Requirements_

- Flutter :)

### Building

- Generate code for the data models

```bash
dart run build_runner build
```

### Rust Server

_Requirements_

- Rust/Cargo
- Cross (for cross-compiling to raspberry pi because the poor device is too slow to do it alone)

### Building

- Create a copy of `tools/sync.fish` with the correct rpi hostname and target executable path (If you don't want to use fish shell you'll have to make your own convenience script)
- Customize and copy `tools/lights.service` to your rpi and enable the service (Requires `systemd`. There should be other ways to auto-run the program if you don't want to or can't use systemd)
- Optional: the Flutter app can find the raspberry pi through multicast DNS if the pi is setup for it

## TODO

- [ ] https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin
  - Bonsoir package is blocking this, is there an alternative?
