import neopixel
from typing import Tuple, List
Color = Tuple[int, int, int]


# Colors
class Colors:
    white = (255, 255, 255)
    black = (0, 0, 0)
    pink = (255, 90, 160)
    orange = (255, 160, 25)
    blue = (110, 190, 230)
    red = (255, 75, 50)
    green = (61, 156, 23)


def color_from_hex(hex: str):
    hex = hex.lstrip('#')
    length = len(hex)
    return tuple(int(hex[i:i + 2], 16) for i in range(0, length, 2))


class LightController:
    frames = 1
    time_to_sleep = 1

    def __init__(self, number_of_pixels):
        self.current_frame = 0
        self.num_pixels = number_of_pixels

    def pixels_for_frame(self):
        return [Colors.white for _ in range(self.num_pixels)]

    def update_frame(self):
        return


def color_at_brightness(color: Color, brightness: float):
    # return the given color at the given brightness
    if brightness <= 0:
        return Colors.black
    elif brightness >= 1:
        return color
    else:
        r = int(color[0] * brightness)
        g = int(color[1] * brightness)
        b = int(color[2] * brightness)
    return r, g, b


def color_wheel(pos):
    # Input a value 0 to 255 to get a color value.
    # The colours are a transition r - g - b - back to r.
    if pos < 0 or pos > 255:
        r = g = b = 0
    elif pos < 85:
        r = int(pos * 3)
        g = int(255 - pos*3)
        b = 0
    elif pos < 170:
        pos -= 85
        r = int(255 - pos*3)
        g = 0
        b = int(pos*3)
    else:
        pos -= 170
        r = 0
        g = int(pos*3)
        b = int(255 - pos*3)
    return r, g, b


def set_pixels(pixel_device: neopixel.NeoPixel, pixel_colors: List[Color]):
    for i in range(len(pixel_colors)):
        pixel_device[i] = pixel_colors[i]
    pixel_device.show()
