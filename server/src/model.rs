use serde::{Deserialize, Serialize};

use crate::light_pattern::Color;

#[derive(Deserialize, Serialize, Clone)]
#[serde(rename_all = "snake_case")]
pub enum PatternName {
    Breathing,
    RainbowAcross,
    RainbowInPlace,
    Scroll,
    SolidColor,
    Twinkle,
}

#[derive(Serialize)]
#[serde(untagged)]
pub enum PatternSetting {
    MultipleChoice {
        name: &'static str,
        description: Option<&'static str>,
        options: Vec<&'static str>,
    },
    #[serde(rename_all = "camelCase")]
    Number {
        name: &'static str,
        description: Option<&'static str>,
        min: usize,
        max: usize,
        is_percent: bool,
    },
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct PatternInfo {
    pub pattern_id: PatternName,
    pub name: &'static str,
    pub description: &'static str,
    pub can_choose_color: bool,
    pub animation_speeds: usize,
    pub additional_settings: Vec<PatternSetting>,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct ConfigurationSetting {
    pub name: String,
    pub value: usize,
}

#[derive(Serialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct PatternConfiguration {
    pub pattern_id: PatternName,
    pub animation_speed: Option<usize>,
    pub brightness: u8,
    pub colors: Option<Vec<Color>>,
    pub additional_settings: Vec<ConfigurationSetting>,
}
