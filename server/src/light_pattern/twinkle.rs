use std::num::NonZeroUsize;

use rand::random_range;

use crate::model::{ConfigurationSetting, PatternConfiguration, PatternInfo, PatternSetting};

use super::{Color, ColorPattern, LightPattern};

pub struct Twinkle {
    brightness: u8,
    brightnesses: Vec<u16>,
    led_colors: Vec<Color>,
    colors: Vec<Color>,
    sleep_millis: u64,
}

impl Twinkle {
    const FRAMES: u16 = 360;
    const SPEEDS: [u64; 3] = [30, 25, 20];
}

impl LightPattern for Twinkle {
    fn get_frame(&self) -> Vec<Color> {
        self.led_colors
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

    fn get_info() -> PatternInfo {
        let additional_settings: Vec<PatternSetting> = vec![];

        PatternInfo {
            pattern_id: crate::model::PatternName::Twinkle,
            name: "Twinkle",
            description: &"Leds vary in brightness independently to simulate a twinkling effect. If more than one color is specified, colors are spread evenly across.",
            can_choose_color: true,
            animation_speeds: Self::SPEEDS.len(),
            additional_settings,
        }
    }

    fn get_current_settings(&self) -> crate::model::PatternConfiguration {
        PatternConfiguration {
            pattern_id: crate::model::PatternName::Twinkle,
            animation_speed: Self::SPEEDS.iter().position(|&s| s == self.sleep_millis),
            brightness: self.brightness,
            colors: Option::Some(self.colors.clone()),
            additional_settings: vec![],
        }
    }
}

impl ColorPattern for Twinkle {
    fn new(
        leds: NonZeroUsize,
        speed: usize,
        brightness: u8,
        colors: &[Color],
        _options: Vec<ConfigurationSetting>,
    ) -> Self {
        Self {
            brightness,
            brightnesses: (0..usize::from(leds))
                .map(|_| random_range(0..Self::FRAMES))
                .collect(),
            colors: colors.into(),
            led_colors: colors
                .iter()
                .map(|c| c.at_brightness_percent(brightness))
                .cycle()
                .take(usize::from(leds))
                .collect(),
            sleep_millis: Self::SPEEDS[speed.clamp(0, Self::SPEEDS.len())],
        }
    }
}
