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
        match color_assignment {
            ColorAssignment::Ordered => Self::new_with_color(location, 0),
            ColorAssignment::Random => Self::new_with_random_color(location, color_count),
        }
    }

    fn new_with_color(location: i32, color_index: usize) -> Self {
        Self {
            location,
            color_index,
        }
    }

    fn new_with_random_color(location: i32, color_count: usize) -> Self {
        Self {
            location,
            color_index: random_range(0..color_count),
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
    burst_spacing: BurstSpacing,
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

    fn pick_next(&self, previous_color_index: Option<usize>, color_count: usize) -> usize {
        match self {
            ColorAssignment::Ordered => previous_color_index
                .map(|i| (i + 1) % color_count)
                .unwrap_or(0),
            ColorAssignment::Random => random_range(0..color_count),
        }
    }
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
pub struct BurstLength(usize);
impl BurstLength {
    const NAME: &str = "Burst Length";
    const DESCRIPTION: &str = "The total length of each burst.";
    const MIN: usize = 1;
    const MAX: usize = 10;
}
impl Default for BurstLength {
    fn default() -> Self {
        Self(5)
    }
}

#[derive(Clone, Copy)]
pub struct BurstSpacing(usize);
impl BurstSpacing {
    const NAME: &str = "Burst Spacing";
    const DESCRIPTION: &str = "Values smaller than or equal to the length of the led strip will result in more than one burst active at a time. Larger values will limit the number of bursts to 1 and will increase the time it takes for another to fire after the active burst leaves the end.";
    const MIN: usize = 3;
    const MAX: usize = 100;
}
impl Default for BurstSpacing {
    fn default() -> Self {
        // TODO: Would be nice for this to be configurable at the server level to account for different lengths of led strips.
        // A hardcoded value that's abritrarily chosen to have a
        // nice delay between single bursts on a 50-led strip.
        Self(65)
    }
}

impl Pew {
    const NAME: &str = "Pew";
    const SPEEDS: [u64; 3] = [100, 50, 17];

    fn parse_options(options: Vec<ConfigurationSetting>) -> PewOptions {
        let mut result = PewOptions::default();

        options.iter().for_each(|o| match o {
            ConfigurationSetting::Number { name, value } => {
                if name == ColorAssignment::NAME
                    && let Ok(value) = ColorAssignment::try_from(*value)
                {
                    result.color_choice = value;
                }
                if name == BurstLength::NAME
                    && let Ok(value) = usize::try_from(*value)
                {
                    result.burst_length =
                        BurstLength(value.clamp(BurstLength::MIN, BurstLength::MAX));
                }
                if name == BurstSpacing::NAME
                    && let Ok(value) = usize::try_from(*value)
                {
                    result.burst_spacing =
                        BurstSpacing(value.clamp(BurstSpacing::MIN, BurstSpacing::MAX))
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
            bursts: vec![Burst::new(0, options.color_choice, colors.len())],
        }
    }
}

impl LightPattern for Pew {
    fn get_frame(&self) -> Vec<Color> {
        let mut frame = vec![Color::BLACK; self.led_count];

        self.bursts.iter().for_each(|burst| {
            let burst_len = self.options.burst_length.0;

            // early return if the burst is currently entirely past the end of the led strip
            // this can happen if the `burst_spacing` is set more than `burst_length` larger than `led_count`
            if burst.location - burst_len as i32 > self.led_count as i32 {
                return;
            }

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
        for i in 0..self.bursts.len() {
            self.bursts[i].location += 1;
        }

        // Note: we add, then remove, in order to make sure we always have one burst in the list at all times

        // if the earliest burst is far enough ahead, start a new burst and put it at the start of the list
        let trigger_index = self.options.burst_spacing.0 + self.options.burst_length.0;
        if self.bursts[0].location == trigger_index as i32 {
            let color_index = self
                .options
                .color_choice
                .pick_next(Some(self.bursts[0].color_index), self.colors.len());
            self.bursts.insert(0, Burst::new_with_color(0, color_index));
        }

        // if the furthest burst has finished, remove it
        let end_index = i32::max(
            self.led_count as i32 + self.options.burst_length.0 as i32,
            trigger_index as i32,
        );
        if self.bursts.last().unwrap().location == end_index {
            self.bursts.remove(self.bursts.len() - 1);
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
                    description: Some(BurstLength::DESCRIPTION),
                    default_value: BurstLength::default().0 as usize,
                    min: BurstLength::MIN,
                    max: BurstLength::MAX,
                    step_size: 1,
                    is_percent: false,
                },
                PatternSettingInfo::Number {
                    name: BurstSpacing::NAME,
                    description: Some(BurstSpacing::DESCRIPTION),
                    default_value: BurstSpacing::default().0 as usize,
                    min: BurstSpacing::MIN,
                    max: BurstSpacing::MAX,
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
                ConfigurationSetting::Number {
                    name: BurstSpacing::NAME.to_string(),
                    value: self.options.burst_spacing.0 as usize,
                },
            ],
        }
    }
}
