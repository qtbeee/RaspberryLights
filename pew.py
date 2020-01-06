import board
import neopixel
import time

red = (255, 0, 0)
blue = (0, 0, 255)
black = (0, 0, 0)

pixels = neopixel.NeoPixel(board.D18, 50, brightness=0.1, auto_write=False, pixel_order=neopixel.RGB)

try:
    while True:
        for i in range(50):
            if i == 0:
                pixels[49] = black
            else:
                pixels[i-1] = black
            pixels[i] = red
            pixels.show()
            time.sleep(0.2)

except (KeyboardInterrupt, SystemExit):
    pixels.deinit()
