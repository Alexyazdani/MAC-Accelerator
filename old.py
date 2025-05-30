
# [31] [30] [29] [28] [27:24]     [23:15]     [14:9]      [8:0]
#  BR   SR   WE   V   RESERVED     WADDR      SCALAR      BATCH


def generate_imem_8x1(image_size, batch_size):
    batch_ren = "0"
    scalar_ren = "0"
    wen = "0"
    reserved = "0000000000"
    scalar_addr = "000000"
    batch_addr = "000000"
    instructions = []
    valid = "1"
    for w_addr in range(image_size * batch_size):
        scalar_base = (w_addr // batch_size) * image_size
        for pixel in range(image_size):
            scalar_addr_val = scalar_base + pixel
            batch_addr_val = pixel * image_size + (w_addr % image_size)
            if pixel == image_size - 1:
                wen = "1"
            else:
                wen = "0"
            scalar_addr = format(scalar_addr_val, "06b")
            batch_addr = format(batch_addr_val, "06b")
            waddr = format(w_addr, "06b")
            instruction = f"{batch_ren}{scalar_ren}{wen}{valid}{reserved}{waddr}{scalar_addr}{batch_addr}"
            instructions.append(instruction)
    mid = len(instructions) // 2
    first_half = instructions[:mid]
    second_half = instructions[mid:]
    instructions = [x for pair in zip(first_half, second_half) for x in pair]
    return instructions

# def write_to_file(instructions, filename):
#     batch_size = 8
#     image_size = 64
#     with open(filename, "w") as f:
#         j = 0
#         f.write(f"//Output Image {j}:\n")
#         for i, instruction in enumerate(instructions):
#             if i > 0 and i % (image_size*batch_size) == 0:
#                 j += 1
#                 f.write(f"\n//Output Image {j}:\n")
#             f.write(instruction + "\n")
#             if (i + 1) % batch_size == 0:
#                 f.write("\n")