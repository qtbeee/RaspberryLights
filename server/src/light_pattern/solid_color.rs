use std::num::NonZeroUsize;

use crate::model::PatternInfo;

use super::{Color, ColorPattern, Information, LightPattern};

pub struct SolidColor {
    leds: NonZeroUsize,
    colors: Vec<Color>,
    sleep_millis: u64,
}

impl SolidColor {
    const SPEEDS: [usize; 1] = [100];
}

impl LightPattern for SolidColor {
    fn get_frame(&self) -> Vec<Color> {
        self.colors
            .iter()
            .cloned()
            .cycle()
            .take(usize::from(self.leds))
            .collect()
    }

    fn update(&mut self) {}

    fn get_sleep_millis(&self) -> u64 {
        self.sleep_millis
    }
}

impl ColorPattern for SolidColor {
    /// If more than one color is specified, the pattern
    /// will spread the colors across the leds like you would
    /// expect from a set of christmas lights.
    fn new(leds: NonZeroUsize, speed: usize, brightness: f32, colors: &[Color]) -> Self {
        Self {
            leds,
            colors: colors.iter().map(|c| c.at_brightness(brightness)).collect(),
            sleep_millis: Self::SPEEDS[speed.clamp(0, Self::SPEEDS.len())] as u64,
        }
    }
}

impl Information for SolidColor {
    fn get_info() -> PatternInfo {
        PatternInfo {
            pattern: crate::model::PatternName::SolidColor,
            can_choose_color: true,
            animation_speeds: Self::SPEEDS.len(),
        }
    }
}
