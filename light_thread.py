import time
from utils import set_pixels, LightController
import threading


# https://stackoverflow.com/questions/33640283/thread-that-i-can-pause-and-resume
class LightThread(threading.Thread):
    def __init__(self, pattern: LightController, pixels):
        super().__init__()
        self.lightPattern = pattern
        self.pixels = pixels
        # flag for pausing the thread (do I need this?)
        self.paused = False
        self.pause_cond = threading.Condition()

    def run(self):
        while True:
            with self.pause_cond:
                while self.paused:
                    self.pause_cond.wait()
                # If not paused, do the thing!
                pixel_values = self.lightPattern.pixels_for_frame()
                set_pixels(self.pixels, pixel_values)
                self.lightPattern.update_frame()
                time.sleep(self.lightPattern.time_to_sleep)

    def pause(self):
        self.paused = True
        self.pause_cond.acquire()

    def resume(self):
        self.paused = False
        self.pause_cond.notify()
        self.pause_cond.release()

    def setPattern(self, pattern: LightController):
        self.pause()
        self.lightPattern = pattern
        self.resume()
