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
pub enum PatternSettingInfo {
    #[serde(rename_all = "camelCase")]
    MultipleChoice {
        name: &'static str,
        description: Option<&'static str>,
        options: Vec<&'static str>,
        default_value: usize,
    },
    #[serde(rename_all = "camelCase")]
    Number {
        name: &'static str,
        description: Option<&'static str>,
        default_value: usize,
        min: usize,
        max: usize,
        step_size: usize,
        is_percent: bool,
    },
    #[serde(rename_all = "camelCase")]
    Boolean {
        name: &'static str,
        description: Option<&'static str>,
        default_value: bool,
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
    pub additional_settings: Vec<PatternSettingInfo>,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(untagged)]
pub enum ConfigurationSetting {
    Number { name: String, value: usize },
    Boolean { name: String, value: bool },
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
