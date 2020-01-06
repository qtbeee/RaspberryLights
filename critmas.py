import board
import neopixel
import time
from random import randrange
from typing import Tuple

Color = Tuple[int, int, int]

num_pixels = 50
pixels = neopixel.NeoPixel(board.D18, num_pixels, brightness=0.1, auto_write=False, pixel_order=neopixel.RGB)

# colors
black = (0, 0, 0)
pink = (255, 90, 160)
orange = (255, 160, 25)
blue = (110, 190, 230)
red = (255, 75, 50)
green = (61, 156, 23)

color_options = [pink, orange, blue, red, green]
pixel_colors = [randrange(0, len(color_options)) for x in range(num_pixels)]
number_of_steps = 100


def color_for_pixel(index):
    return color_options[pixel_colors[index]]


def breathing_color(color: Color, brightness: float):
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


def breathing_cycle(duration: float):
    global pixel_colors

    time_to_sleep = duration / number_of_steps
    for j in range(number_of_steps // 2):
        for i in range(num_pixels):
            pixel_color = breathing_color(color_for_pixel(i), j / (number_of_steps // 2))
            pixels[i] = pixel_color
        pixels.show()
        time.sleep(time_to_sleep)
    for j in range(number_of_steps // 2, 0, -1):
        for i in range(num_pixels):
            pixel_color = breathing_color(color_for_pixel(i), j / (number_of_steps // 2))
            pixels[i] = pixel_color
        pixels.show()
        time.sleep(time_to_sleep)
    pixel_colors = [randrange(0, len(color_options)) for x in range(num_pixels)]


def main():
    # initialize pixel_colors array
    for i in range(num_pixels):
        pixel_color = color_for_pixel(i)
        pixels[i] = breathing_color(pixel_color, 0)
    pixels.show()
    try:
        while True:
            breathing_cycle(5)

    except (KeyboardInterrupt, SystemExit):
        pixels.deinit()


main()
