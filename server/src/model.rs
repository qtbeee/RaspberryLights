use serde::{Deserialize, Serialize};

use crate::light_pattern::Color;

#[derive(Deserialize, Serialize, Clone)]
#[serde(rename_all = "camelCase")]
pub enum PatternName {
    Breathing,
    BreathingConfigurable,
    Critmas,
    RainbowAcross,
    RainbowInPlace,
    Scroll,
    SolidColor,
    Twinkle,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
#[serde(untagged)]
pub enum PatternSetting {
    MultipleChoice {
        name: &'static str,
        description: Option<&'static str>,
        options: Vec<&'static str>,
    },
    Number {
        name: &'static str,
        description: Option<&'static str>,
        min: usize,
        max: usize,
    },
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct PatternInfo {
    pub pattern: PatternName,
    pub description: &'static str,
    pub can_choose_color: bool,
    pub animation_speeds: usize,
    pub additional_settings: Vec<PatternSetting>,
}

#[derive(Serialize, Clone)]
#[serde(untagged)]
pub enum ConfigurationSetting {
    MultipleChoice {
        name: &'static str,
        value: String,
    },
    #[serde(rename_all = "camelCase")]
    Number {
        name: &'static str,
        value: usize,
        is_percent: bool,
    },
}

#[derive(Serialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct PatternConfiguration {
    pub name: PatternName,
    pub animation_speed: Option<usize>,
    pub brightness: u8,
    pub colors: Option<Vec<Color>>,
    pub additional_settings: Vec<ConfigurationSetting>,
}
