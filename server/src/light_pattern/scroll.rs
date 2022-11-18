use std::num::NonZeroUsize;

use crate::model::PatternInfo;

use super::{Color, ColorPattern, Information, LightPattern};

pub struct Scroll {
    pos: u8,
    leds: NonZeroUsize,
    colors: Vec<Color>,
    sleep_millis: u64,
}

impl Scroll {
    const SPEEDS: [usize; 3] = [250, 230, 100];
}

impl LightPattern for Scroll {
    fn get_frame(&self) -> Vec<Color> {
        let mut result = vec![];
        for n in 0..usize::from(self.leds) {
            let n = n % usize::from(u8::MAX);
            if (n as u8).overflowing_add(self.pos).0 % 3 == 0 {
                let index = if self.colors.len() > 1 {
                    n.overflowing_add(usize::from(self.pos)).0 / 3 % self.colors.len()
                } else {
                    0
                };

                result.push(self.colors[index]);
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
            colors: colors.iter().map(|c| c.at_brightness(brightness)).collect(),
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
