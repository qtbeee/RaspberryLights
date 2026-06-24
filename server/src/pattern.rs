use std::{
    num::NonZeroUsize,
    str::FromStr,
    sync::{Arc, Mutex},
};

use axum::{
    Json,
    extract::{self, State},
};
use serde::{Deserialize, Serialize};

use crate::{
    light_pattern::{
        Breathing, Color, ColorPattern, ColorlessPattern, LightPattern, RainbowAcross,
        RainbowInPlace, Scroll, SolidColor, Twinkle,
    },
    model::{ConfigurationSetting, PatternConfiguration, PatternInfo, PatternName},
};

pub struct ServerState {
    pub sender: tokio::sync::mpsc::Sender<Box<dyn LightPattern + Send>>,
    pub leds_in_use: NonZeroUsize,
    pub current_pattern_settings: Mutex<PatternConfiguration>,
}

#[derive(Serialize)]
pub struct Patterns {
    pub patterns: Vec<PatternInfo>,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
/// `animation_speed` assumes a zero-based index.
pub struct PatternRequest {
    pub pattern_id: PatternName,
    pub colors: Option<Vec<String>>,
    pub animation_speed: Option<usize>,
    pub brightness: Option<u8>,
    pub additional_settings: Option<Vec<ConfigurationSetting>>,
}

pub async fn get_patterns() -> Json<Patterns> {
    Json(Patterns {
        patterns: vec![
            Breathing::get_info(),
            RainbowAcross::get_info(),
            RainbowInPlace::get_info(),
            Scroll::get_info(),
            SolidColor::get_info(),
            Twinkle::get_info(),
        ],
    })
}

pub async fn get_current_pattern(
    State(server_state): State<Arc<ServerState>>,
) -> Json<PatternConfiguration> {
    Json(
        server_state
            .current_pattern_settings
            .lock()
            .unwrap()
            .clone(),
    )
}

pub async fn set_pattern(
    State(server_state): State<Arc<ServerState>>,
    Json(request): extract::Json<PatternRequest>,
) {
    let colors = request.colors.as_ref().map(|c| {
        c.iter()
            .map(|c| Color::from_str(c).unwrap())
            .collect::<Vec<_>>()
    });
    let animation_speed = request.animation_speed.unwrap_or(0);
    let brightness = request.brightness.map(|b| b.clamp(10, 100)).unwrap_or(100);
    println!("additional settings -> {:?}", request.additional_settings);
    let options = request.additional_settings.unwrap_or(vec![]);

    let pattern: Box<dyn LightPattern + Send> = match request.pattern_id {
        PatternName::Breathing => Box::new(Breathing::new(
            server_state.leds_in_use,
            animation_speed,
            brightness,
            &colors.expect("breathing pattern needs at least one color!"),
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

    // If we made it this far then the pattern is valid and we can save it
    // to the server state for `GET /pattern` usage
    {
        let mut lock = server_state.current_pattern_settings.lock().unwrap();
        *lock = pattern.get_current_settings();
    }
    let _ = server_state.sender.send(pattern).await;
}
