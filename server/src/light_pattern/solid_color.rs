use std::num::NonZeroUsize;

use serde_json::{Map, Value};

use crate::model::{PatternConfiguration, PatternInfo};

use super::{Color, ColorPattern, Information, LightPattern};

pub struct SolidColor {
    leds: NonZeroUsize,
    brightness: u8,
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
    fn new(
        leds: NonZeroUsize,
        speed: usize,
        brightness: u8,
        colors: &[Color],
        _options: Map<String, Value>,
    ) -> Self {
        Self {
            leds,
            brightness,
            colors: colors
                .iter()
                .map(|c| c.at_brightness_percent(brightness))
                .collect(),
            sleep_millis: Self::SPEEDS[speed.clamp(0, Self::SPEEDS.len())] as u64,
        }
    }
}

impl Information for SolidColor {
    fn get_info() -> PatternInfo {
        PatternInfo {
            pattern: crate::model::PatternName::SolidColor,
            description: &"Displays chosen color without animations. If more than one color is specified, colors are spread evenly across.",
            can_choose_color: true,
            animation_speeds: Self::SPEEDS.len(),
            additional_settings: vec![],
        }
    }

    fn get_current_settings(&self) -> crate::model::PatternConfiguration {
        PatternConfiguration {
            name: crate::model::PatternName::SolidColor,
            animation_speed: None,
            brightness: self.brightness,
            colors: Option::Some(self.colors.clone()),
            additional_settings: vec![],
        }
    }
}
