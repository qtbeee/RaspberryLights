from utils import Color, LightController


class SolidColor(LightController):

    def __init__(self, number_of_pixels: int, color: Color):
        super().__init__(number_of_pixels)
        self.color = color

    def pixels_for_frame(self):
        return [self.color for _ in range(self.num_pixels)]

    def update_frame(self):
        return
