use std::{
    str::FromStr,
    sync::{
        atomic::{AtomicBool, Ordering},
        Arc,
    },
    thread::sleep,
    time::Duration,
};

use ws2818_rgb_led_spi_driver::{
    adapter_gen::WS28xxAdapter,
    adapter_spi::WS28xxSpiAdapter,
    encoding::SPI_BYTES_PER_RGB_PIXEL,
    timings::encoding::{WS2812_LOGICAL_ONE_BYTES, WS2812_LOGICAL_ZERO_BYTES},
};

fn main() {
    let finish = Arc::new(AtomicBool::new(false));

    let r = finish.clone();
    ctrlc::set_handler(move || {
        r.store(true, Ordering::SeqCst);
    })
    .expect("Failed to set ctrl+c handler D:");

    println!("Hello, world!");

    let mut adapter = WS28xxSpiAdapter::new("/dev/spidev0.0").unwrap();
    let num_leds = 50;
    let leds_in_use = 5;

    let mut pattern = RainbowInPlace::new(leds_in_use);
    loop {
        if finish.load(Ordering::SeqCst) {
            break;
        }

        {
            let mut spi_encoded = vec![];
            // set first `leds_in_use` leds to the current color
            pattern.get_next_frame().iter().for_each(|led| {
                spi_encoded.extend_from_slice(&encode_rgb(led.red, led.green, led.blue));
            });
            // set the remainder to blank so they don't get set later
            for _ in leds_in_use..num_leds {
                spi_encoded.extend_from_slice(&encode_rgb(0, 0, 0));
            }
            adapter.write_encoded_rgb(&spi_encoded).unwrap();

            // update state of pattern
            pattern.update();

            // sleep so it's not instant
            sleep(Duration::from_millis(10));
        }
    }

    println!("done");
    adapter.clear(num_leds as usize);
}

struct Color {
    red: u8,
    green: u8,
    blue: u8,
}

impl FromStr for Color {
    type Err = std::num::ParseIntError;

    fn from_str(hex_code: &str) -> Result<Self, Self::Err> {
        // u8::from_str_radix(src: &str, radix: u32) converts a string
        // slice in a given base to u8
        let red: u8 = u8::from_str_radix(&hex_code[1..3], 16)?;
        let green: u8 = u8::from_str_radix(&hex_code[3..5], 16)?;
        let blue: u8 = u8::from_str_radix(&hex_code[5..7], 16)?;

        Ok(Color { red, green, blue })
    }
}

trait LightPattern {
    fn get_next_frame(&self) -> Vec<Color>;
    fn update(&mut self);
}

trait ColorlessPattern: LightPattern {
    fn new(leds: u8) -> Self;
}

trait ColorPattern: LightPattern {
    fn new(leds: u8, colors: &[Color]) -> Self;
}

struct RainbowInPlace {
    pos: u8,
    leds: u8,
}

impl LightPattern for RainbowInPlace {
    fn get_next_frame(&self) -> Vec<Color> {
        std::iter::from_fn(|| Some(color_wheel(self.pos)))
            .take(self.leds as usize)
            .collect()
    }

    fn update(&mut self) {
        self.pos = self.pos.overflowing_add(1).0;
    }
}

impl ColorlessPattern for RainbowInPlace {
    fn new(leds: u8) -> Self {
        Self { pos: 0, leds }
    }
}

// Get a color value based on `pos`.
// The colors are a transition r - g - b - back to r.
fn color_wheel(pos: u8) -> Color {
    if pos < 85 {
        Color {
            red: pos * 3,
            green: 255 - pos * 3,
            blue: 0,
        }
    } else if pos < 170 {
        let p = pos - 85;
        Color {
            red: 255 - p * 3,
            green: 0,
            blue: p * 3,
        }
    } else {
        let p = pos - 170;
        Color {
            red: 0,
            green: p * 3,
            blue: 255 - p * 3,
        }
    }
}

// This was copied and edited from the ws2818_rgb_led_spi_driver crate cause
// the order of the things are _wrong_ for the WS2811 ;-;
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
