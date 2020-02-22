import board
import neopixel
import atexit
import time
from multiprocessing import Pipe, Process
from multiprocessing.connection import Connection

from flask import Flask
from critmas import Critmas
from twinkle_white import TwinkleWhite
from white_scroll import WhiteScroll
from pew_with_fade import PewWithFade
from rainbow_across import RainbowAcross
from rainbow_in_place import RainbowInPlace
from rainbow_random import RainbowRandom
from utils import set_pixels, LightController

# flask setup
app = Flask(__name__)

# light setup
num_pixels = 50
global pixels


# Function that will be running under its own process
def lightLoop(recv: Connection):
    print("starting that process...")
    lightPattern = LightController(num_pixels)
    while True:
        if recv.poll():
            print("get new pattern")
            lightPattern = recv.recv()

        pixel_values = lightPattern.pixels_for_frame()
        set_pixels(pixels, pixel_values)
        lightPattern.update_frame()
        time.sleep(lightPattern.time_to_sleep)


# for freeing the pin and turning off the lights
def onExit():
    p.terminate()
    pixels.deinit()


@app.route('/pattern/<pattern>', methods=['POST'])
def usePattern(pattern=None):
    global input_connection
    if pattern == "critmas":
        input_connection.send(Critmas(num_pixels))
    elif pattern == "twinkle":
        input_connection.send(TwinkleWhite(num_pixels))
    elif pattern == "white_scroll":
        input_connection.send(WhiteScroll(num_pixels))
    elif pattern == "pew_with_fade":
        input_connection.send(PewWithFade(num_pixels))
    elif pattern == "rainbow_across":
        input_connection.send(RainbowAcross(num_pixels))
    elif pattern == "rainbow_in_place":
        input_connection.send(RainbowInPlace(num_pixels))
    elif pattern == "rainbow_random":
        input_connection.send(RainbowRandom(num_pixels))
    else:
        return "pattern is not known"
    return pattern


if __name__ != '__main__':
    print("__name__ is ", __name__)
    global pixels, input_connection
    pixels = neopixel.NeoPixel(
        board.D18,
        num_pixels,
        brightness=0.1,
        auto_write=False,
        pixel_order=neopixel.RGB)

    atexit.register(onExit)

    child_conn, input_connection = Pipe(False)

    p = Process(target=lightLoop, args=(child_conn,))
    p.start()
