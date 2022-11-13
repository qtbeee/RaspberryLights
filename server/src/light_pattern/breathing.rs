use std::num::NonZeroUsize;

use rand::{thread_rng, Rng};

use crate::model::PatternInfo;

use super::{Color, ColorPattern, Information, LightPattern};

pub struct Breathing {
    led_count: NonZeroUsize,
    pos: u16,
    colors: Vec<Color>,
    current_color: usize,
    sleep_millis: u64,
}

impl Breathing {
    pub const SPEEDS: [usize; 3] = [35, 30, 20];

    fn pick_color(&mut self) {
        if self.colors.len() == 1 {
            return;
        }

        // We want to avoid the same color in a row, but also don't wanna loop too long
        // if the rng gives the same number back-to-back. Solution: if the same color is
        // is chosen in a row, just choose the "next" color in the list instead.
        let next_color = thread_rng().gen_range(0..self.colors.len());
        if self.current_color == next_color {
            self.current_color = (self.current_color + 1) % self.colors.len();
        }
    }
}

impl LightPattern for Breathing {
    fn get_frame(&self) -> Vec<Color> {
        let x = (self.pos as f32).to_radians();
        let color = self.colors[self.current_color].at_brightness(x.sin());

        vec![color; usize::from(self.led_count)]
    }

    fn update(&mut self) {
        self.pos += 1;
        if self.pos == 180 {
            self.pos = 0;
            self.pick_color();
        }
    }

    fn get_sleep_millis(&self) -> u64 {
        self.sleep_millis
    }
}

impl ColorPattern for Breathing {
    fn new(leds: NonZeroUsize, speed: usize, brightness: f32, colors: &[Color]) -> Self {
        Self {
            led_count: leds,
            pos: 0,
            sleep_millis: Self::SPEEDS[speed.clamp(0, Self::SPEEDS.len())] as u64,
            colors: colors.iter().map(|c| c.at_brightness(brightness)).collect(),
            current_color: if colors.len() == 1 {
                0
            } else {
                thread_rng().gen_range(0..colors.len())
            },
        }
    }
}

impl Information for Breathing {
    fn get_info() -> PatternInfo {
        PatternInfo {
            pattern: crate::model::PatternName::Breathing,
            can_choose_color: true,
            animation_speeds: Self::SPEEDS.len(),
        }
    }
}
