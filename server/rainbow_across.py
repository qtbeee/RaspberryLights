from utils import LightController, color_wheel


class RainbowAcross(LightController):
    frames = 255
    time_to_sleep = 0.001

    def _color_for_pixel(self, index: int):
        pos = (index * 256 // self.num_pixels) + self.current_frame
        return color_wheel(pos & 255)

    def pixels_for_frame(self):
        return [self._color_for_pixel(x) for x in range(self.num_pixels)]

    def update_frame(self):
        self.current_frame = (self.current_frame + 1) % self.frames
