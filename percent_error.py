import numpy as np

def float_to_ieee754_16(f):
    half = np.float16(f)
    return f"{half.view(np.uint16):04x}"

def ieee754_16_to_float(h):
    bits = int(h, 16)
    sign = (bits >> 15) & 0x1
    exp = (bits >> 10) & 0x1F
    frac = bits & 0x3FF
    if exp == 0:
        if frac == 0:
            return -0.0 if sign else 0.0
        else:
            return (-1)**sign * (frac / 2**10) * 2**(-14)
    elif exp == 0x1F:
        if frac == 0:
            return float('-inf') if sign else float('inf')
        else:
            return float('nan')
    else:
        return (-1)**sign * (1 + frac / 2**10) * 2**(exp - 15)

def percent_error(file1, file2):
    with open(file1, 'r') as f1, open(file2, 'r') as f2:
        hex_vals_1 = [line.strip() for line in f1.readlines()]
        hex_vals_2 = [line.strip() for line in f2.readlines()]

    total_error = 0.0
    min_error = float('inf')
    max_error = float('-inf')
    for val1, val2 in zip(hex_vals_1, hex_vals_2):
        float1 = ieee754_16_to_float(val1)
        float2 = ieee754_16_to_float(val2)
        abs_error = abs(float1 - float2)
        signed_error = float2 - float1
        rel_error = (abs_error / 9) * 100 if float1 != 0 else 0.0
        rel_signed_error = (signed_error / 9) * 100 if float1 != 0 else 0.0
        total_error += rel_error
        min_error = min(min_error, rel_signed_error)
        max_error = max(max_error, rel_signed_error)
        print(f"Value1: {float1:.6f}, Value2: {float2:.6f}, Error: {rel_error:.4f}%")

    avg_error = total_error / len(hex_vals_1)
    print(f"\nAverage Absolute Error: {avg_error:.6f}%")
    print(f"Minimum Signed Error: {min_error:.6f}%")
    print(f"Maximum Signed Error: {max_error:.6f}%\n\n")


def main():
    file1 = 'dmem_batch.txt'
    file2 = 'data_decoded.txt'
    percent_error(file1, file2)


if __name__ == "__main__":
    main()
