import board
import neopixel
import time
from typing import Tuple

Color = Tuple[int, int, int]

num_pixels = 50
pixels = neopixel.NeoPixel(board.D18, num_pixels, brightness=0.1, auto_write=False, pixel_order=neopixel.RGB)

# colors
black = (0, 0, 0)
white = (255, 255, 255)


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


def update_pixels():
    spaces = 8
    for j in range(spaces):
        for i in range(num_pixels):
            pixels[i] = color_at_brightness(white, ((i + j) % (spaces + 1)) / spaces)
        pixels.show()
        time.sleep(0.1)


def main():
    try:
        while True:
            update_pixels()

    except (KeyboardInterrupt, SystemExit):
        pixels.deinit()


main()
