use std::{num::NonZeroUsize, str::FromStr};

use axum::{extract, Extension, Json};
use serde::{Deserialize, Serialize};

use crate::{
    light_pattern::{
        Breathing, Color, ColorPattern, ColorlessPattern, Critmas, Information, LightPattern,
        RainbowAcross, RainbowInPlace, Scroll, SolidColor, Twinkle,
    },
    model::{PatternInfo, PatternName},
};

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
    pub brightness: Option<f32>,
}

pub async fn get_patterns() -> Json<Patterns> {
    Json(Patterns {
        patterns: vec![
            Breathing::get_info(),
            Critmas::get_info(),
            RainbowAcross::get_info(),
            RainbowInPlace::get_info(),
            Scroll::get_info(),
            SolidColor::get_info(),
            Twinkle::get_info(),
        ],
    })
}

pub async fn set_pattern(
    Extension(sender): Extension<tokio::sync::mpsc::Sender<Box<dyn LightPattern + Send>>>,
    Extension(leds_in_use): Extension<NonZeroUsize>,
    Json(request): extract::Json<PatternRequest>,
) {
    let colors = request.colors.as_ref().map(|c| {
        c.iter()
            .map(|c| Color::from_str(c).unwrap())
            .collect::<Vec<_>>()
    });
    let animation_speed = request.animation_speed.unwrap_or(0);
    let brightness = request.brightness.map(|b| b.clamp(0.1, 1.0)).unwrap_or(1.0);

    let pattern: Box<dyn LightPattern + Send> = match request.pattern {
        PatternName::Breathing => Box::new(Breathing::new(
            leds_in_use,
            animation_speed,
            brightness,
            &colors.expect("breathing pattern needs at least one color!"),
        )),
        PatternName::Critmas => Box::new(Critmas::new(leds_in_use, animation_speed, brightness)),
        PatternName::RainbowAcross => Box::new(RainbowAcross::new(
            leds_in_use,
            animation_speed,
            brightness,
        )),
        PatternName::RainbowInPlace => Box::new(RainbowInPlace::new(
            leds_in_use,
            animation_speed,
            brightness,
        )),
        PatternName::Scroll => Box::new(Scroll::new(
            leds_in_use,
            animation_speed,
            brightness,
            &colors.expect("scroll pattern needs at least one color!"),
        )),
        PatternName::SolidColor => Box::new(SolidColor::new(
            leds_in_use,
            animation_speed,
            brightness,
            &colors.expect("solid color pattern needs at least one color!"),
        )),
        PatternName::Twinkle => Box::new(Twinkle::new(
            leds_in_use,
            animation_speed,
            brightness,
            &colors.expect("twinkle pattern needs at least one color!"),
        )),
    };

    let _ = sender.send(pattern).await;
}
