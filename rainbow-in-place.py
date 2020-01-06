import board
import neopixel
import time


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


NUM_LEDS = 50

pixels = neopixel.NeoPixel(board.D18, NUM_LEDS, brightness=0.1, auto_write=False, pixel_order=neopixel.RGB)

pos = 0
try:
    while True:
        pixels.fill(wheel(pos))
        pixels.show()
        pos = (pos + 1) % 255
        time.sleep(0.05)

except (KeyboardInterrupt, SystemExit):
    pixels.deinit()
