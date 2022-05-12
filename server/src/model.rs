use serde::{Deserialize, Serialize};

#[derive(Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub enum PatternName {
    Breathing,
    Critmas,
    RainbowAcross,
    RainbowInPlace,
    Scroll,
    SolidColor,
    Twinkle,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct PatternInfo {
    pub pattern: PatternName,
    pub can_choose_color: bool,
    pub animation_speeds: usize,
}
