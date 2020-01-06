from math import radians, sin
from random import randrange

from utils import color_at_brightness, Colors, LightController


class Critmas(LightController):
    frames = 500
    time_to_sleep = 0.01
    colors = [Colors.pink, Colors.orange, Colors.blue, Colors.red, Colors.green]

    def __init__(self, number_of_pixels: int):
        super().__init__(number_of_pixels)
        self.pixel_colors = None
        self._reset_pixel_colors()

    def _reset_pixel_colors(self):
        self.pixel_colors = [randrange(0, len(self.colors)) for _ in range(self.num_pixels)]

    def _brightness_for_frame(self):
        return abs(sin(radians(360 / self.frames) * self.current_frame))

    def _color_for_pixel(self, index: int):
        return color_at_brightness(self.colors[self.pixel_colors[index]], self._brightness_for_frame())

    def pixels_for_frame(self):
        return [self._color_for_pixel(x) for x in range(self.num_pixels)]

    def update_frame(self):
        self.current_frame += 1
        if self.current_frame >= self.frames:
            self.current_frame = 0
            self._reset_pixel_colors()
