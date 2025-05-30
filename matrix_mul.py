import numpy as np

def normalize_1_10_to_0_255(image):
    image = np.array(image, dtype=np.float32)
    return (image - 1) * (255 / 9)

def denormalize_0_255_to_1_10(image):
    image = np.array(image, dtype=np.float32)
    return (image * 9 / 255) + 1

def normalize_4_120_to_0_255(image):
    image = np.array(image, dtype=np.float32)
    return (image - 4) * (255 / (120 - 4))

def denormalize_0_255_to_4_120(image):
    image = np.array(image, dtype=np.float32)
    return (image * (120 - 4) / 255) + 4

def normalize_1_2_to_0_255(image):
    image = np.array(image, dtype=np.float32)
    return (image - 1) * 255

def denormalize_0_255_to_1_2(image):
    image = np.array(image, dtype=np.float32)
    return (image / 255) + 1

# def normalize_08_304_to_0_255(image):
#     image = np.array(image, dtype=np.float32)
#     return (image - 0.8) * (255 / (30.4 - 0.8))

# def denormalize_0_255_to_08_304(image):
#     image = np.array(image, dtype=np.float32)
#     return (image * (30.4 - 0.8) / 255) + 0.8

def normalize_dynamic_to_0_255(image):
    image = np.array(image, dtype=np.float32)
    min_val = np.min(image)
    max_val = np.max(image)
    if max_val == min_val:
        return np.zeros_like(image)  # Avoid divide-by-zero
    return (image - min_val) * (255 / (max_val - min_val))

def normalize_encoded_to_0_255(image):
    image = np.array(image, dtype=np.float32)
    return (image + 24) * (255.0 / 48.0)
    # image = np.array(image, dtype=np.float32)
    # return (image - 4) * (255.0 / 20.0)



def main():

    rand_scalar = np.random.uniform(0.5, 1.5, size=(8, 8))
    inverse_scalar = np.linalg.inv(rand_scalar)
    batch = np.random.uniform(1, 10, (8, 64))
    encoded = rand_scalar @ batch
    decoded = inverse_scalar @ encoded

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


if __name__ == "__main__":
    main()