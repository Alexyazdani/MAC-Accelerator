import numpy as np
import os
from PIL import Image
import random

def float_to_ieee754_16(f):                                               # Custom 16-bit with 10-bit Mantissa + 5 bit Exponent
    half = np.float16(f)
    return f"{half.view(np.uint16):04x}"

def ieee754_16_to_float(h):                                               # Custom 16-bit with 10-bit Mantissa + 5 bit Exponent     
    """Convert 16-bit IEEE-754 hex string to Python float."""
    import math
    bits = int(h, 16)
    sign = (bits >> 15) & 0x1
    exp = (bits >> 10) & 0x1F
    frac = bits & 0x3FF
    if exp == 0:
        if frac == 0:
            return -0.0 if sign else 0.0  # Signed zero
        else:
            return (-1)**sign * (frac / 2**10) * 2**(-14)
    elif exp == 0x1F:
        if frac == 0:
            return float('-inf') if sign else float('inf')
        else:
            return float('nan')
    else:
        return (-1)**sign * (1 + frac / 2**10) * 2**(exp - 15)

def denormalize_0_255_to_1_2(image):
    image = np.array(image, dtype=np.float32)
    return (image / 255) + 1

def generate_imem(image_size, batch_size, filename="imem.txt"):
    batch_ren = "0"
    scalar_ren = "0"
    wen = "0"
    reserved = "0000"
    scalar_addr = "000000"
    batch_addr = "000000000"
    instructions = []
    valid = "1"
    for w_addr in range(image_size * batch_size):
        scalar_base = (w_addr // image_size) * batch_size
        for image in range(batch_size):
            scalar_addr_val = scalar_base + image
            batch_addr_val = image * image_size + (w_addr % image_size)
            if image == batch_size - 1:
                wen = "1"
            else:
                wen = "0"
            scalar_addr = format(scalar_addr_val, "06b")
            batch_addr = format(batch_addr_val, "09b")
            waddr = format(w_addr, "09b")
            instruction = f"{batch_ren}{scalar_ren}{wen}{valid}{reserved}{waddr}{scalar_addr}{batch_addr}"
            instructions.append(instruction)
    mid = len(instructions) // 2
    first_half = instructions[:mid]
    second_half = instructions[mid:]
    instructions = [x for pair in zip(first_half, second_half) for x in pair]
    write_to_file(instructions, filename)
    return instructions

def write_to_file(instructions, filename):
    with open(filename, "w") as f:
        for i, instruction in enumerate(instructions):
            f.write(instruction + "\n")

def pad_zeros(instructions, imem_size):
    padding_needed = imem_size - len(instructions)
    if padding_needed > 0:
        instructions.extend(["00000000000000000000000000000000"] * padding_needed)
    return instructions

def repeat_to_fill(instructions, imem_size):
    if imem_size % len(instructions) != 0:
        return False
    repeat_count = imem_size // len(instructions)
    return instructions * repeat_count

def generate_batch(directory, image_size, batch_size, filename="dmem_batch.txt"):
    png_files = sorted([f for f in os.listdir(directory) if f.lower().endswith(".png")])
    if len(png_files) != batch_size:
        raise ValueError(f"Expected {batch_size} images, but found {len(png_files)} in {directory}.")
    floatsA = []
    test_batch = []
    for file in png_files:
        path = os.path.join(directory, file)
        image = Image.open(path).convert('L')
        pixels = list(image.getdata())
        floats = denormalize_0_255_to_1_2(pixels)
        floatsA.extend(floats)
    with open(filename, "w") as f:
        for i, val in enumerate(floatsA):
            if i % image_size == 0:
                test_batch.append(val)
            hex_val = float_to_ieee754_16(val)
            f.write(hex_val + "\n")

def generate_scalar(batch_size, filename="dmem_scalar.txt"):
    while True:
        floatsB = [x*random.choice([-1, 1]) for x in [random.uniform(0.5, 1.5) for _ in range(batch_size * batch_size)]]
        scalar_matrix = np.array(floatsB).reshape(8, 8)
        cond = np.linalg.cond(scalar_matrix)
        print("Condition number:", cond)
        if cond <= 20:
            break
    inverse_scalar_matrix = np.linalg.inv(scalar_matrix)
    test_scalar = []
    with open("dmem_scalar.txt", "w") as f:
        for i, val in enumerate(floatsB):
            if i < batch_size:
                test_scalar.append(val)
            hex_val = float_to_ieee754_16(val)
            f.write(hex_val + "\n")
    with open("dmem_scalar_inverse.txt", "w") as f:
        for row in inverse_scalar_matrix:
            for i, val in enumerate(row):
                hex_val = float_to_ieee754_16(val)
                f.write(hex_val)
                f.write("\n")
            f.write("\n")

def generate_binary(image_size, batch_size, imem_filename="imem.txt", batch_filename="dmem_batch.txt", scalar_filename="dmem_scalar.txt"):
    generate_imem(image_size, batch_size, filename=imem_filename)
    generate_batch("images8x8/art/", image_size, batch_size, filename=batch_filename)
    generate_scalar(batch_size, filename=scalar_filename)

def main():
    image_size = 64
    batch_size = 8
    generate_binary(image_size, batch_size)

if __name__ == "__main__":
    main()
