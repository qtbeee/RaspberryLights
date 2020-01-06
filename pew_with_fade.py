import board
import neopixel
import time

red = (255, 0, 0)
red1 = (200, 0, 0)
red2 = (140, 0, 0)
red3 = (50, 0, 0)
black = (0, 0, 0)

NUM_LEDS = 50

pixels = neopixel.NeoPixel(board.D18, NUM_LEDS, brightness=0.1, auto_write=False, pixel_order=neopixel.RGB)

lights = [-4, -3, -2, -1, 0]
colors = [black, red3, red2, red1, red]

try:
    while True:
        for i in range(len(lights)):
            if lights[i] >= 0:
                pixels[lights[i]] = colors[i]
            lights[i] = (lights[i] + 1) % NUM_LEDS

        pixels.show()
        time.sleep(0.1)

except (KeyboardInterrupt, SystemExit):
    pixels.deinit()
