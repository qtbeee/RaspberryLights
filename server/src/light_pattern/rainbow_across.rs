use std::num::NonZeroUsize;

use crate::model::{ConfigurationSetting, PatternConfiguration, PatternInfo};

use super::{Color, ColorlessPattern, LightPattern};

pub struct RainbowAcross {
    pos: u8,
    led_count: NonZeroUsize,
    sleep_millis: u64,
    global_brightness: u8,
}

impl RainbowAcross {
    const SPEEDS: [usize; 4] = [100, 75, 50, 30];
}

impl LightPattern for RainbowAcross {
    fn get_frame(&self) -> Vec<Color> {
        (0..usize::from(self.led_count))
            .map(|n| {
                // If FOR SOME REASON we have more than 255 leds, mod division by u8 max value
                // so it can't fail to cast to u8 and also doesn't do weird truncation.
                let n = n % usize::from(u8::MAX);

                Color::wheel(self.pos.overflowing_add(n as u8).0)
                    .at_brightness_percent(self.global_brightness)
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
        PatternInfo {
            pattern_id: crate::model::PatternName::RainbowAcross,
            name: "Rainbow Across",
            description: &"Rainbow gradient travels over the leds over time",
            can_choose_color: false,
            animation_speeds: Self::SPEEDS.len(),
            additional_settings: vec![],
        }
    }

    fn get_current_settings(&self) -> crate::model::PatternConfiguration {
        PatternConfiguration {
            pattern_id: crate::model::PatternName::RainbowAcross,
            animation_speed: Self::SPEEDS
                .iter()
                .position(|&s| s == self.sleep_millis as usize),
            brightness: self.global_brightness,
            colors: Option::None,
            additional_settings: vec![],
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
        }
    }
}
