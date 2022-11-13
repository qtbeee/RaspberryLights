use std::num::NonZeroUsize;

use crate::model::PatternInfo;

use super::{Color, ColorlessPattern, Information, LightPattern};

pub struct RainbowAcross {
    pos: u8,
    led_count: NonZeroUsize,
    sleep_millis: u64,
    brightness: f32,
}

impl RainbowAcross {
    const SPEEDS: [usize; 4] = [100, 75, 50, 30];
}

impl LightPattern for RainbowAcross {
    fn get_frame(&self) -> Vec<Color> {
        (0..usize::from(self.led_count))
            .map(|n| {
                // If FOR SOME REASON we have more than 255 leds, mod division by u8 max value
                // so it can't fail to cast to u8 and also doesn't do weird truncation.
                let n = n % usize::from(u8::MAX);

                Color::wheel(self.pos.overflowing_add(n as u8).0).at_brightness(self.brightness)
            })
            .collect()
    }

    fn update(&mut self) {
        self.pos = self.pos.overflowing_add(1).0;
    }

    fn get_sleep_millis(&self) -> u64 {
        self.sleep_millis
    }
}

impl ColorlessPattern for RainbowAcross {
    fn new(leds: NonZeroUsize, speed: usize, brightness: f32) -> Self {
        Self {
            pos: 0,
            led_count: leds,
            sleep_millis: Self::SPEEDS[speed.clamp(0, Self::SPEEDS.len())] as u64,
            brightness,
        }
    }
}

impl Information for RainbowAcross {
    fn get_info() -> PatternInfo {
        PatternInfo {
            pattern: crate::model::PatternName::RainbowAcross,
            can_choose_color: false,
            animation_speeds: Self::SPEEDS.len(),
        }
    }
}
