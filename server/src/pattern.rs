use std::{num::NonZeroUsize, str::FromStr, sync::Arc};

use axum::{Extension, Json, extract};
use serde::{Deserialize, Serialize};
use serde_json::{Map, Value};

use crate::{
    light_pattern::{
        Breathing, BreathingConfigurable, Color, ColorPattern, ColorlessPattern, Critmas,
        Information, LightPattern, RainbowAcross, RainbowInPlace, Scroll, SolidColor, Twinkle,
    },
    model::{PatternConfiguration, PatternInfo, PatternName},
};

pub struct ServerState {
    pub sender: tokio::sync::mpsc::Sender<Box<dyn LightPattern + Send>>,
    pub leds_in_use: NonZeroUsize,
    pub current_pattern_settings: PatternConfiguration,
}

#[derive(Serialize)]
pub struct Patterns {
    pub patterns: Vec<PatternInfo>,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
/// `animation_speed` assumes a zero-based index.
pub struct PatternRequest {
    pub pattern: PatternName,
    pub colors: Option<Vec<String>>,
    pub animation_speed: Option<usize>,
    pub brightness: Option<u8>,
    pub additional_options: Option<Map<String, Value>>,
}

pub async fn get_patterns() -> Json<Patterns> {
    Json(Patterns {
        patterns: vec![
            Breathing::get_info(),
            BreathingConfigurable::get_info(),
            Critmas::get_info(),
            RainbowAcross::get_info(),
            RainbowInPlace::get_info(),
            Scroll::get_info(),
            SolidColor::get_info(),
            Twinkle::get_info(),
        ],
    })
}

pub async fn get_current_pattern(
    Extension(server_state): Extension<Arc<ServerState>>,
) -> Json<PatternConfiguration> {
    Json(server_state.current_pattern_settings.clone())
}

pub async fn set_pattern(
    Extension(server_state): Extension<Arc<ServerState>>,
    Json(request): extract::Json<PatternRequest>,
) {
    let colors = request.colors.as_ref().map(|c| {
        c.iter()
            .map(|c| Color::from_str(c).unwrap())
            .collect::<Vec<_>>()
    });
    let animation_speed = request.animation_speed.unwrap_or(0);
    let brightness = request.brightness.map(|b| b.clamp(10, 100)).unwrap_or(100);
    let options = request.additional_options.unwrap_or(Map::new());

    let pattern: Box<dyn LightPattern + Send> = match request.pattern {
        PatternName::Breathing => Box::new(Breathing::new(
            server_state.leds_in_use,
            animation_speed,
            brightness,
            &colors.expect("breathing pattern needs at least one color!"),
            options,
        )),
        PatternName::BreathingConfigurable => Box::new(BreathingConfigurable::new(
            server_state.leds_in_use,
            animation_speed,
            brightness,
            &colors.expect("breating pattern needs at least one color!"),
            options,
        )),
        PatternName::Critmas => Box::new(Critmas::new(
            server_state.leds_in_use,
            animation_speed,
            brightness,
            options,
        )),
        PatternName::RainbowAcross => Box::new(RainbowAcross::new(
            server_state.leds_in_use,
            animation_speed,
            brightness,
            options,
        )),
        PatternName::RainbowInPlace => Box::new(RainbowInPlace::new(
            server_state.leds_in_use,
            animation_speed,
            brightness,
            options,
        )),
        PatternName::Scroll => Box::new(Scroll::new(
            server_state.leds_in_use,
            animation_speed,
            brightness,
            &colors.expect("scroll pattern needs at least one color!"),
            options,
        )),
        PatternName::SolidColor => Box::new(SolidColor::new(
            server_state.leds_in_use,
            animation_speed,
            brightness,
            &colors.expect("solid color pattern needs at least one color!"),
            options,
        )),
        PatternName::Twinkle => Box::new(Twinkle::new(
            server_state.leds_in_use,
            animation_speed,
            brightness,
            &colors.expect("twinkle pattern needs at least one color!"),
            options,
        )),
    };

    let _ = server_state.sender.send(pattern).await;
}
