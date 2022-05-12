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
    pub const SPEEDS: [usize; 1] = [30];

    fn pick_color(&mut self) {
        if self.colors.len() == 1 {
            return;
        }
        self.current_color = thread_rng().gen_range(0..self.colors.len());
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
    fn new(leds: NonZeroUsize, speed: usize, colors: &[Color]) -> Self {
        Self {
            led_count: leds,
            pos: 0,
            sleep_millis: Self::SPEEDS[speed.clamp(0, Self::SPEEDS.len())] as u64,
            colors: colors.to_vec(),
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
