from random import randrange

from utils import LightController, color_wheel


class RainbowRandom(LightController):
    time_to_sleep = 0.1

    def __init__(self, number_of_pixels: int):
        super().__init__(number_of_pixels)
        self.pixel_colors = [randrange(0, 256) for _ in range(self.num_pixels)]

    def pixels_for_frame(self):
        return [color_wheel(x) for x in self.pixel_colors]

    def update_frame(self):
        index = randrange(0, self.num_pixels)
        self.pixel_colors[index] = randrange(0, 256)
