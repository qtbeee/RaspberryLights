import board
import neopixel
import time
from random import randrange

num_pixels = 50
pixels = neopixel.NeoPixel(board.D18, num_pixels, brightness=0.1, auto_write=False, pixel_order=neopixel.RGB)


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


def rainbow_cycle(wait):
    index = randrange(0, num_pixels)
    pixel_color = (randrange(0, 255) * 256 // num_pixels)
    pixels[index] = wheel(pixel_color & 255)
    pixels.show()
    time.sleep(wait)


def main():
    for i in range(num_pixels):
        pixel_color = (randrange(0, 255) * 256 // num_pixels)
        pixels[i] = wheel(pixel_color & 255)
    pixels.show()
    try:
        while True:
            rainbow_cycle(0.1)

    except (KeyboardInterrupt, SystemExit):
        pixels.deinit()


main()
