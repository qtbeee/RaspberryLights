use std::num::NonZeroUsize;

use rand::{random_range, rng, seq::IndexedRandom};

use crate::model::{ConfigurationSetting, PatternConfiguration, PatternInfo, PatternSettingInfo};

use super::{Color, ColorPattern, LightPattern};

pub enum AdditionalSetting {
    ColorAssignment,
}

impl AdditionalSetting {
    const STRS: [&str; 1] = ["Color Assignment"];
}

#[derive(Clone, Copy)]
pub struct TwinkleOptions {
    color_choice: TwinkleColorChoice,
}

#[derive(Default, Clone, Copy)]
enum TwinkleColorChoice {
    #[default]
    BalancedOnce,
    RandomizeOnce,
    SynchronizeAndCycleThrough,
    BalancedAndCycleThrough,
    RandomizeAndCycleThrough,
}

impl TryFrom<usize> for TwinkleColorChoice {
    type Error = &'static str;

    fn try_from(value: usize) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(TwinkleColorChoice::BalancedOnce),
            1 => Ok(TwinkleColorChoice::RandomizeOnce),
            2 => Ok(TwinkleColorChoice::SynchronizeAndCycleThrough),
            3 => Ok(TwinkleColorChoice::BalancedAndCycleThrough),
            4 => Ok(TwinkleColorChoice::RandomizeAndCycleThrough),
            _ => Err("Out of bounds value"),
        }
    }
}

impl TwinkleColorChoice {
    const STRS: [&str; 5] = [
        "Spread Evenly Once",
        "Randomize Once",
        "Synchronize and Cycle",
        "Spread Evenly and Cycle",
        "Randomize and Cycle",
    ];
}

pub struct Twinkle {
    brightness: u8,
    brightnesses: Vec<u16>,
    led_colors: Vec<Color>,
    colors: Vec<Color>,
    sleep_millis: u64,
    options: TwinkleOptions,
}

impl Twinkle {
    const FRAMES: u16 = 180;
    const SPEEDS: [u64; 3] = [30, 25, 20];

    fn parse_options(options: Vec<ConfigurationSetting>) -> TwinkleOptions {
        let mut color_choice = Default::default();

        options.iter().for_each(|o| match o {
            ConfigurationSetting::Number { name, value } => match name {
                v if v == AdditionalSetting::STRS[AdditionalSetting::ColorAssignment as usize] => {
                    color_choice = TwinkleColorChoice::try_from(*value).unwrap_or_default();
                }
                _ => {}
            },
            _ => {}
        });

        TwinkleOptions { color_choice }
    }

    fn initialize_colors(
        led_count: usize,
        colors: &[Color],
        color_choice: TwinkleColorChoice,
    ) -> Vec<Color> {
        if colors.len() == 1 {
            return vec![colors[0]; led_count];
        }

        match color_choice {
            TwinkleColorChoice::BalancedOnce | TwinkleColorChoice::BalancedAndCycleThrough => {
                colors.iter().cycle().take(led_count).copied().collect()
            }
            TwinkleColorChoice::RandomizeOnce | TwinkleColorChoice::RandomizeAndCycleThrough => {
                let mut rng = rng();
                colors
                    .choose_iter(&mut rng)
                    .unwrap() // can't be empty
                    .take(led_count)
                    .copied()
                    .collect()
            }
            TwinkleColorChoice::SynchronizeAndCycleThrough => vec![colors[0]; led_count],
        }
    }

    fn next_color(&self, current_color: Color) -> Color {
        if self.colors.len() == 1 {
            return current_color;
        }

        match self.options.color_choice {
            TwinkleColorChoice::BalancedOnce | TwinkleColorChoice::RandomizeOnce => current_color,
            TwinkleColorChoice::SynchronizeAndCycleThrough
            | TwinkleColorChoice::BalancedAndCycleThrough
            | TwinkleColorChoice::RandomizeAndCycleThrough => {
                let color_index = self
                    .colors
                    .iter()
                    .position(|c| *c == current_color)
                    .unwrap();
                self.colors[(color_index + 1) % self.colors.len()]
            }
        }
    }
}

impl LightPattern for Twinkle {
    fn get_frame(&self) -> Vec<Color> {
        self.led_colors
            .iter()
            .zip(self.brightnesses.iter())
            .map(|(color, brightness)| {
                // brightness set to be between 0.3 and 1.3, which will then be clamped to 0.3 and 1.0
                // I think I did this so that the lights would spend a bit more time at full brightness?
                let brightness = (*brightness as f32).to_radians().sin().abs() + 0.3;
                color
                    .at_brightness_percent(self.brightness)
                    .at_brightness(brightness)
            })
            .collect()
    }

    fn update(&mut self) {
        for index in 0..self.brightnesses.len() {
            let old_brightness = self.brightnesses[index];
            self.brightnesses[index] = (old_brightness + 5) % Self::FRAMES;

            // If we've finished the loop on a given led, pick the next color it will be
            if self.brightnesses[index] < old_brightness {
                self.led_colors[index] = self.next_color(self.led_colors[index]);
            }
        }
    }

    fn get_sleep_millis(&self) -> u64 {
        self.sleep_millis
    }

    fn get_info() -> PatternInfo {
        let additional_settings: Vec<PatternSettingInfo> =
            vec![PatternSettingInfo::MultipleChoice {
                name: AdditionalSetting::STRS[AdditionalSetting::ColorAssignment as usize],
                description: Some(
                    "Choose how leds are assigned color if more than one color is provided.",
                ),
                options: TwinkleColorChoice::STRS.into(),
                default_value: TwinkleColorChoice::default() as usize,
            }];

        PatternInfo {
            pattern_id: crate::model::PatternName::Twinkle,
            name: "Twinkle",
            description: &"Leds vary in brightness independently to simulate a twinkling effect.",
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
            additional_settings: vec![ConfigurationSetting::Number {
                name: AdditionalSetting::STRS[AdditionalSetting::ColorAssignment as usize].into(),
                value: self.options.color_choice as usize,
            }],
        }
    }
}

impl ColorPattern for Twinkle {
    fn new(
        leds: NonZeroUsize,
        speed: usize,
        brightness: u8,
        colors: &[Color],
        options: Vec<ConfigurationSetting>,
    ) -> Self {
        let options = Self::parse_options(options);

        let result = Self {
            options,
            brightness,
            brightnesses: (0..usize::from(leds))
                .map(|_| random_range(0..Self::FRAMES))
                .collect(),
            colors: colors.into(),
            led_colors: Self::initialize_colors(usize::from(leds), colors, options.color_choice),
            sleep_millis: Self::SPEEDS[speed.clamp(0, Self::SPEEDS.len())],
        };

        result
    }
}
