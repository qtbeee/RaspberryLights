mod breathing;
mod color;
mod critmas;
mod rainbow_across;
mod rainbow_in_place;
mod scroll;
mod solid_color;
mod twinkle;

use std::num::NonZeroUsize;

pub use breathing::Breathing;
pub use color::Color;
pub use critmas::Critmas;
pub use rainbow_across::RainbowAcross;
pub use rainbow_in_place::RainbowInPlace;
pub use scroll::Scroll;
pub use solid_color::SolidColor;
pub use twinkle::Twinkle;

use crate::model::PatternInfo;

pub trait LightPattern {
    fn get_frame(&self) -> Vec<Color>;
    fn update(&mut self);
    fn get_sleep_millis(&self) -> u64;
}

pub trait ColorlessPattern: LightPattern + Information {
    fn new(leds: NonZeroUsize, speed: usize) -> Self;
}

pub trait ColorPattern: LightPattern + Information {
    fn new(leds: NonZeroUsize, speed: usize, colors: &[Color]) -> Self;
}

pub trait Information {
    fn get_info() -> PatternInfo;
}
