use std::num::NonZeroUsize;

use crate::model::PatternInfo;

use super::{Color, ColorPattern, Information, LightPattern};

pub struct Scroll {
    pos: u8,
    leds: NonZeroUsize,
    color: Color,
    sleep_millis: u64,
}

impl Scroll {
    const SPEEDS: [usize; 2] = [250, 230];
}

impl LightPattern for Scroll {
    fn get_frame(&self) -> Vec<Color> {
        let mut result = vec![];
        for n in 0..usize::from(self.leds) {
            let n = n % usize::from(u8::MAX);
            if (n as u8).overflowing_add(self.pos).0 % 3 == 0 {
                result.push(self.color);
            } else {
                result.push(Color {
                    red: 0,
                    green: 0,
                    blue: 0,
                });
            }
        }

        result
    }

    fn update(&mut self) {
        self.pos = self.pos.overflowing_add(1).0
    }

    fn get_sleep_millis(&self) -> u64 {
        self.sleep_millis
    }
}

impl ColorPattern for Scroll {
    fn new(leds: NonZeroUsize, speed: usize, brightness: f32, colors: &[Color]) -> Self {
        Self {
            leds,
            pos: 0,
            color: colors[0].at_brightness(brightness),
            sleep_millis: Self::SPEEDS[speed.clamp(0, Self::SPEEDS.len())] as u64,
        }
    }
}

impl Information for Scroll {
    fn get_info() -> PatternInfo {
        PatternInfo {
            pattern: crate::model::PatternName::Scroll,
            can_choose_color: true,
            animation_speeds: Self::SPEEDS.len(),
        }
    }
}
