from random import randrange
import board
import neopixel
import time
from typing import Tuple, List
from math import sin, radians

Color = Tuple[int, int, int]


# Colors
class Colors:
    white = (255, 255, 255)


white = (255, 255, 255)
black = (0, 0, 0)
pink = (255, 90, 160)
orange = (255, 160, 25)
blue = (110, 190, 230)
red = (255, 75, 50)
green = (61, 156, 23)

christmas_colors = [pink, orange, blue, red, green]

num_pixels = 50
pixels = neopixel.NeoPixel(board.D18, num_pixels, brightness=0.1, auto_write=False, pixel_order=neopixel.RGB)


def color_at_brightness(color: Color, brightness: float):
    # return the given color at the given brightness
    if brightness <= 0:
        return black
    elif brightness >= 1:
        return color
    else:
        r = int(color[0] * brightness)
        g = int(color[1] * brightness)
        b = int(color[2] * brightness)
    return r, g, b


def set_pixels(pixel_colors: List[Color]):
    for i in range(len(pixel_colors)):
        pixels[i] = pixel_colors[i]
    pixels.show()


class LightController:
    frames = 1
    time_to_sleep = 1

    def __init__(self, number_of_pixels):
        self.current_frame = 0
        self.num_pixels = number_of_pixels

    def pixels_for_frame(self):
        return [white for _ in range(num_pixels)]

    def update_frame(self):
        return


class Critmas(LightController):
    frames = 500
    time_to_sleep = 0.01
    colors = [pink, orange, blue, red, green]

    def __init__(self, number_of_pixels: int):
        super().__init__(number_of_pixels)
        self.pixel_colors = None
        self._reset_pixel_colors()

    def _reset_pixel_colors(self):
        self.pixel_colors = [randrange(0, len(self.colors)) for _ in range(self.num_pixels)]

    def _brightness_for_frame(self):
        return abs(sin(radians(360 / self.frames) * self.current_frame))

    def pixels_for_frame(self):
        return [color_at_brightness(self.colors[self.pixel_colors[x]], self._brightness_for_frame()) for x in range(self.num_pixels)]

    def update_frame(self):
        self.current_frame += 1
        if self.current_frame >= self.frames:
            self.current_frame = 0
            self._reset_pixel_colors()


class TwinkleWhite(LightController):
    frames = 360
    time_to_sleep = 0.003

    def __init__(self, number_of_pixels: int):
        super().__init__(number_of_pixels)
        self.pixel_colors = [randrange(0, 360) for _ in range(self.num_pixels)]

    def _color_for_pixel(self, index: int):
        return color_at_brightness(white, (sin(radians(self.pixel_colors[index])) / 2) + 0.8)

    def pixels_for_frame(self):
        return [self._color_for_pixel(x) for x in range(self.num_pixels)]

    def update_frame(self):
        for index in range(num_pixels):
            self.pixel_colors[index] = (self.pixel_colors[index] + 10) % 360


def main():
    # pattern = Critmas(num_pixels)
    pattern = TwinkleWhite(num_pixels)
    try:
        while True:
            pixel_values = pattern.pixels_for_frame()
            set_pixels(pixel_values)
            pattern.update_frame()
            time.sleep(pattern.time_to_sleep)

    except (KeyboardInterrupt, SystemExit):
        pixels.deinit()


if __name__ == '__main__':
    main()
