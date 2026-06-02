use std::num::NonZeroUsize;

use crate::model::{ConfigurationSetting, PatternConfiguration, PatternInfo};

use super::{Color, ColorlessPattern, LightPattern};

pub struct RainbowInPlace {
    pos: u8,
    led_count: NonZeroUsize,
    sleep_millis: u64,
    brightness: u8,
}

impl RainbowInPlace {
    const SPEEDS: [usize; 4] = [100, 75, 50, 30];
}

impl LightPattern for RainbowInPlace {
    fn get_frame(&self) -> Vec<Color> {
        let color = Color::wheel(self.pos).at_brightness_percent(self.brightness);

        vec![color; usize::from(self.led_count)]
    }

    fn update(&mut self) {
        self.pos = self.pos.overflowing_add(1).0;
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
            additional_settings: vec![],
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
            additional_settings: vec![],
        }
    }
}

impl ColorlessPattern for RainbowInPlace {
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
            brightness,
        }
    }
}
