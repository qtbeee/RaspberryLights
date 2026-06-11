use std::num::NonZeroUsize;

use crate::model::{ConfigurationSetting, PatternConfiguration, PatternInfo, PatternSettingInfo};

use super::{Color, ColorlessPattern, LightPattern};

pub struct RainbowAcross {
    pos: u8,
    led_count: NonZeroUsize,
    sleep_millis: u64,
    global_brightness: u8,
    options: RainbowAcrossOptions,
}

enum AdditionalSettings {
    Reverse,
    Width,
}

impl AdditionalSettings {
    pub const STRINGS: [&str; 2] = ["Reverse Animation", "Rainbow Width"];
}

pub struct RainbowAcrossOptions {
    reverse: bool,
    width: usize,
}

impl RainbowAcross {
    const SPEEDS: [usize; 5] = [100, 75, 50, 30, 17];
    const WIDTHS: [usize; 5] = [16, 32, 64, 128, 256];
    const WIDTHS_STRS: [&str; Self::WIDTHS.len()] = ["16", "32", "64", "128", "256"];

    fn parse_options(options: Vec<ConfigurationSetting>) -> RainbowAcrossOptions {
        use AdditionalSettings::{Reverse, Width};

        let mut reverse = Default::default();
        let mut width = 256;

        options.iter().for_each(|o| match o {
            ConfigurationSetting::Number { name, value } => {
                if name == AdditionalSettings::STRINGS[Width as usize] {
                    width = Self::WIDTHS[(*value).clamp(0, Self::WIDTHS.len())];
                }
            }
            ConfigurationSetting::Boolean { name, value } => {
                if name == AdditionalSettings::STRINGS[Reverse as usize] {
                    reverse = *value;
                }
            }
        });

        RainbowAcrossOptions { reverse, width }
    }
}

impl LightPattern for RainbowAcross {
    fn get_frame(&self) -> Vec<Color> {
        (0..usize::from(self.led_count))
            .map(|n| {
                // magic number: 256 is the maximum width of the rainbow
                let n = ((n * (256 / self.options.width as usize)) % usize::from(u8::MAX)) as u8;
                let operation = if self.options.reverse {
                    u8::overflowing_add
                } else {
                    u8::overflowing_sub
                };

                Color::wheel(operation(self.pos, n).0).at_brightness_percent(self.global_brightness)
            })
            .collect()
    }

    fn update(&mut self) {
        self.pos = self.pos.overflowing_add(1).0;
    }

    fn get_sleep_millis(&self) -> u64 {
        self.sleep_millis
    }

    fn get_info() -> PatternInfo {
        use AdditionalSettings::{Reverse, Width};

        let additional_settings = vec![
            PatternSettingInfo::Boolean {
                name: AdditionalSettings::STRINGS[Reverse as usize],
                description: None,
                default_value: false,
            },
            PatternSettingInfo::MultipleChoice {
                name: AdditionalSettings::STRINGS[Width as usize],
                description: Some("Choose how many leds wide the full rainbow will be."),
                options: Self::WIDTHS_STRS.into(),
                default_value: Self::WIDTHS.len() - 1,
            },
        ];

        PatternInfo {
            pattern_id: crate::model::PatternName::RainbowAcross,
            name: "Rainbow Across",
            description: "Rainbow gradient travels over the leds over time",
            can_choose_color: false,
            animation_speeds: Self::SPEEDS.len(),
            additional_settings,
        }
    }

    fn get_current_settings(&self) -> crate::model::PatternConfiguration {
        use AdditionalSettings::{Reverse, Width};

        let additional_settings = vec![
            ConfigurationSetting::Boolean {
                name: AdditionalSettings::STRINGS[Reverse as usize].into(),
                value: self.options.reverse,
            },
            ConfigurationSetting::Number {
                name: AdditionalSettings::STRINGS[Width as usize].into(),
                value: Self::WIDTHS
                    .iter()
                    .position(|&w| w == self.options.width)
                    .unwrap(),
            },
        ];

        PatternConfiguration {
            pattern_id: crate::model::PatternName::RainbowAcross,
            animation_speed: Self::SPEEDS
                .iter()
                .position(|&s| s == self.sleep_millis as usize),
            brightness: self.global_brightness,
            colors: Option::None,
            additional_settings,
        }
    }
}

impl ColorlessPattern for RainbowAcross {
    fn new(
        leds: NonZeroUsize,
        speed: usize,
        brightness: u8,
        _options: Vec<ConfigurationSetting>,
    ) -> Self {
        Self {
            pos: 0,
            led_count: leds,
            sleep_millis: Self::SPEEDS[speed.clamp(0, Self::SPEEDS.len())] as u64,
            global_brightness: brightness,
            options: Self::parse_options(_options),
        }
    }
}
