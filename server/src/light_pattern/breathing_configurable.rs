use std::{fmt::Display, num::NonZeroUsize};

use rand::{Rng, distributions::Uniform, thread_rng};
use serde_json::{Map, Value};

use crate::model::{ConfigurationSetting, PatternConfiguration, PatternInfo, PatternSetting};

use super::{Color, ColorPattern, Information, LightPattern};

#[derive(Debug)]
pub struct BreathingConfigurable {
    led_count: NonZeroUsize,
    brightness: u8,
    current_position: u16,
    colors: Vec<Color>,
    current_colors: Vec<u8>,
    options: BreathingOptions,
    step_size: u16,
}

#[derive(Default, Debug)]
pub struct BreathingOptions {
    color_choice: ColorChoice,
    min_relative_brightness: usize,
}

#[derive(Default, Debug)]
pub enum ColorChoice {
    #[default]
    SyncOnCycle,
    RandomizeOnCycle,
    BalancedOnce,
    RandomizedOnce,
}

const COLOR_CHOICE_STRS: [&str; 4] = [
    "Synchronize Every Cycle",
    "Randomize Every Cycle",
    "Spread Evenly Once",
    "Randomize Once",
];

impl Display for ColorChoice {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ColorChoice::SyncOnCycle => f.write_str(COLOR_CHOICE_STRS[0]),
            ColorChoice::RandomizeOnCycle => f.write_str(COLOR_CHOICE_STRS[1]),
            ColorChoice::BalancedOnce => f.write_str(COLOR_CHOICE_STRS[2]),
            ColorChoice::RandomizedOnce => f.write_str(COLOR_CHOICE_STRS[3]),
        }
    }
}

impl BreathingConfigurable {
    /* How many steps to advance `pos` by each frame */
    pub const SPEEDS: [u16; 6] = [1, 2, 3, 4, 5, 6];
    const FRAME_COUNT: u16 = 720;

    // TODO: implement options coming from the user
    fn parse_options(options: Map<String, Value>) -> BreathingOptions {
        println!("options raw: {:?}", options);

        BreathingOptions::default()
    }

    fn reset_colors(&mut self) {
        match self.options.color_choice {
            ColorChoice::SyncOnCycle => {
                let color_index = thread_rng().gen_range(0..self.colors.len()) as u8;

                if self.current_colors.len() == 0 {
                    self.current_colors
                        .resize(self.led_count.into(), color_index);
                } else {
                    self.current_colors
                        .iter_mut()
                        .for_each(|i| *i = color_index)
                }
            }
            ColorChoice::RandomizeOnCycle => {
                if self.current_colors.len() == 0 {
                    self.current_colors.resize_with(self.led_count.into(), || {
                        thread_rng().gen_range(0..self.colors.len()) as u8
                    });
                } else {
                    self.current_colors
                        .iter_mut()
                        .for_each(|i| *i = thread_rng().gen_range(0..self.colors.len()) as u8);
                }
            }
            ColorChoice::BalancedOnce if self.current_colors.len() == 0 => {
                self.current_colors.extend(
                    (0..self.colors.len() as u8)
                        .cycle()
                        .take(self.led_count.into()),
                );
            }
            ColorChoice::RandomizedOnce if self.current_colors.len() == 0 => {
                let distr = Uniform::new(0, self.colors.len() as u8);

                self.current_colors.extend(
                    thread_rng()
                        .sample_iter(distr)
                        .take(usize::from(self.led_count)),
                );
            }
            _ => {}
        }
    }
}

impl LightPattern for BreathingConfigurable {
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
                    .at_brightness(brightness)
            })
            .collect()
    }

    fn update(&mut self) {
        let next_pos = (self.current_position + self.step_size) % Self::FRAME_COUNT;
        if self.current_position > next_pos {
            // If we've looped back around, see if we need to change the color
            match self.options.color_choice {
                ColorChoice::SyncOnCycle | ColorChoice::RandomizeOnCycle => self.reset_colors(),
                ColorChoice::BalancedOnce | ColorChoice::RandomizedOnce => {}
            }
        }
        self.current_position = next_pos;
    }

    fn get_sleep_millis(&self) -> u64 {
        17 // Vaguely 60fps?
    }
}

impl ColorPattern for BreathingConfigurable {
    fn new(
        leds: NonZeroUsize,
        speed: usize,
        brightness: u8,
        colors: &[Color],
        options: Map<String, Value>,
    ) -> Self {
        let mut pattern = Self {
            led_count: leds,
            brightness,
            current_position: 100,
            colors: colors
                .iter()
                .map(|c| c.at_brightness_percent(brightness))
                .collect(),
            current_colors: Vec::new(),
            options: Self::parse_options(options),
            step_size: Self::SPEEDS[speed.clamp(0, Self::SPEEDS.len())],
        };
        pattern.reset_colors(); // Set initial colors here

        pattern
    }
}

impl Information for BreathingConfigurable {
    fn get_info() -> PatternInfo {
        let additional_settings = vec![
            PatternSetting::MultipleChoice {
                name: "Color Assignment",
                description: Some("Choose how the leds are assigned color."),
                options: COLOR_CHOICE_STRS.into(),
            },
            PatternSetting::Number {
                name: "Minimum Relative Brightness",
                description: Some(
                    "Choose how dark leds get every cycle relative to the overall brightness setting, as a percentage.",
                ),
                min: 0,
                max: 95,
            },
        ];

        PatternInfo {
            pattern: crate::model::PatternName::BreathingConfigurable,
            description: "Pattern where each leds varies in brightness. Cycle behavior can be customized.",
            can_choose_color: true,
            animation_speeds: Self::SPEEDS.len(),
            additional_settings,
        }
    }

    fn get_current_settings(&self) -> crate::model::PatternConfiguration {
        PatternConfiguration {
            name: crate::model::PatternName::BreathingConfigurable,
            animation_speed: Self::SPEEDS.iter().position(|&s| s == self.step_size),
            brightness: self.brightness,
            colors: Option::Some(self.colors.clone()),
            additional_settings: vec![
                ConfigurationSetting::MultipleChoice {
                    name: "Color Assignment",
                    value: format!("{}", self.options.color_choice),
                },
                ConfigurationSetting::Number {
                    name: "Minimum Relative Brightness",
                    value: self.options.min_relative_brightness,
                    is_percent: true,
                },
            ],
        }
    }
}
