import board
import neopixel
import atexit
import time
from multiprocessing import Pipe, Process
from multiprocessing.connection import Connection
from flask import Flask, jsonify, abort, request

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

# available light patterns
light_patterns = {
    "critmas": {"class": Critmas, "canChooseColor": False},
    "twinkle": {"class": TwinkleWhite, "canChooseColor": False},
    "whiteScroll": {"class": WhiteScroll, "canChooseColor": False},
    "pewWithFade": {"class": PewWithFade, "canChooseColor": False},
    "rainbowAcross": {"class": RainbowAcross, "canChooseColor": False},
    "rainbowInPlace": {"class": RainbowInPlace, "canChooseColor": False},
    "rainbowRandom": {"class": RainbowRandom, "canChooseColor": False},
}


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


@app.route('/pattern', methods=['GET'])
def getPatterns():
    return {
        "patterns": [
            {
                "pattern": key,
                "canChooseColor": value.get("canChooseColor")
            } for key, value in light_patterns.items()
        ]
    }
    # return jsonify({'patterns': [*light_patterns]})


@app.route('/pattern', methods=['POST'])
def usePattern():
    if request.is_json:
        body = request.get_json()
        patternName = body.get("pattern")

        pattern = light_patterns[patternName]
        if pattern is not None:
            input_connection.send(pattern.get("class")(num_pixels))
        else:
            return abort(422)
        return patternName
    else:
        abort(400)


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
