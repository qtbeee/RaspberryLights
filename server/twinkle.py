from random import randrange
from math import sin, radians
from utils import color_at_brightness, LightController, Color


class Twinkle(LightController):
    frames = 360
    time_to_sleep = 0.003

    def __init__(self, number_of_pixels: int, color: Color):
        super().__init__(number_of_pixels)
        self.color = color
        self.pixel_colors = [randrange(0, 360) for _ in range(self.num_pixels)]

    def _color_for_pixel(self, index: int):
        return color_at_brightness(self.color, (sin(radians(self.pixel_colors[index])) / 2) + 0.8)

    def pixels_for_frame(self):
        return [self._color_for_pixel(x) for x in range(self.num_pixels)]

    def update_frame(self):
        for index in range(self.num_pixels):
            self.pixel_colors[index] = (self.pixel_colors[index] + 10) % 360
