from utils import LightController, color_wheel


class RainbowInPlace(LightController):
    frames = 255
    time_to_sleep = 0.03

    def __init__(self, number_of_pixels):
        super().__init__(number_of_pixels)

    def pixels_for_frame(self):
        return [color_wheel(self.current_frame) for _ in range(self.num_pixels)]

    def update_frame(self):
        self.current_frame = (self.current_frame + 1) % 255
