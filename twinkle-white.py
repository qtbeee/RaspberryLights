from server import LightController, color_at_brightness, Colors
from random import randrange
from math import sin, radians


class TwinkleWhite(LightController):
    frames = 360
    time_to_sleep = 0.003

    def __init__(self, number_of_pixels: int):
        super().__init__(number_of_pixels)
        self.pixel_colors = [randrange(0, 360) for _ in range(self.num_pixels)]

    def _color_for_pixel(self, index: int):
        return color_at_brightness(Colors.white, (sin(radians(self.pixel_colors[index])) / 2) + 0.8)

    def pixels_for_frame(self):
        return [self._color_for_pixel(x) for x in range(self.num_pixels)]

    def update_frame(self):
        for index in range(self.num_pixels):
            self.pixel_colors[index] = (self.pixel_colors[index] + 10) % 360

# import board
# import neopixel
# import time
# from random import randrange
# from typing import Tuple
# from math import sin, radians
#
# Color = Tuple[int, int, int]
#
# num_pixels = 50
# pixels = neopixel.NeoPixel(board.D18, num_pixels, brightness=0.1, auto_write=False, pixel_order=neopixel.RGB)
#
# # colors
# black = (0, 0, 0)
# white = (255, 255, 255)
#
# # positions of each pixel on the sin curve, in degrees
# pixel_xs = []
#
#
# def init_pixel_brightnesses():
#     global pixel_xs
#     pixel_xs = [randrange(0, 360) for x in range(num_pixels)]
#
#
# def update_pixel_brightnesses(speed: int):
#     for index in range(num_pixels):
#         pixel_xs[index] = (pixel_xs[index] + speed) % 360
#
#
# def color_for_pixel(index):
#     brightness = (sin(radians(pixel_xs[index])) / 2) + 0.8
#     return color_at_brightness(white, brightness)
#
#
# def color_at_brightness(color: Color, brightness: float):
#     # return the given color at the given brightness
#     if brightness <= 0:
#         return black
#     elif brightness >= 1:
#         return color
#     else:
#         r = int(color[0] * brightness)
#         g = int(color[1] * brightness)
#         b = int(color[2] * brightness)
#     return r, g, b
#
#
# def set_pixels():
#     for i in range(len(pixel_xs)):
#         pixels[i] = color_for_pixel(i)
#     pixels.show()
#
#
# def main():
#     # initialize pixel_colors array
#     init_pixel_brightnesses()
#     set_pixels()
#     try:
#         while True:
#             update_pixel_brightnesses(10)
#             set_pixels()
#             time.sleep(0.002)
#
#     except (KeyboardInterrupt, SystemExit):
#         pixels.deinit()
#
#
# main()
