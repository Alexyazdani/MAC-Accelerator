import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
import random
from PIL import Image
import os
from matrix_mul import *

def generate_random_image():
    return [random.randint(0, 255) for _ in range(64)]

def display_images_8x8(images, titles=None):
    if len(images) != 8:
        raise ValueError("You must provide exactly 8 images.")
    if not all(len(img) == 64 for img in images):
        raise ValueError("All images must have 64 pixels (8x8).")

    fig, axes = plt.subplots(2, 4, figsize=(12, 6))
    axes = axes.flatten()

    for i, (img, ax) in enumerate(zip(images, axes)):
        array = np.array(img, dtype=np.uint8).reshape((8, 8))
        ax.imshow(array, cmap='gray', vmin=0, vmax=255)
        ax.axis('off')

        rect = patches.Rectangle(
            (0, 0), 1, 1,
            linewidth=1,
            edgecolor='black',
            facecolor='none',
            transform=ax.transAxes,
            clip_on=False
        )
        ax.add_patch(rect)

        if titles:
            ax.set_title(titles[i])

    fig.subplots_adjust(hspace=0.3)
    plt.show()

happy_face = [
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 0,   255, 255, 0,   255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 0,   255, 255, 255, 255, 0,   255,
    255, 255, 0,   255, 255, 0,   255, 255,
    255, 255, 255, 0,   0,   255, 255, 255,
    255, 255, 255, 255, 255, 255, 255, 255
]

heart = [
    255, 0,   255, 255, 255, 255, 0,   255,
    0,   0,   0,   255, 255, 0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,
    255, 0,   0,   0,   0,   0,   0,   255,
    255, 255, 0,   0,   0,   0,   255, 255,
    255, 255, 255, 0,   0,   255, 255, 255,
    255, 255, 255, 255, 0,   255, 255, 255
]

key = [
    255, 255, 255, 0,   0,   255, 255, 255,
    255, 255, 255, 255, 0,   255, 255, 255,
    255, 255, 255, 0,   0,   255, 255, 255,
    255, 255, 255, 255, 0,   255, 255, 255,
    255, 255, 255, 0,   0,   0,   255, 255,
    255, 255, 0,   255, 255, 255, 0,   255,
    255, 255, 0,   255, 255, 255, 0,   255,
    255, 255, 255, 0,   0,   0,   255, 255
]

arrow = [
    255, 255, 255, 0,   0,   255, 255, 255,
    255, 255, 0,   0,   0,   0,   255, 255,
    255, 0,   255, 0,   0,   255, 0,   255,
    0,   255, 255, 0,   0,   255, 255, 0,
    255, 255, 255, 0,   0,   255, 255, 255,
    255, 255, 255, 0,   0,   255, 255, 255,
    255, 255, 255, 0,   0,   255, 255, 255,
    255, 255, 255, 0,   0,   255, 255, 255
]

squid = [
    255, 255, 255, 0,   0,   255, 255, 255,
    255, 255, 0,   0,   0,   0,   255, 255,
    255, 0,   0,   0,   0,   0,   0,   255,
    0,   0,   255, 0,   0,   255, 0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,
    255, 255, 0,   255, 255, 0,   255, 255,
    255, 0,   255, 0,   0,   255, 0,   255,
    0,   255, 0,   255, 255, 0,   255, 0
]

cat = [
    255, 255, 0,   255, 255, 255, 255, 255,
    0,   0,   0,   255, 255, 255, 255, 255,
    0,   0,   0,   255, 255, 255, 255, 0,
    255, 255, 0,   0,   0,   0,   0,   0,
    255, 255, 0,   0,   0,   0,   0,   255,
    255, 255, 0,   0,   0,   0,   0,   255,
    255, 255, 0,   255, 255, 255, 0,   255,
    255, 0,   0,   255, 255, 0,   0,   255
]

ghost = [
    255, 255, 255, 255, 255, 255, 255, 255,
    255, 0,   0,   0,   0,   0,   0,   255,
    255, 0,   255, 0,   0,   255, 0,   255,
    255, 0,   0,   0,   0,   0,   0,   255,
    255, 0,   255, 255, 255, 255, 0,   255,
    255, 0,   0,   0,   0,   0,   0,   255,
    255, 255, 0,   255, 255, 0,   255, 255,
    255, 0,   0,   255, 0,   0,   255, 255
]

cyclopse = [
    255, 0,   0,   0,   0,   0,   255, 255,
    255, 0,   0,   255, 0,   0,   255, 255,
    255, 0,   0,   0,   0,   0,   255, 255,
    255, 255, 0,   0,   0,   255, 255, 255,
    0,   0,   0,   0,   0,   0,   0,   255,
    0,   255, 0,   255, 0,   255, 0,   255,
    255, 255, 0,   255, 0,   255, 255, 255,
    255, 0,   0,   255, 0,   0,   255, 255
]


bird = [
    255, 0,   0,   0,   255, 255, 255, 255,
    0,   0,   255, 0,   255, 255, 255, 255,
    255, 0,   0,   0,   255, 255, 255, 255,
    255, 0,   0,   0,   0,   255, 255, 255,
    255, 0,   0,   0,   0,   0,   0,   0,
    255, 0,   0,   0,   0,   0,   0,   255,
    255, 0,   0,   0,   255, 255, 255, 255,
    255, 255, 0,   255, 255, 255, 255, 255
]


# white = [
#     255, 255, 255, 255, 255, 255, 255, 255,
#     255, 255, 255, 255, 255, 255, 255, 255,
#     255, 255, 255, 255, 255, 255, 255, 255,
#     255, 255, 255, 255, 255, 255, 255, 255,
#     255, 255, 255, 255, 255, 255, 255, 255,
#     255, 255, 255, 255, 255, 255, 255, 255,
#     255, 255, 255, 255, 255, 255, 255, 255,
#     255, 255, 255, 255, 255, 255, 255, 255
# ]

images_art = [happy_face, heart, key, squid, cat, cyclopse, bird] + [generate_random_image()]
titles_art = [f"Image {i+1}" for i in range(7)] + ["Noise Image"]

digit0 = [
    0,   0,   30,  80,  80,  30,  0,   0,
    0,   50, 200, 255, 255, 200, 50,  0,
    0,   100, 255, 150, 150, 255, 100, 0,
    0,   120, 255, 80, 100, 255, 120, 0,
    0,   120, 255, 100, 80, 255, 120, 0,
    0,   100, 255, 150, 150, 255, 100, 0,
    0,   50,  200, 255, 255, 200, 50,  0,
    0,   0,   30,  80,  80,  30,  0,   0
]


# digit1 = [
#     0,   0,   0,   100, 150, 0,   0,   0,
#     0,   0,   100, 255, 255, 100, 0,   0,
#     0,   100, 255, 255, 255, 100, 0,   0,
#     0,   0,   100, 255, 255, 100, 0,   0,
#     0,   0,   100, 255, 255, 100, 0,   0,
#     0,   0,   100, 255, 255, 100, 0,   0,
#     0,   0,   100, 255, 255, 100, 0,   0,
#     0,   0,   80,  180, 200, 80,  0,   0
# ]
digit1 = [
    255, 255, 255, 155, 105, 255, 255, 255,
    255, 255, 155, 0,   0,   155, 255, 255,
    255, 155, 0,   0,   0,   155, 255, 255,
    255, 255, 155, 0,   0,   155, 255, 255,
    255, 255, 155, 0,   0,   155, 255, 255,
    255, 255, 155, 0,   0,   155, 255, 255,
    255, 255, 155, 0,   0,   155, 255, 255,
    255, 255, 175, 75,  55,  175, 255, 255
]



digit2 = [
    0,   80,  150, 180, 180, 150, 80,  0,
    80,  255, 255, 255, 255, 255, 255, 100,
    0,   0,   0,   0,   0,   200, 255, 150,
    0,   0,   0,   0,   100, 255, 255, 100,
    0,   0,   0,   180, 255, 200, 50,  0,
    0,   0,   150, 255, 150, 0,   0,   0,
    0,   80,  255, 255, 150, 0,   0,   0,
    100, 255, 255, 255, 255, 250, 180, 100
]


# digit3 = [
#     50, 180, 220, 220, 180, 100, 0,   0,
#     100, 255, 255, 255, 255, 200, 0,   0,
#     0,   0,   0,   80, 255, 255, 50,  0,
#     0,   50, 150, 255, 255, 255, 100, 0,
#     0,   0,   0,   100, 255, 255, 100, 0,
#     0,   0,   0,   100, 255, 255, 100, 0,
#     80, 180, 255, 255, 255, 200, 0,   0,
#     50, 80,  120, 120, 80,  50,  0,   0
# ]
digit3 = [
    205, 75,  35,  35,  75,  155, 255, 255,
    155, 0,   0,   0,   0,   55,  255, 255,
    255, 255, 255, 175, 0,   0,   205, 255,
    255, 205, 105, 0,   0,   0,   155, 255,
    255, 255, 255, 155, 0,   0,   155, 255,
    255, 255, 255, 155, 0,   0,   155, 255,
    175, 75,  0,   0,   0,   55,  255, 255,
    205, 175, 135, 135, 175, 205, 255, 255
]



digit4 = [
    0,   0,   0,   200, 255, 200, 0,   0,
    0,   0,   100, 255, 255, 200, 0,   0,
    0,   50, 200, 255, 255, 200, 0,   0,
    0,   100, 255, 180, 255, 200, 0,   0,
    50, 200, 255, 255, 255, 255, 100, 0,
    0,   0,   0,   255, 255, 0,   0,   0,
    0,   0,   0,   255, 255, 0,   0,   0,
    0,   0,   0,   255, 255, 0,   0,   0
]

# digit5 = [
#     200, 255, 255, 255, 255, 200, 0,   0,
#     200, 255, 255, 255, 255, 100, 0,   0,
#     200, 255, 255, 100, 0,   0,   0,   0,
#     255, 255, 255, 255, 180, 100, 0,   0,
#     100, 100, 100, 255, 255, 255, 100, 0,
#     0,   0,   0,   80,  255, 255, 150, 0,
#     100, 200, 255, 255, 255, 200, 0,   0,
#     50, 100, 150, 150, 100, 50,  0,   0
# ]
digit5 = [
    55,  0,   0,   0,   0,   55,  255, 255,
    55,  0,   0,   0,   0,   155, 255, 255,
    55,  0,   0,   155, 255, 255, 255, 255,
    0,   0,   0,   0,   75,  155, 255, 255,
    155, 155, 155, 0,   0,   0,   155, 255,
    255, 255, 255, 175, 0,   0,   105, 255,
    155, 55,  0,   0,   0,   55,  255, 255,
    205, 155, 105, 105, 155, 205, 255, 255
]


digit6 = [
    0,   0,   50, 180, 200, 100, 0,   0,
    0,   100, 255, 255, 200, 50, 0,   0,
    50, 255, 255, 100, 0,   0,   0,   0,
    100, 255, 255, 255, 180, 50, 0,   0,
    150, 255, 255, 255, 255, 200, 50, 0,
    180, 255, 255, 180, 255, 255, 100, 0,
    100, 200, 255, 255, 255, 180, 0,   0,
    0,   50,  100, 100, 80,  0,   0,   0
]

images_mnist = [digit0, digit1, digit2, digit3, digit4, digit5, digit6] + [generate_random_image()]
titles_mnist = [f"Image {i+1}" for i in range(7)] + ["Noise Image"]


def image_to_rgb(path):
    img = Image.open(path).convert('RGB')
    width, height = img.size
    # print(f"Image size: {width} x {height}")
    data = np.array(img)
    red = data[:, :, 0].flatten().tolist()
    green = data[:, :, 1].flatten().tolist()
    blue = data[:, :, 2].flatten().tolist()
    return red, green, blue

def display_image_grayscale(pixels, width, height):
    array = np.array(pixels, dtype=np.uint8).reshape((height, width))
    plt.imshow(array, cmap='gray', vmin=0, vmax=255)
    plt.axis('off')
    plt.show()

def display_image_red(red, width, height):
    blank = np.zeros(len(red), dtype=np.uint8)
    array = np.stack([red, blank, blank], axis=1).reshape((height, width, 3))
    plt.imshow(array)
    plt.axis('off')
    plt.show()

def display_image_green(green, width, height):
    blank = np.zeros(len(green), dtype=np.uint8)
    array = np.stack([blank, green, blank], axis=1).reshape((height, width, 3))
    plt.imshow(array)
    plt.axis('off')
    plt.show()

def display_image_blue(blue, width, height):
    blank = np.zeros(len(blue), dtype=np.uint8)
    array = np.stack([blank, blank, blue], axis=1).reshape((height, width, 3))
    plt.imshow(array)
    plt.axis('off')
    plt.show()

def display_image_color(red, green, blue, width, height):
    array = np.stack([red, green, blue], axis=1).reshape((height, width, 3)).astype(np.uint8)
    plt.imshow(array)
    plt.axis('off')
    plt.show()

def display_images_color(rgb_images, width, height, titles=None):
    fig, axes = plt.subplots(2, 4, figsize=(12, 6))
    axes = axes.flatten()
    for i, ((r, g, b), ax) in enumerate(zip(rgb_images, axes)):
        array = np.stack([r, g, b], axis=1).reshape((height, width, 3)).astype(np.uint8)
        ax.imshow(array)
        ax.axis('off')
        rect = patches.Rectangle((0, 0), 1, 1, linewidth=1, edgecolor='black', facecolor='none', transform=ax.transAxes, clip_on=False)
        ax.add_patch(rect)
        if titles:
            ax.set_title(titles[i])
    fig.subplots_adjust(hspace=0.3)
    plt.show()

def display_images_channel(rgb_images, width, height, channel, titles=None):
    fig, axes = plt.subplots(2, 4, figsize=(12, 6))
    axes = axes.flatten()
    for i, (r, g, b) in enumerate(rgb_images):
        zero = np.zeros(len(r), dtype=np.uint8)
        if channel == 'r':
            stacked = np.stack([r, zero, zero], axis=1)
        elif channel == 'g':
            stacked = np.stack([zero, g, zero], axis=1)
        elif channel == 'b':
            stacked = np.stack([zero, zero, b], axis=1)
        array = stacked.reshape((height, width, 3))
        ax = axes[i]
        ax.imshow(array)
        ax.axis('off')
        rect = patches.Rectangle((0, 0), 1, 1, linewidth=1, edgecolor='black', facecolor='none', transform=ax.transAxes, clip_on=False)
        ax.add_patch(rect)
        if titles:
            ax.set_title(titles[i])
    fig.subplots_adjust(hspace=0.3)
    plt.show()

# height = 1024
# width = 1024
# Anakin_red, Anakin_green, Anakin_blue = image_to_rgb("images/Anakin.png")
# KitFisto_red, KitFisto_green, KitFisto_blue = image_to_rgb("images/KitFisto.png")
# EldenRing_red, EldenRing_green, EldenRing_blue = image_to_rgb("images/EldenRing.png")
# Garfield_red, Garfield_green, Garfield_blue = image_to_rgb("images/Garfield.png")
# Jango_red, Jango_green, Jango_blue = image_to_rgb("images/Jango.png")
# SmallSoldiers_red, SmallSoldiers_green, SmallSoldiers_blue = image_to_rgb("images/SmallSoldiers.png")
# Toulouse_red, Toulouse_green, Toulouse_blue = image_to_rgb("images/Toulouse.png")
# random_red = np.random.randint(0, 256, height * width).tolist()
# random_green = np.random.randint(0, 256, height * width).tolist()
# random_blue = np.random.randint(0, 256, height * width).tolist()

# images_red = [Anakin_red, KitFisto_red, EldenRing_red, Garfield_red, Jango_red, SmallSoldiers_red, Toulouse_red, random_red]
# images_green = [Anakin_green, KitFisto_green, EldenRing_green, Garfield_green, Jango_green, SmallSoldiers_green, Toulouse_green, random_green]
# images_blue = [Anakin_blue, KitFisto_blue, EldenRing_blue, Garfield_blue, Jango_blue, SmallSoldiers_blue, Toulouse_blue, random_blue]

def save_grayscale_image(pixel_values, height, width, filepath):
    if len(pixel_values) != height * width:
        raise ValueError("Length of pixel_values does not match height * width.")

    image = Image.new('L', (width, height))
    image.putdata(pixel_values)
    
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    image.save(filepath, format='PNG')

def load_grayscale_image(filepath):
    image = Image.open(filepath).convert('L')
    return list(image.getdata())

def ieee754_16_to_float(hex_str):
    uint16 = np.uint16(int(hex_str, 16))
    return uint16.view(np.float16).item()

def hexfile_to_png(filepath, batch_size, image_size, mode, output_dir):
    with open(filepath, 'r') as f:
        hex_lines = [line.strip() for line in f if line.strip()]
    expected_lines = batch_size * image_size
    if len(hex_lines) != expected_lines:
        raise ValueError(f"Expected {expected_lines} hex values, but got {len(hex_lines)}.")
    os.makedirs(output_dir, exist_ok=True)
    images = []
    for i in range(batch_size):
        start = i * image_size
        end = start + image_size
        hex_chunk = hex_lines[start:end]
        float_vals = [ieee754_16_to_float(h) for h in hex_chunk]
        if mode == "e":
            pixel_vals = normalize_encoded_to_0_255(float_vals)
            # pixel_vals = normalize_dynamic_to_0_255(float_vals)
        elif mode == "d":
            pixel_vals = normalize_1_2_to_0_255(float_vals)
        else:
            raise ValueError("Mode must be 'e' (encoded) or 'd' (denormalized)")
        pixel_vals = np.clip(pixel_vals, 0, 255).astype(np.uint8).tolist()
        images.append(pixel_vals)
        save_grayscale_image(
            pixel_vals,
            height=int(image_size**0.5),
            width=int(image_size**0.5),
            filepath=os.path.join(output_dir, f"image_{i:02d}.png")
        )
    display_images_8x8(images)

def main():
    # display_images_8x8(images_art, titles_art)
    # display_images_8x8(images_mnist, titles_mnist)

    # display_image_red(Anakin_red, 1024, 1024)
    # display_image_green(Anakin_green, 1024, 1024)
    # display_image_blue(Anakin_blue, 1024, 1024)
    # display_image_color(Anakin_red, Anakin_green, Anakin_blue, 1024, 1024)

    # display_image_red(KitFisto_red, 1024, 1024)
    # display_image_green(KitFisto_green, 1024, 1024)
    # display_image_blue(KitFisto_blue, 1024, 1024)
    # display_image_color(KitFisto_red, KitFisto_green, KitFisto_blue, 1024, 1024)

    # display_image_red(EldenRing_red, 1024, 1024)
    # display_image_green(EldenRing_green, 1024, 1024)
    # display_image_blue(EldenRing_blue, 1024, 1024)
    # display_image_color(EldenRing_red, EldenRing_green, EldenRing_blue, 1024, 1024)

    # display_image_red(Garfield_red, 1024, 1024)
    # display_image_green(Garfield_green, 1024, 1024)
    # display_image_blue(Garfield_blue, 1024, 1024)
    # display_image_color(Garfield_red, Garfield_green, Garfield_blue, 1024, 1024)

    # display_image_red(Jango_red, 1024, 1024)
    # display_image_green(Jango_green, 1024, 1024)
    # display_image_blue(Jango_blue, 1024, 1024)
    # display_image_color(Jango_red, Jango_green, Jango_blue, 1024, 1024)

    # display_image_red(SmallSoldiers_red, 1024, 1024)
    # display_image_green(SmallSoldiers_green, 1024, 1024)
    # display_image_blue(SmallSoldiers_blue, 1024, 1024)
    # display_image_color(SmallSoldiers_red, SmallSoldiers_green, SmallSoldiers_blue, 1024, 1024)

    # display_image_red(Toulouse_red, 1024, 1024)
    # display_image_green(Toulouse_green, 1024, 1024)
    # display_image_blue(Toulouse_blue, 1024, 1024)
    # display_image_color(Toulouse_red, Toulouse_green, Toulouse_blue, 1024, 1024)



    # rgb_images = [
    #     (Anakin_red, Anakin_green, Anakin_blue),
    #     (KitFisto_red, KitFisto_green, KitFisto_blue),
    #     (EldenRing_red, EldenRing_green, EldenRing_blue),
    #     (Garfield_red, Garfield_green, Garfield_blue),
    #     (Jango_red, Jango_green, Jango_blue),
    #     (SmallSoldiers_red, SmallSoldiers_green, SmallSoldiers_blue),
    #     (Toulouse_red, Toulouse_green, Toulouse_blue),
    #     (random_red, random_green, random_blue)
    # ]
    # display_images_color(rgb_images, width, height)
    # display_images_channel(rgb_images, width, height, channel='r')
    # display_images_channel(rgb_images, width, height, channel='g')
    # display_images_channel(rgb_images, width, height, channel='b')


    # mnist_path = "images8x8/mnist/"
    # for i, image in enumerate(images_mnist):
    #     if images_mnist[i] == images_mnist[-1]:
    #         filename = "noise_image.png"
    #     else:
    #         filename = f"mnist_image_{i}.png"
    #     save_grayscale_image(image, 8, 8, mnist_path + filename)

    # art_path = "images8x8/art/"
    # for i, image in enumerate(images_art):
    #     if images_art[i] == images_art[-1]:
    #         filename = "noise_image.png"
    #     else:
    #         filename = f"art_image_{i}.png"
    #     save_grayscale_image(image, 8, 8, art_path + filename)


    # image_test = load_grayscale_image("images8x8/mnist/mnist_image_0.png")
    # print(image_test)
    # display_image_grayscale(image_test, 8, 8)
    hexfile_to_png("data_encoded.txt", 8, 64, "e", "encoded/")
    hexfile_to_png("data_decoded.txt", 8, 64, "d", "decoded/")


if __name__ == "__main__":
    main()