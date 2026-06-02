use std::num::NonZeroUsize;

use rand::{Rng, distributions::Uniform, thread_rng};

use crate::model::{ConfigurationSetting, PatternConfiguration, PatternInfo};

use super::{Color, ColorlessPattern, LightPattern};

static CRITMAS_COLORS: [Color; 5] = [
    // pink, orange, blue, red, green
    Color {
        red: 255,
        green: 90,
        blue: 160,
    },
    Color {
        red: 255,
        green: 160,
        blue: 25,
    },
    Color {
        red: 110,
        green: 190,
        blue: 230,
    },
    Color {
        red: 255,
        green: 75,
        blue: 50,
    },
    Color {
        red: 61,
        green: 156,
        blue: 23,
    },
];
pub struct Critmas {
    pos: u16,
    current_colors: Vec<u8>,
    sleep_millis: u64,
    global_brightness: u8,
}

impl Critmas {
    pub const SPEEDS: [usize; 3] = [35, 30, 20];

    fn reset_colors(&mut self) {
        self.current_colors
            .iter_mut()
            .for_each(|i| *i = thread_rng().gen_range(0..CRITMAS_COLORS.len() as u8));
    }
}

impl LightPattern for Critmas {
    fn get_frame(&self) -> Vec<Color> {
        self.current_colors
            .iter()
            .map(|c| {
                let x = (self.pos as f32).to_radians();
                CRITMAS_COLORS[*c as usize]
                    .at_brightness_percent(self.global_brightness)
                    .at_brightness(x.sin())
            })
            .collect()
    }

    fn update(&mut self) {
        self.pos += 1;
        if self.pos == 180 {
            self.pos = 0;
            self.reset_colors();
        }
    }

    fn get_sleep_millis(&self) -> u64 {
        self.sleep_millis
    }

    fn get_info() -> PatternInfo {
        PatternInfo {
            pattern_id: crate::model::PatternName::Critmas,
            name: "Critmas",
            description: &"Similar to `Breathing` pattern, but the colors are fixed, and randomized per bulb.",
            can_choose_color: false,
            animation_speeds: Self::SPEEDS.len(),
            additional_settings: vec![],
        }
    }

    fn get_current_settings(&self) -> crate::model::PatternConfiguration {
        PatternConfiguration {
            pattern_id: crate::model::PatternName::Critmas,
            animation_speed: Self::SPEEDS
                .iter()
                .position(|&s| s == self.sleep_millis as usize),
            brightness: self.global_brightness,
            colors: Option::None,
            additional_settings: vec![],
        }
    }
}

impl ColorlessPattern for Critmas {
    fn new(
        leds: NonZeroUsize,
        speed: usize,
        brightness: u8,
        _options: Vec<ConfigurationSetting>,
    ) -> Self {
        let range = Uniform::new(0, CRITMAS_COLORS.len() as u8);

        Self {
            pos: 0,
            sleep_millis: Self::SPEEDS[speed.clamp(0, Self::SPEEDS.len())] as u64,
            current_colors: thread_rng()
                .sample_iter(range)
                .take(usize::from(leds))
                .collect(),
            global_brightness: brightness,
        }
    }
}
