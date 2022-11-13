use std::num::NonZeroUsize;

use crate::model::PatternInfo;

use super::{Color, ColorlessPattern, Information, LightPattern};

pub struct RainbowInPlace {
    pos: u8,
    led_count: NonZeroUsize,
    sleep_millis: u64,
    brightness: f32,
}

impl RainbowInPlace {
    const SPEEDS: [usize; 4] = [100, 75, 50, 30];
}

impl LightPattern for RainbowInPlace {
    fn get_frame(&self) -> Vec<Color> {
        let color = Color::wheel(self.pos).at_brightness(self.brightness);

        vec![color; usize::from(self.led_count)]
    }

    fn update(&mut self) {
        self.pos = self.pos.overflowing_add(1).0;
    }

    fn get_sleep_millis(&self) -> u64 {
        self.sleep_millis
    }
}

impl ColorlessPattern for RainbowInPlace {
    fn new(leds: NonZeroUsize, speed: usize, brightness: f32) -> Self {
        Self {
            pos: 0,
            led_count: leds,
            sleep_millis: Self::SPEEDS[speed.clamp(0, Self::SPEEDS.len())] as u64,
            brightness,
        }
    }
}

impl Information for RainbowInPlace {
    fn get_info() -> PatternInfo {
        PatternInfo {
            pattern: crate::model::PatternName::RainbowInPlace,
            can_choose_color: false,
            animation_speeds: Self::SPEEDS.len(),
        }
    }
}
