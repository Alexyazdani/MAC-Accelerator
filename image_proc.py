from display_image import *
from matrix_mul import *

# def generate_scalar_matrix(rows, cols, low=0.1, high=1.9, neg_prob=0.4):
#     while True:
#         A = np.random.uniform(low, high, (rows, cols))
#         signs = np.where(np.random.rand(rows, cols) < neg_prob, -1, 1)
#         A *= signs
#         A /= np.linalg.norm(A, axis=1, keepdims=True)
#         if rows == cols and np.linalg.cond(A) > 10:
#             continue
#         return A

def generate_scalar_matrix(rows, cols, low=0.5, high=1.5, neg_prob=0.5):
    A = np.random.uniform(low, high, size=(rows, cols))
    signs = np.random.choice([1, -1], size=(rows, cols), p=[1 - neg_prob, neg_prob])
    return A * signs

def main_v1():
    # batch = denormalize_0_255_to_1_10(images_art)
    batch = denormalize_0_255_to_1_10(images_mnist)
    rand_scalar = np.random.uniform(0.5, 1.5, size=(8, 8))  #Always a square matrix with length = K+1
    inverse_scalar = np.linalg.inv(rand_scalar)
    encoded = rand_scalar @ batch
    decoded = inverse_scalar @ encoded
    encoded_visual = normalize_4_120_to_0_255(encoded)
    decoded_visual = normalize_1_10_to_0_255(decoded)

    print("Random Scalar Matrix (Noise values between 0.1 and 1, one per column with small variation across rows):")
    print(np.array2string(rand_scalar, formatter={'float_kind': lambda x: f"{x:0.2f}"}))
    print("\nBatch Data Matrix (Random values between 1 and 10):")
    print(np.array2string(batch, formatter={'float_kind': lambda x: f"{x:0.2f}"}))
    print("\nEncoded Matrix :")
    print(np.array2string(encoded, formatter={'float_kind': lambda x: f"{x:0.2f}"}))
    print("\nInverse Scalar Matrix :")
    print(np.array2string(inverse_scalar, formatter={'float_kind': lambda x: f"{x:0.2f}"}))
    print("\nDecoded Matrix :")
    print(np.array2string(decoded, formatter={'float_kind': lambda x: f"{x:0.2f}"}))


    titles = [f"Image {i+1}" for i in range(7)] + ["Noise Image"]
    # display_images_8x8(images_art, titles)
    display_images_8x8(images_mnist, titles)
    titles = [f"Encoded Image {i+1}" for i in range(8)]
    display_images_8x8(encoded_visual, titles)
    titles = [f"Decoded Image {i+1}" for i in range(8)]
    display_images_8x8(decoded_visual, titles)


height = 1024
width = 1024
AaylaSecura_red, AaylaSecura_green, AaylaSecura_blue = image_to_rgb("images/AaylaSecura.png")
Anakin_red, Anakin_green, Anakin_blue = image_to_rgb("images/Anakin.png")
KitFisto_red, KitFisto_green, KitFisto_blue = image_to_rgb("images/KitFisto.png")
MaceWindu_red, MaceWindu_green, MaceWindu_blue = image_to_rgb("images/MaceWindu.png")
ObiWan_red, ObiWan_green, ObiWan_blue = image_to_rgb("images/ObiWan.png")
PloKoon_red, PloKoon_green, PloKoon_blue = image_to_rgb("images/PloKoon.png")
Yoda_red, Yoda_green, Yoda_blue = image_to_rgb("images/Yoda.png")
random_red = np.random.randint(0, 256, height * width).tolist()
random_green = np.random.randint(0, 256, height * width).tolist()
random_blue = np.random.randint(0, 256, height * width).tolist()

images_red = [AaylaSecura_red, Anakin_red, KitFisto_red, MaceWindu_red, ObiWan_red, PloKoon_red, Yoda_red, random_red]
images_green = [AaylaSecura_green, Anakin_green, KitFisto_green, MaceWindu_green, ObiWan_green, PloKoon_green, Yoda_green, random_green]
images_blue = [AaylaSecura_blue, Anakin_blue, KitFisto_blue, MaceWindu_blue, ObiWan_blue, PloKoon_blue, Yoda_blue, random_blue]




def main_v2():
    batch_red = denormalize_0_255_to_1_2(images_red)
    batch_green = denormalize_0_255_to_1_2(images_green)
    batch_blue = denormalize_0_255_to_1_2(images_blue)

    while True:
        rand_scalar = generate_scalar_matrix(8, 8, low=0.5, high=1.5, neg_prob=0.5)
        cond = np.linalg.cond(rand_scalar)
        if cond <= 20:
            break

    # print("Random Scalar Matrix:\n", rand_scalar)
    print("Condition number:", cond)

    inverse_scalar = np.linalg.inv(rand_scalar)
    # print("Inverse Scalar Matrix:\n", inverse_scalar)

    encoded_red = rand_scalar @ batch_red
    encoded_green = rand_scalar @ batch_green
    encoded_blue = rand_scalar @ batch_blue

    decoded_red = inverse_scalar @ encoded_red
    decoded_green = inverse_scalar @ encoded_green
    decoded_blue = inverse_scalar @ encoded_blue

    encoded_visual_red = normalize_encoded_to_0_255(encoded_red)
    encoded_visual_green = normalize_encoded_to_0_255(encoded_green)
    encoded_visual_blue = normalize_encoded_to_0_255(encoded_blue)

    # encoded_visual_red = normalize_dynamic_to_0_255(encoded_red)
    # encoded_visual_green = normalize_dynamic_to_0_255(encoded_green)
    # encoded_visual_blue = normalize_dynamic_to_0_255(encoded_blue)

    decoded_visual_red = normalize_1_2_to_0_255(decoded_red)
    decoded_visual_green = normalize_1_2_to_0_255(decoded_green)
    decoded_visual_blue = normalize_1_2_to_0_255(decoded_blue)


    rgb_images = [
        (AaylaSecura_red, AaylaSecura_green, AaylaSecura_blue),
        (Anakin_red, Anakin_green, Anakin_blue),
        (KitFisto_red, KitFisto_green, KitFisto_blue),
        (MaceWindu_red, MaceWindu_green, MaceWindu_blue),
        (ObiWan_red, ObiWan_green, ObiWan_blue),
        (PloKoon_red, PloKoon_green, PloKoon_blue),
        (Yoda_red, Yoda_green, Yoda_blue),
        (random_red, random_green, random_blue)
    ]
    titles = [f"Batch Image {i+1}" for i in range(7)] + ["Noise Image"]
    display_images_color(rgb_images, width, height, titles)
    titles = [f"Batch Image {i+1} (RED)" for i in range(7)] + ["Noise Image (RED)"]
    display_images_channel(rgb_images, width, height, channel='r', titles=titles)
    titles = [f"Batch Image {i+1} (GREEN)" for i in range(7)] + ["Noise Image (GREEN)"]
    display_images_channel(rgb_images, width, height, channel='g', titles=titles)
    titles = [f"Batch Image {i+1} (BLUE)" for i in range(7)] + ["Noise Image (BLUE)"]
    display_images_channel(rgb_images, width, height, channel='b', titles=titles)

    encoded_images = [(encoded_red[0], encoded_green[0], encoded_blue[0]),
                      (encoded_red[1], encoded_green[1], encoded_blue[1]),
                      (encoded_red[2], encoded_green[2], encoded_blue[2]),
                      (encoded_red[3], encoded_green[3], encoded_blue[3]),
                      (encoded_red[4], encoded_green[4], encoded_blue[4]),
                      (encoded_red[5], encoded_green[5], encoded_blue[5]),
                      (encoded_red[6], encoded_green[6], encoded_blue[6]),
                      (encoded_red[7], encoded_green[7], encoded_blue[7])]

    decoded_images = [(decoded_red[0], decoded_green[0], decoded_blue[0]),
                      (decoded_red[1], decoded_green[1], decoded_blue[1]),
                      (decoded_red[2], decoded_green[2], decoded_blue[2]),
                      (decoded_red[3], decoded_green[3], decoded_blue[3]),
                      (decoded_red[4], decoded_green[4], decoded_blue[4]),
                      (decoded_red[5], decoded_green[5], decoded_blue[5]),
                      (decoded_red[6], decoded_green[6], decoded_blue[6]),
                      (decoded_red[7], decoded_green[7], decoded_blue[7])]

    encoded_images_visual = [
        (encoded_visual_red[0], encoded_visual_green[0], encoded_visual_blue[0]),
        (encoded_visual_red[1], encoded_visual_green[1], encoded_visual_blue[1]),
        (encoded_visual_red[2], encoded_visual_green[2], encoded_visual_blue[2]),
        (encoded_visual_red[3], encoded_visual_green[3], encoded_visual_blue[3]),
        (encoded_visual_red[4], encoded_visual_green[4], encoded_visual_blue[4]),
        (encoded_visual_red[5], encoded_visual_green[5], encoded_visual_blue[5]),
        (encoded_visual_red[6], encoded_visual_green[6], encoded_visual_blue[6]),
        (encoded_visual_red[7], encoded_visual_green[7], encoded_visual_blue[7])]
    titles = [f"Encoded Image {i+1}" for i in range(8)]
    display_images_color(encoded_images_visual, width, height, titles)

    decoded_images_visual = [
        (decoded_visual_red[0], decoded_visual_green[0], decoded_visual_blue[0]),
        (decoded_visual_red[1], decoded_visual_green[1], decoded_visual_blue[1]),
        (decoded_visual_red[2], decoded_visual_green[2], decoded_visual_blue[2]),
        (decoded_visual_red[3], decoded_visual_green[3], decoded_visual_blue[3]),
        (decoded_visual_red[4], decoded_visual_green[4], decoded_visual_blue[4]),
        (decoded_visual_red[5], decoded_visual_green[5], decoded_visual_blue[5]),
        (decoded_visual_red[6], decoded_visual_green[6], decoded_visual_blue[6]),
        (decoded_visual_red[7], decoded_visual_green[7], decoded_visual_blue[7])]
    titles = [f"Decoded Image {i+1}" for i in range(7)] + ["Decoded Noise Image"]
    display_images_color(decoded_images_visual, width, height, titles)

    print("Encoded Red:   min =", np.min(encoded_red),   ", max =", np.max(encoded_red),   ", abs min =", np.min(np.abs(encoded_red)))
    print("Encoded Green: min =", np.min(encoded_green), ", max =", np.max(encoded_green), ", abs min =", np.min(np.abs(encoded_green)))
    print("Encoded Blue:  min =", np.min(encoded_blue),  ", max =", np.max(encoded_blue),  ", abs min =", np.min(np.abs(encoded_blue)))
    print("Decoded Red:   min =", np.min(decoded_red),   ", max =", np.max(decoded_red),   ", abs min =", np.min(np.abs(decoded_red)))
    print("Decoded Green: min =", np.min(decoded_green), ", max =", np.max(decoded_green), ", abs min =", np.min(np.abs(decoded_green)))
    print("Decoded Blue:  min =", np.min(decoded_blue),  ", max =", np.max(decoded_blue),  ", abs min =", np.min(np.abs(decoded_blue)))


if __name__ == "__main__":
    # main_v1()
    main_v2()