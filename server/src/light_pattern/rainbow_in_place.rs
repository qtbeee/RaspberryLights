use std::num::NonZeroUsize;

use rand::random_range;

use crate::model::{ConfigurationSetting, PatternConfiguration, PatternInfo, PatternSettingInfo};

use super::{Color, ColorlessPattern, LightPattern};

enum AdditionalSetting {
    MaxColorOffset,
}

impl AdditionalSetting {
    const SETTINGS_STRS: [&str; 1] = ["Maximum Color Offset"];
}

#[derive(Clone, Copy, Default)]
struct RainbowInPlaceOptions {
    max_color_offset: u8,
}

pub struct RainbowInPlace {
    positions: Vec<u8>,
    sleep_millis: u64,
    brightness: u8,
    options: RainbowInPlaceOptions,
}

impl RainbowInPlace {
    const SPEEDS: [usize; 4] = [100, 75, 50, 30];

    fn parse_options(options: Vec<ConfigurationSetting>) -> RainbowInPlaceOptions {
        let mut max_color_offset = Default::default();

        options.iter().for_each(|o| match o {
            ConfigurationSetting::Number { name, value } => match name {
                v if v
                    == AdditionalSetting::SETTINGS_STRS
                        [AdditionalSetting::MaxColorOffset as usize] =>
                {
                    max_color_offset = (*value as u8).clamp(0, 100);
                }
                _ => {}
            },
            _ => {}
        });

        RainbowInPlaceOptions { max_color_offset }
    }

    fn positions_from_options(led_count: NonZeroUsize, max_color_offset: u8) -> Vec<u8> {
        let mut result = vec![];
        result.resize_with(usize::from(led_count), || {
            if max_color_offset == 0 {
                0u8
            } else {
                random_range(0..max_color_offset)
            }
        });

        result
    }
}

impl LightPattern for RainbowInPlace {
    fn get_frame(&self) -> Vec<Color> {
        self.positions
            .iter()
            .map(|pos| Color::wheel(*pos).at_brightness_percent(self.brightness))
            .collect()
    }

    fn update(&mut self) {
        self.positions.iter_mut().for_each(|pos| {
            *pos = pos.overflowing_add(1).0;
        });
    }

    fn get_sleep_millis(&self) -> u64 {
        self.sleep_millis
    }

    fn get_info() -> PatternInfo {
        PatternInfo {
            pattern_id: crate::model::PatternName::RainbowInPlace,
            name: "Rainbow In Place",
            description: &"All leds change color together in a rainbow pattern.",
            can_choose_color: false,
            animation_speeds: Self::SPEEDS.len(),
            additional_settings: vec![PatternSettingInfo::Number {
                name: AdditionalSetting::SETTINGS_STRS[AdditionalSetting::MaxColorOffset as usize],
                description: Some(
                    "If set greater than 0, leds will be randomly offset from each other instead of synchronized.",
                ),
                default_value: 0,
                min: 0,
                max: 128,
                step_size: 16,
                is_percent: false,
            }],
        }
    }

    fn get_current_settings(&self) -> crate::model::PatternConfiguration {
        PatternConfiguration {
            pattern_id: crate::model::PatternName::RainbowInPlace,
            animation_speed: Self::SPEEDS
                .iter()
                .position(|&s| s == self.sleep_millis as usize),
            brightness: self.brightness,
            colors: Option::None,
            additional_settings: vec![ConfigurationSetting::Number {
                name: AdditionalSetting::SETTINGS_STRS[AdditionalSetting::MaxColorOffset as usize]
                    .into(),
                value: self.options.max_color_offset as usize,
            }],
        }
    }
}

impl ColorlessPattern for RainbowInPlace {
    fn new(
        leds: NonZeroUsize,
        speed: usize,
        brightness: u8,
        options: Vec<ConfigurationSetting>,
    ) -> Self {
        let options = Self::parse_options(options);

        Self {
            positions: Self::positions_from_options(leds, options.max_color_offset),
            sleep_millis: Self::SPEEDS[speed.clamp(0, Self::SPEEDS.len())] as u64,
            brightness,
            options,
        }
    }
}
