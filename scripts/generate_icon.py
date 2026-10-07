from PIL import Image, ImageDraw
import os

os.makedirs("assets", exist_ok=True)

# 1024x1024 canvas, dark blue background
SIZE = 1024
img = Image.new('RGBA', (SIZE, SIZE), (30, 60, 79, 255))
d = ImageDraw.Draw(img)

# Yellow sun (upper middle)
sun_cx, sun_cy, sun_r = 512, 420, 180
d.ellipse([sun_cx - sun_r, sun_cy - sun_r, sun_cx + sun_r, sun_cy + sun_r],
          fill=(255, 217, 61, 255))

# Sun rays (8 short lines)
import math
for angle in range(0, 360, 45):
    rad = math.radians(angle)
    x1 = sun_cx + int(math.cos(rad) * (sun_r + 25))
    y1 = sun_cy + int(math.sin(rad) * (sun_r + 25))
    x2 = sun_cx + int(math.cos(rad) * (sun_r + 75))
    y2 = sun_cy + int(math.sin(rad) * (sun_r + 75))
    d.line([x1, y1, x2, y2], fill=(255, 217, 61, 255), width=28)

# White cloud (overlapping circles at bottom)
white = (255, 255, 255, 255)
# bottom-left puff
d.ellipse([170, 640, 470, 850], fill=white)
# middle puff (bigger)
d.ellipse([350, 570, 720, 850], fill=white)
# right puff
d.ellipse([600, 640, 860, 850], fill=white)
# flat bottom to make it look like a cloud
d.rectangle([170, 780, 860, 850], fill=white)

img.save("assets/icon.png", "PNG")
print("Icon saved: assets/icon.png")

# Also create a 512x512 version (for faster testing)
img.resize((512, 512)).save("assets/icon_512.png", "PNG")
print("Icon saved: assets/icon_512.png")
