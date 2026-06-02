mod breathing;
mod breathing_configurable;
mod color;
mod critmas;
mod rainbow_across;
mod rainbow_in_place;
mod scroll;
mod solid_color;
mod twinkle;

use std::num::NonZeroUsize;

pub use breathing::Breathing;
pub use breathing_configurable::BreathingConfigurable;
pub use color::Color;
pub use critmas::Critmas;
pub use rainbow_across::RainbowAcross;
pub use rainbow_in_place::RainbowInPlace;
pub use scroll::Scroll;
pub use solid_color::SolidColor;
pub use twinkle::Twinkle;

use crate::model::{ConfigurationSetting, PatternConfiguration, PatternInfo};

pub trait LightPattern {
    fn get_frame(&self) -> Vec<Color>;
    fn update(&mut self);
    fn get_sleep_millis(&self) -> u64;

    fn get_info() -> PatternInfo
    where
        Self: Sized;
    fn get_current_settings(&self) -> PatternConfiguration;
}

pub trait ColorlessPattern: LightPattern {
    fn new(
        leds: NonZeroUsize,
        speed: usize,
        brightness: u8,
        options: Vec<ConfigurationSetting>,
    ) -> Self;
}

pub trait ColorPattern: LightPattern {
    fn new(
        leds: NonZeroUsize,
        speed: usize,
        brightness: u8,
        colors: &[Color],
        options: Vec<ConfigurationSetting>,
    ) -> Self;
}
