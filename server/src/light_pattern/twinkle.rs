use std::num::NonZeroUsize;

use rand::{thread_rng, Rng};

use crate::model::PatternInfo;

use super::{Color, ColorPattern, Information, LightPattern};

pub struct Twinkle {
    brightnesses: Vec<u16>,
    colors: Vec<Color>,
    sleep_millis: u64,
}

impl Twinkle {
    const FRAMES: u16 = 360;
    const SPEEDS: [usize; 2] = [50, 30];
}

impl LightPattern for Twinkle {
    fn get_frame(&self) -> Vec<Color> {
        self.colors
            .iter()
            .zip(self.brightnesses.iter())
            .map(|(color, brightness)| {
                // brightness set to be between 0.3 and 1.8, which will then be clamped to 0.3 and 1.0
                // I think I did this so that the lights would spend a bit more time at full brightness?
                let brightness = (*brightness as f32).to_radians().sin() / 2.0 + 0.6;
                color.at_brightness(brightness)
            })
            .collect()
    }

    fn update(&mut self) {
        for brightness in self.brightnesses.iter_mut() {
            *brightness = (*brightness + 10) % Self::FRAMES
        }
    }

    fn get_sleep_millis(&self) -> u64 {
        self.sleep_millis
    }
}

impl ColorPattern for Twinkle {
    fn new(leds: NonZeroUsize, speed: usize, colors: &[Color]) -> Self {
        Self {
            brightnesses: (0..usize::from(leds))
                .map(|_| thread_rng().gen_range(0..Self::FRAMES))
                .collect(),
            colors: colors
                .iter()
                .cloned()
                .cycle()
                .take(usize::from(leds))
                .collect(),
            sleep_millis: Self::SPEEDS[speed.clamp(0, Self::SPEEDS.len())] as u64,
        }
    }
}

impl Information for Twinkle {
    fn get_info() -> PatternInfo {
        PatternInfo {
            pattern: crate::model::PatternName::Twinkle,
            can_choose_color: true,
            animation_speeds: Self::SPEEDS.len(),
        }
    }
}
