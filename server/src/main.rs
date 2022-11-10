mod light_pattern;
mod model;
mod pattern;

use axum::{routing::get, Extension, Router};
use light_pattern::{ColorlessPattern, LightPattern, RainbowInPlace};

use std::{num::NonZeroUsize, time::Duration};
use tokio::{sync::mpsc::error::TryRecvError, time::sleep};
use tower_http::trace::TraceLayer;
use ws2818_rgb_led_spi_driver::{
    adapter_gen::WS28xxAdapter,
    adapter_spi::WS28xxSpiAdapter,
    encoding::SPI_BYTES_PER_RGB_PIXEL,
    timings::encoding::{WS2812_LOGICAL_ONE_BYTES, WS2812_LOGICAL_ZERO_BYTES},
};

use crate::pattern::{get_patterns, set_pattern};

#[tokio::main]
async fn main() {
    // Setup:
    // - Make a channel
    // - Give the sending end to the post handler
    // - Start the server in a background thread
    // - Start the function for running the lights and give it the receiving end
    let leds_in_use = NonZeroUsize::new(50).unwrap();
    let total_leds: usize = 50;

    let (send, rcv) = tokio::sync::mpsc::channel(1);

    let app = Router::new()
        .route("/pattern", get(get_patterns).post(set_pattern))
        .layer(TraceLayer::new_for_http())
        .layer(Extension(send))
        .layer(Extension(leds_in_use));

    // NOTE: to get around the spi handler not being `Send`, we're running the axum server
    // in a separate thread instead of the led runner function!
    let handler = tokio::spawn(
        axum::Server::bind(&"0.0.0.0:5000".parse().unwrap()).serve(app.into_make_service()),
    );

    ctrlc::set_handler(move || {
        handler.abort();
    })
    .expect("Failed to set ctrl+c handler D:");

    run_lights(rcv, total_leds, leds_in_use).await;
}

async fn run_lights(
    mut receiver: tokio::sync::mpsc::Receiver<Box<dyn LightPattern + Send>>,
    total_leds: usize,
    leds_in_use: NonZeroUsize,
) {
    // Set up spi pin
    let mut attempts = 0;
    let mut adapter = loop {
        attempts += 1;
       if let Ok(adapter) = WS28xxSpiAdapter::new("/dev/spidev0.0") {
         break adapter;
       } else {
         println!("attempt {}: spi device not found. sleeping for 5 seconds", attempts);
         sleep(Duration::from_secs(5)).await;
       }
    };

    let mut pattern: Box<dyn LightPattern> = Box::new(RainbowInPlace::new(leds_in_use, 0));

    loop {
        match receiver.try_recv() {
            Ok(new_pattern) => {
                // pattern = pattern_from_json(new_pattern);
                pattern = new_pattern;
            }
            // If the server closes the connection, we should stop too!
            // TODO: clear lights before we're done
            Err(TryRecvError::Disconnected) => {
                adapter.clear(usize::from(leds_in_use));
                return;
            }

            Err(_) => (),
        }

        // Advance the light strip state for the current pattern
        let mut spi_encoded = vec![];

        // set the leds in use to the colors specified by the light pattern
        pattern.get_frame().iter().for_each(|led| {
            spi_encoded.extend_from_slice(&encode_rgb(led.red, led.green, led.blue));
        });

        // set the remainder to blank so they don't get set later
        for _ in usize::from(leds_in_use)..total_leds {
            spi_encoded.extend_from_slice(&encode_rgb(0, 0, 0));
        }
        adapter.write_encoded_rgb(&spi_encoded).unwrap();

        // update state of pattern
        pattern.update();

        // sleep so it's not instant
        sleep(Duration::from_millis(pattern.get_sleep_millis())).await;
    }
}

// This was copied and edited from the ws2818_rgb_led_spi_driver crate cause
// the order of the rgb bytes are _wrong_ for the WS2811 ;-;
const COLORS: usize = 3; // r, g, b
pub fn encode_rgb(r: u8, g: u8, b: u8) -> [u8; SPI_BYTES_PER_RGB_PIXEL] {
    let mut spi_bytes: [u8; SPI_BYTES_PER_RGB_PIXEL] = [0; SPI_BYTES_PER_RGB_PIXEL];
    let mut spi_bytes_i = 0;
    let rgb = [r, g, b]; // order specified by specification
    for color in 0..COLORS {
        let mut color_bits = rgb[color];
        for _ in 0..8 {
            // for each bit of our color; starting with most significant
            // we encode now one color bit in two spi bytes (for proper timings along with our frequency)
            if 0b10000000 & color_bits == 0 {
                spi_bytes[spi_bytes_i] = WS2812_LOGICAL_ZERO_BYTES[0];
                spi_bytes[spi_bytes_i + 1] = WS2812_LOGICAL_ZERO_BYTES[1];
            } else {
                spi_bytes[spi_bytes_i] = WS2812_LOGICAL_ONE_BYTES[0];
                spi_bytes[spi_bytes_i + 1] = WS2812_LOGICAL_ONE_BYTES[1];
            }
            color_bits = color_bits << 1;
            spi_bytes_i += 2; // update array index;
        }
    }
    debug_assert_eq!(spi_bytes_i, SPI_BYTES_PER_RGB_PIXEL);
    spi_bytes
}
