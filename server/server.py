import board
import neopixel
import atexit
import time
from multiprocessing import Pipe, Process
from multiprocessing.connection import Connection
from flask import Flask, abort, request

from critmas import Critmas
from twinkle import Twinkle
from scroll import Scroll
from pew_with_fade import PewWithFade
from rainbow_across import RainbowAcross
from rainbow_in_place import RainbowInPlace
from rainbow_random import RainbowRandom
from utils import set_pixels, LightController, Colors, colorFromHex

# flask setup
app = Flask(__name__)

# light setup
num_pixels = 50
global pixels

# available light patterns
light_patterns = {
    "critmas": {"class": Critmas, "canChooseColor": False},
    "twinkle": {"class": Twinkle, "canChooseColor": True},
    "scroll": {"class": Scroll, "canChooseColor": True},
    "pewWithFade": {"class": PewWithFade, "canChooseColor": True},
    "rainbowAcross": {"class": RainbowAcross, "canChooseColor": False},
    "rainbowInPlace": {"class": RainbowInPlace, "canChooseColor": False},
    "rainbowRandom": {"class": RainbowRandom, "canChooseColor": False},
}


# Function that will be running under its own process
def light_loop(recv: Connection):
    print("starting that process...")
    light_pattern = LightController(num_pixels)
    while True:
        if recv.poll():
            print("get new pattern")
            light_pattern = recv.recv()

        pixel_values = light_pattern.pixels_for_frame()
        set_pixels(pixels, pixel_values)
        light_pattern.update_frame()
        time.sleep(light_pattern.time_to_sleep)


# for freeing the pin and turning off the lights
def on_exit():
    p.terminate()
    pixels.deinit()


@app.route('/pattern', methods=['GET'])
def get_patterns():
    return {
        "patterns": [
            {
                "pattern": key,
                "canChooseColor": value.get("canChooseColor")
            } for key, value in light_patterns.items()
        ]
    }


@app.route('/pattern', methods=['POST'])
def use_pattern():
    if request.is_json:
        body = request.get_json()
        pattern_name = body.get("pattern")

        pattern = light_patterns[pattern_name]
        if pattern is not None:
            if pattern.get("canChooseColor"):
                color = Colors.white
                if body.get("color") is not None:
                    color = colorFromHex(body.get("color"))
                input_connection.send(pattern.get("class")(num_pixels, color))
            else:
                input_connection.send(pattern.get("class")(num_pixels))
        else:
            return abort(422)
        return pattern_name
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

    atexit.register(on_exit)

    child_conn, input_connection = Pipe(False)

    p = Process(target=light_loop, args=(child_conn,))
    p.start()
