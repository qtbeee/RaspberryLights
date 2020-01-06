from random import randrange

from utils import LightController


class RainbowRandom(LightController):
    time_to_sleep = 0.1

    def __init__(self, number_of_pixels: int):
        super().__init__(number_of_pixels)
        self.pixel_colors = [randrange(0, 256) for _ in range(self.num_pixels)]

    def pixels_for_frame(self):
        return [wheel(x) for x in self.pixel_colors]

    def update_frame(self):
        index = randrange(0, self.num_pixels)
        self.pixel_colors[index] = randrange(0, 256)


def wheel(pos):
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


# def rainbow_cycle(wait):
#     index = randrange(0, num_pixels)
#     pixel_color = (randrange(0, 255) * 256 // num_pixels)
#     pixels[index] = wheel(pixel_color & 255)
#     pixels.show()
#     time.sleep(wait)
#
#
# def main():
#     for i in range(num_pixels):
#         pixel_color = (randrange(0, 255) * 256 // num_pixels)
#         pixels[i] = wheel(pixel_color & 255)
#     pixels.show()
#     try:
#         while True:
#             rainbow_cycle(0.1)
#
#     except (KeyboardInterrupt, SystemExit):
#         pixels.deinit()
#
#
# main()
