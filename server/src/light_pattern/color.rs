use std::str::FromStr;

#[derive(Clone, Copy, Debug)]
pub struct Color {
    pub red: u8,
    pub green: u8,
    pub blue: u8,
}

impl Color {
    // Get a color value based on `pos`.
    // The colors are a transition r - g - b - back to r.
    pub fn wheel(pos: u8) -> Color {
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

    /// brightness between 0 and 1
    pub fn at_brightness(&self, brightness: f32) -> Color {
        let brightness = brightness.clamp(0.0, 1.0);
        Color {
            red: ((self.red as f32) * brightness) as u8,
            green: ((self.green as f32) * brightness) as u8,
            blue: ((self.blue as f32) * brightness) as u8,
        }
    }
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

impl From<(u8, u8, u8)> for Color {
    fn from(rgb: (u8, u8, u8)) -> Self {
        Self {
            red: rgb.0,
            green: rgb.1,
            blue: rgb.2,
        }
    }
}
