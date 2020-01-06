from utils import color_at_brightness, Colors, LightController


class WhiteScroll(LightController):
    time_to_sleep = 0.1
    frames = 8

    def __init__(self, number_of_pixels: int):
        super().__init__(number_of_pixels)
        self.pixel_colors = [Colors.black]

    def _color_for_pixel(self, index: int):
        return color_at_brightness(Colors.white, ((index + self.current_frame) % (self.frames + 1)) / self.frames)

    def pixels_for_frame(self):
        return [self._color_for_pixel(i) for i in range(self.num_pixels)]

    def update_frame(self):
        self.current_frame = (self.current_frame + 1) % self.frames
