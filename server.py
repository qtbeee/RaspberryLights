import board
import neopixel
import atexit

from light_thread import LightThread
from flask import Flask
from critmas import Critmas
from twinkle_white import TwinkleWhite
from white_scroll import WhiteScroll
from pew_with_fade import PewWithFade

# flask setup
app = Flask(__name__)

# light setup
num_pixels = 50
pixels = neopixel.NeoPixel(
    board.D18,
    num_pixels,
    brightness=0.1,
    auto_write=False,
    pixel_order=neopixel.RGB)
lightThread = LightThread(TwinkleWhite(num_pixels), pixels)
lightThread.run()


# to make sure the lights get shut off on normal exit
@atexit.register
def onExit():
    pixels.deinit()


@app.route('/pattern/<pattern>', methods=['POST'])
def usePattern(pattern=None):
    if pattern == "critmas":
        lightThread.setPattern(Critmas(num_pixels))
    elif pattern == "twinkle":
        lightThread.setPattern(TwinkleWhite(num_pixels))
    elif pattern == "white_scroll":
        lightThread.setPattern(WhiteScroll(num_pixels))
    elif pattern == "pew_with_fade":
        lightThread.setPattern(PewWithFade(num_pixels))
    else:
        return "pattern is not known"
    return pattern


# def main():
#     try:
#         while True:
#             pixel_values = lightPattern.pixels_for_frame()
#             set_pixels(pixels, pixel_values)
#             lightPattern.update_frame()
#             time.sleep(lightPattern.time_to_sleep)

#     except (KeyboardInterrupt, SystemExit):
#         pixels.deinit()


if __name__ == '__main__':
    app.run()
#     main()
