from utils import LightController, Colors, Color, color_at_brightness


class PewWithFade(LightController):
    time_to_sleep = 0.05

    def __init__(self, number_of_pixels: int, color: Color):
        super().__init__(number_of_pixels)
        self.pixel_positions = [-3, -2, -1, 0]
        self.pixel_brightnesses = [0.1, 0.7, 0.9, 1]
        self.color = color

    def pixels_for_frame(self):
        pixel_colors = [Colors.black for _ in range(self.num_pixels)]
        for index, x in enumerate(self.pixel_positions):
            if 0 <= x < self.num_pixels:
                pixel_colors[x] = color_at_brightness(self.color, self.pixel_brightnesses[index])
        return pixel_colors

    def update_frame(self):
        for i in range(len(self.pixel_positions)):
            self.pixel_positions[i] = (self.pixel_positions[i] + 1) % (self.num_pixels + 15)
