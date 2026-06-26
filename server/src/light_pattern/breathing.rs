use std::num::NonZeroUsize;

use rand::{
    distr::{Distribution, Uniform},
    random_range, rng,
};

use crate::model::{ConfigurationSetting, PatternConfiguration, PatternInfo, PatternSettingInfo};

use super::{Color, ColorPattern, LightPattern};

#[derive(Debug)]
pub struct Breathing {
    global_brightness: u8,
    current_position: u16,
    colors: Vec<Color>,
    current_colors: Vec<u8>,
    options: BreathingOptions,
    step_size: u16,
}

enum AdditionalSetting {
    ColorAssignment,
    MinRelBrightness,
}

const SETTINGS_STRS: [&str; 2] = ["Color Assignment", "Minimum Relative Brightness"];

#[derive(Default, Debug)]
pub struct BreathingOptions {
    color_choice: ColorChoice,
    min_relative_brightness: usize,
}

#[derive(Default, Debug, Clone, Copy)]
pub enum ColorChoice {
    #[default]
    SyncOnCycle,
    RandomizeOnCycle,
    BalancedOnce,
    RandomizedOnce,
}

impl TryFrom<usize> for ColorChoice {
    type Error = &'static str;

    fn try_from(value: usize) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(ColorChoice::SyncOnCycle),
            1 => Ok(ColorChoice::RandomizeOnCycle),
            2 => Ok(ColorChoice::BalancedOnce),
            3 => Ok(ColorChoice::RandomizedOnce),
            _ => Err("Out of bounds value"),
        }
    }
}

const COLOR_CHOICE_STRS: [&str; 4] = [
    "Synchronize Every Cycle",
    "Randomize Every Cycle",
    "Spread Evenly Once",
    "Randomize Once",
];

impl Breathing {
    /* How many steps to advance `pos` by each frame */
    pub const SPEEDS: [u16; 6] = [1, 2, 3, 4, 5, 6];
    const FRAME_COUNT: u16 = 720;

    fn parse_options(options: Vec<ConfigurationSetting>) -> BreathingOptions {
        let mut color_choice = Default::default();
        let mut min_relative_brightness = Default::default();

        options.iter().for_each(|o| match o {
            ConfigurationSetting::Number { name, value } => match name {
                v if v == SETTINGS_STRS[AdditionalSetting::ColorAssignment as usize] => {
                    color_choice = ColorChoice::try_from(*value).unwrap_or_default();
                }
                v if v == SETTINGS_STRS[AdditionalSetting::MinRelBrightness as usize] => {
                    min_relative_brightness = (*value).clamp(0, 95);
                }
                _ => {}
            },
            _ => {}
        });

        BreathingOptions {
            color_choice,
            min_relative_brightness,
        }
    }

    fn get_starting_colors(
        colors: &[Color],
        color_choice: ColorChoice,
        led_count: usize,
    ) -> Vec<u8> {
        if colors.len() == 1 {
            return vec![0; led_count];
        }

        match color_choice {
            ColorChoice::SyncOnCycle => {
                let color_index = random_range(0..colors.len()) as u8;
                vec![color_index; led_count]
            }
            ColorChoice::RandomizeOnCycle | ColorChoice::RandomizedOnce => {
                Uniform::try_from(0u8..colors.len() as u8)
                    .unwrap()
                    .sample_iter(rng())
                    .take(led_count)
                    .collect()
            }
            ColorChoice::BalancedOnce => (0..colors.len())
                .into_iter()
                .cycle()
                .take(led_count)
                .map(|i| i as u8)
                .collect(),
        }
    }

    fn reset_colors(&mut self) {
        if self.colors.len() == 1 {
            return;
        }

        match self.options.color_choice {
            ColorChoice::SyncOnCycle => {
                let color_index = random_range(0..self.colors.len()) as u8;

                self.current_colors
                    .iter_mut()
                    .for_each(|i| *i = color_index)
            }
            ColorChoice::RandomizeOnCycle => {
                self.current_colors
                    .iter_mut()
                    .for_each(|i| *i = random_range(0..self.colors.len()) as u8);
            }
            ColorChoice::BalancedOnce | ColorChoice::RandomizedOnce => {}
        }
    }
}

impl LightPattern for Breathing {
    fn get_frame(&self) -> Vec<Color> {
        // brightness set to be between `options.min_relative_brightness` (as a float instead of percentage) and 1
        // e.g. if min_relative_brightness is 25%
        // sin(pos) => 0...1
        // sin(pos) * brightness_range => 0...0.75
        // (sin(pos) * brightness_range) + (min_relative_brightness / 100) => 0.25...1
        let brightness_range = (100f32 - (self.options.min_relative_brightness as f32)) / 100f32;
        let pos_as_radians =
            (self.current_position as f32 / Self::FRAME_COUNT as f32 * 180f32).to_radians();
        let brightness = pos_as_radians.sin() * brightness_range
            + ((self.options.min_relative_brightness as f32) / 100f32);

        self.current_colors
            .iter()
            .map(|color_index| {
                self.colors
                    .get((*color_index) as usize)
                    .unwrap()
                    .at_brightness_percent(self.global_brightness)
                    .at_brightness(brightness)
            })
            .collect()
    }

    fn update(&mut self) {
        let next_pos = (self.current_position + self.step_size) % Self::FRAME_COUNT;
        if self.current_position > next_pos {
            self.reset_colors();
        }
        self.current_position = next_pos;
    }

    fn get_sleep_millis(&self) -> u64 {
        17 // Vaguely 60fps?
    }

    fn get_info() -> PatternInfo {
        let additional_settings = vec![
            PatternSettingInfo::MultipleChoice {
                name: SETTINGS_STRS[AdditionalSetting::ColorAssignment as usize],
                description: Some(
                    "Choose how leds are assigned color if more than one color is provided.",
                ),
                options: COLOR_CHOICE_STRS.into(),
                default_value: ColorChoice::default() as usize,
            },
            PatternSettingInfo::Number {
                name: SETTINGS_STRS[AdditionalSetting::MinRelBrightness as usize],
                description: Some(
                    "Choose how dark leds get every cycle relative to the overall brightness setting, as a percentage.",
                ),
                min: 0,
                max: 95,
                default_value: 0,
                step_size: 5,
                is_percent: true,
            },
        ];

        PatternInfo {
            pattern_id: crate::model::PatternName::Breathing,
            name: "Breathing",
            description: "All lights fade in and out together.",
            can_choose_color: true,
            animation_speeds: Self::SPEEDS.len(),
            additional_settings,
        }
    }

    fn get_current_settings(&self) -> crate::model::PatternConfiguration {
        PatternConfiguration {
            pattern_id: crate::model::PatternName::Breathing,
            animation_speed: Self::SPEEDS.iter().position(|&s| s == self.step_size),
            brightness: self.global_brightness,
            colors: Option::Some(self.colors.clone()),
            additional_settings: vec![
                ConfigurationSetting::Number {
                    name: SETTINGS_STRS[AdditionalSetting::ColorAssignment as usize].into(),
                    value: self.options.color_choice as usize,
                },
                ConfigurationSetting::Number {
                    name: SETTINGS_STRS[AdditionalSetting::MinRelBrightness as usize].into(),
                    value: self.options.min_relative_brightness,
                },
            ],
        }
    }
}

impl ColorPattern for Breathing {
    fn new(
        leds: NonZeroUsize,
        speed: usize,
        brightness: u8,
        colors: &[Color],
        options: Vec<ConfigurationSetting>,
    ) -> Self {
        let options = Self::parse_options(options);

        Self {
            global_brightness: brightness,
            current_position: 100,
            colors: colors.into(),
            current_colors: Self::get_starting_colors(
                colors,
                options.color_choice,
                usize::from(leds),
            ),
            options,
            step_size: Self::SPEEDS[speed.clamp(0, Self::SPEEDS.len() - 1)],
        }
    }
}
