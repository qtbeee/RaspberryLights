import board
import neopixel
import time

from critmas import Critmas
from twinkle_white import TwinkleWhite
from white_scroll import WhiteScroll
from utils import set_pixels

num_pixels = 50
pixels = neopixel.NeoPixel(board.D18, num_pixels, brightness=0.1, auto_write=False, pixel_order=neopixel.RGB)


def main():
    pattern = WhiteScroll(num_pixels)
    try:
        while True:
            pixel_values = pattern.pixels_for_frame()
            set_pixels(pixels, pixel_values)
            pattern.update_frame()
            time.sleep(pattern.time_to_sleep)

    except (KeyboardInterrupt, SystemExit):
        pixels.deinit()


if __name__ == '__main__':
    main()
