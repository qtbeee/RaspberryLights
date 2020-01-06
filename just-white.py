import board
import neopixel
import time

white = (255, 255, 255)

num_pixels = 50
pixels = neopixel.NeoPixel(board.D18, num_pixels, brightness=0.1, auto_write=False, pixel_order=neopixel.RGB)


def main():
    pixels.fill(white)
    pixels.show()
    try:
        while True:
            time.sleep(5)

    except (KeyboardInterrupt, SystemExit):
        pixels.deinit()


main()
