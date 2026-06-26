use std::num::NonZeroUsize;

use crate::model::{ConfigurationSetting, PatternConfiguration, PatternInfo};

use super::{Color, ColorPattern, LightPattern};

pub struct Scroll {
    pos: u8,
    brightness: u8,
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

    fn get_info() -> PatternInfo {
        PatternInfo {
            pattern_id: crate::model::PatternName::Scroll,
            name: "Scroll",
            description: &"Marquee-style scrolling lights pattern. Not recommended for those with photosensitivity.",
            can_choose_color: true,
            animation_speeds: Self::SPEEDS.len(),
            additional_settings: vec![],
        }
    }

    fn get_current_settings(&self) -> crate::model::PatternConfiguration {
        PatternConfiguration {
            pattern_id: crate::model::PatternName::Scroll,
            animation_speed: Self::SPEEDS
                .iter()
                .position(|&s| s == self.sleep_millis as usize),
            brightness: self.brightness,
            colors: Option::Some(self.colors.clone()),
            additional_settings: vec![],
        }
    }
}

impl ColorPattern for Scroll {
    fn new(
        leds: NonZeroUsize,
        speed: usize,
        brightness: u8,
        colors: &[Color],
        _options: Vec<ConfigurationSetting>,
    ) -> Self {
        Self {
            leds,
            brightness,
            pos: 0,
            colors: colors
                .iter()
                .map(|c| c.at_brightness_percent(brightness))
                .collect(),
            sleep_millis: Self::SPEEDS[speed.clamp(0, Self::SPEEDS.len() - 1)] as u64,
        }
    }
}
