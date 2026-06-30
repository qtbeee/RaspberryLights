use rand::random_range;

use crate::{
    light_pattern::{Color, ColorPattern, LightPattern},
    model::{ConfigurationSetting, PatternConfiguration, PatternInfo, PatternSettingInfo},
};

struct Burst {
    location: i32,
    color_index: usize,
}
impl Burst {
    fn new(location: i32, color_assignment: ColorAssignment, color_count: usize) -> Self {
        Self {
            location,
            color_index: match color_assignment {
                ColorAssignment::Ordered => 0,
                ColorAssignment::Random => random_range(0..color_count),
            },
        }
    }
}

pub struct Pew {
    led_count: usize,
    sleep_millis: u64,
    brightness: u8,
    colors: Vec<Color>,
    options: PewOptions,

    // state
    bursts: Vec<Burst>,
}

#[derive(Default, Clone, Copy)]
pub struct PewOptions {
    reverse: ReverseAnimation,
    color_choice: ColorAssignment,
    burst_length: BurstLength,
}

#[derive(Default, Clone, Copy)]
pub struct ReverseAnimation(bool);
impl ReverseAnimation {
    const NAME: &str = "Reverse Animation";
}

#[derive(Default, Clone, Copy)]
pub enum ColorAssignment {
    #[default]
    Ordered,
    Random,
}
impl ColorAssignment {
    const NAME: &str = "Color Assignment";
    const STRS: [&str; 2] = ["Ordered", "Random"];
}
impl TryFrom<usize> for ColorAssignment {
    type Error = &'static str;

    fn try_from(value: usize) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(ColorAssignment::Ordered),
            1 => Ok(ColorAssignment::Random),
            _ => Err("Out of bounds value"),
        }
    }
}

#[derive(Clone, Copy)]
pub struct BurstLength(u8);
impl BurstLength {
    const NAME: &str = "Burst Length";
    const MIN: usize = 1;
    const MAX: usize = 5;
}
impl Default for BurstLength {
    fn default() -> Self {
        Self(5)
    }
}

impl Pew {
    const NAME: &str = "Pew";
    const SPEEDS: [u64; 3] = [100, 50, 17];

    fn parse_options(options: Vec<ConfigurationSetting>) -> PewOptions {
        let mut result = PewOptions::default();

        options.iter().for_each(|o| match o {
            ConfigurationSetting::Number { name, value } => {
                if name == BurstLength::NAME
                    && let Ok(value) = usize::try_from(*value)
                {
                    result.burst_length =
                        BurstLength(value.clamp(BurstLength::MIN, BurstLength::MAX) as u8);
                }
                if name == ColorAssignment::NAME
                    && let Ok(value) = ColorAssignment::try_from(*value)
                {
                    result.color_choice = value;
                }
            }
            ConfigurationSetting::Boolean { name, value } => {
                if name == ReverseAnimation::NAME {
                    result.reverse = ReverseAnimation(*value);
                }
            }
        });

        result
    }

    fn pick_next_color(&mut self, index: usize) {
        match self.options.color_choice {
            ColorAssignment::Ordered => {
                let current = self.bursts[index].color_index;
                self.bursts[index].color_index = (current + 1) % self.colors.len();
            }
            ColorAssignment::Random => {
                self.bursts[index].color_index = random_range(0..self.colors.len())
            }
        }
    }
}

impl ColorPattern for Pew {
    fn new(
        leds: std::num::NonZeroUsize,
        speed: usize,
        brightness: u8,
        colors: &[super::Color],
        options: Vec<crate::model::ConfigurationSetting>,
    ) -> Self {
        let options = Self::parse_options(options);

        Self {
            sleep_millis: Self::SPEEDS[speed.clamp(0, Self::SPEEDS.len() - 1)],
            options,
            brightness,
            colors: colors.into(),
            led_count: usize::from(leds),
            bursts: vec![Burst::new(0, options.color_choice, colors.len())], // TODO: handle more than one burst
        }
    }
}

impl LightPattern for Pew {
    fn get_frame(&self) -> Vec<Color> {
        let mut frame = vec![Color::BLACK; self.led_count];

        self.bursts.iter().for_each(|burst| {
            let burst_len = self.options.burst_length.0;

            for i in 0..burst_len {
                let brightness = if burst_len == 1 {
                    1f32
                } else {
                    // y = -0.9(x/(burst_len-1))^2 + 1
                    -0.9 * (i as f32 / (burst_len - 1) as f32).powi(2) + 1f32
                };

                let color = self.colors[burst.color_index]
                    .at_brightness_percent(self.brightness)
                    .at_brightness(brightness);

                let led_position = if self.options.reverse.0 {
                    self.led_count as i32 - 1 - (burst.location - i as i32)
                } else {
                    burst.location - i as i32
                };

                if led_position >= 0 && led_position < self.led_count as i32 {
                    frame[led_position as usize] = color;
                }
            }
        });

        frame
    }

    fn update(&mut self) {
        let mut looped_bursts = vec![];
        for (i, b) in self.bursts.iter_mut().enumerate() {
            let old = b.location;
            b.location += 1;
            b.location %= (self.led_count + 15) as i32; // TODO: should this number vary based on other settings?

            if old > b.location {
                looped_bursts.push(i);
            }
        }

        for i in looped_bursts.iter() {
            self.pick_next_color(*i);
        }
    }

    fn get_sleep_millis(&self) -> u64 {
        self.sleep_millis
    }

    fn get_info() -> PatternInfo
    where
        Self: Sized,
    {
        PatternInfo {
            pattern_id: crate::model::PatternName::Pew,
            name: Self::NAME,
            description: "Bursts of color travel across.",
            can_choose_color: true,
            animation_speeds: Self::SPEEDS.len(),
            additional_settings: vec![
                PatternSettingInfo::Boolean {
                    name: ReverseAnimation::NAME,
                    description: None,
                    default_value: false,
                },
                PatternSettingInfo::MultipleChoice {
                    name: ColorAssignment::NAME,
                    description: Some(
                        "If more than one color is provided, choose how colors are assigned to each burst.",
                    ),
                    options: ColorAssignment::STRS.into(),
                    default_value: ColorAssignment::default() as usize,
                },
                PatternSettingInfo::Number {
                    name: BurstLength::NAME,
                    description: None,
                    default_value: BurstLength::default().0 as usize,
                    min: BurstLength::MIN,
                    max: BurstLength::MAX,
                    step_size: 1,
                    is_percent: false,
                },
            ],
        }
    }

    fn get_current_settings(&self) -> PatternConfiguration {
        PatternConfiguration {
            pattern_id: crate::model::PatternName::Pew,
            animation_speed: Self::SPEEDS.iter().position(|&s| s == self.sleep_millis),
            brightness: self.brightness,
            colors: Some(self.colors.clone()),
            additional_settings: vec![
                ConfigurationSetting::Boolean {
                    name: ReverseAnimation::NAME.to_string(),
                    value: self.options.reverse.0,
                },
                ConfigurationSetting::Number {
                    name: ColorAssignment::NAME.to_string(),
                    value: self.options.color_choice as usize,
                },
                ConfigurationSetting::Number {
                    name: BurstLength::NAME.to_string(),
                    value: self.options.burst_length.0 as usize,
                },
            ],
        }
    }
}
