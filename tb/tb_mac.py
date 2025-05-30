import struct
import numpy as np
import random
import subprocess

def float_to_ieee754_32(f):
    return f"{struct.unpack('>I', struct.pack('>f', f))[0]:08x}"

def ieee754_32_to_float(h):
    return struct.unpack('>f', struct.pack('>I', int(h, 16)))[0]

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

# def float_to_ieee754_16(f):                                                 # BFloat16
#     bf16 = np.float32(f).view(np.uint32) >> 16
#     return f"{bf16:04x}"

# def ieee754_16_to_float(h):                                                 # BFloat16
#     bits = int(h, 16)
#     sign = (bits >> 15) & 0x1
#     exp  = (bits >> 7) & 0xFF
#     frac = bits & 0x7F
#     if exp == 0:
#         if frac == 0:
#             return -0.0 if sign else 0.0
#         else:
#             return (-1)**sign * (frac / 2**7) * 2**(-126)
#     elif exp == 0xFF:
#         if frac == 0:
#             return float('-inf') if sign else float('inf')
#         else:
#             return float('nan')
#     else:
#         return (-1)**sign * (1 + frac / 2**7) * 2**(exp - 127)


def generate_random_floats(n, max):
    magnitude = random.uniform(0, max)
    low = -abs(magnitude)
    high = abs(magnitude)
    """Generate n random floats between low and high."""
    return [random.uniform(low, high) for _ in range(n)]


def run_verilog_sim_mul():
    compile_cmd = "iverilog -o build/tb_b16fpmul.out src/b16fpmul.v tb/tb_b16fpmul.v".split()
    sim_cmd = "vvp build/tb_b16fpmul.out".split()
    try:
        # print("Compiling...")
        subprocess.run(compile_cmd, check=True)
        # print("Running simulation...")
        subprocess.run(sim_cmd, check=True)
        # print("Done!")
    except subprocess.CalledProcessError as e:
        print(e)     

def run_verilog_sim_add():
    compile_cmd = "iverilog -o build/tb_b16fpadd_pipe.out src/b16fpadd_pipe.v src/b16fpadd.v tb/tb_b16fpadd_pipe.v".split()
    sim_cmd = "vvp build/tb_b16fpadd_pipe.out".split()
    # compile_cmd = "iverilog -o build/tb_b16fpadd.out src/b16fpadd.v tb/tb_b16fpadd.v".split()
    # sim_cmd = "vvp build/tb_b16fpadd.out".split()
    try:
        # print("Compiling...")
        subprocess.run(compile_cmd, check=True)
        # print("Running simulation...")
        subprocess.run(sim_cmd, check=True)
        # print("Done!")
    except subprocess.CalledProcessError as e:
        print(e)    

def run_verilog_sim_mac():
    compile_cmd = "iverilog -o build/tb_b16fpmac.out src/b16fpmac.v src/b16fpmul.v src/b16fpadd.v tb/tb_b16fpmac.v".split()
    sim_cmd = "vvp build/tb_b16fpmac.out".split()
    try:
        # print("Compiling...")
        subprocess.run(compile_cmd, check=True)
        # print("Running simulation...")
        subprocess.run(sim_cmd, check=True)
        # print("Done!")
    except subprocess.CalledProcessError as e:
        print(e)   

def run_verilog_sim_pipeline():
    compile_cmd = "iverilog -o build/tb_fp_pipeline tb/tb_fp_pipeline.v src/fp_pipeline.v src/b16fpadd_pipe.v src/b16fpadd.v src/b16fpmul_pipe.v src/counter.v behav/datamem_behav.v behav/imem_behav.v".split()
    sim_cmd = "vvp build/tb_fp_pipeline".split()
    try:
        subprocess.run(compile_cmd, check=True)
        subprocess.run(sim_cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(e)        

def test_multiplier():
    print("Testing Multiplier...")
    num_values = 100
    floatsA = generate_random_floats(num_values, 1)
    floatsB = generate_random_floats(num_values, 1)
    # floatsA[99] = -0.000083
    # floatsB[99] = -0.042926
    with open("inputs/oprA_mul", "w") as f:
        for i, val in enumerate(floatsA):
            hex_val = float_to_ieee754_16(val)
            if i < len(floatsA) - 1:
                f.write(hex_val + "\n")
            else:
                f.write(hex_val)
    with open("inputs/oprB_mul", "w") as f:
        for i, val in enumerate(floatsB):
            hex_val = float_to_ieee754_16(val)
            if i < len(floatsB) - 1:
                f.write(hex_val + "\n")
            else:
                f.write(hex_val)    
    run_verilog_sim_mul()
    total_rel_error = 0.0
    with open("outputs/result_mul.out", "r") as f:
        result_hexes = [line.strip() for line in f.readlines()]
        for i, (a, b, hex_result) in enumerate(zip(floatsA, floatsB, result_hexes), 1):
            sim_result = ieee754_16_to_float(hex_result)
            expected = a * b
            abs_error = abs(expected - sim_result)
            rel_error_percent = (abs_error / abs(expected)) * 100 if expected != 0 else 0.0
            total_rel_error += rel_error_percent
            if rel_error_percent > 0.15:
                fail = "FAILURE"
            else:
                fail = ""
            print(f"Test {i:03d}: {a:12.6f} * {b:12.6f} = {expected:14.6f} (expected), {sim_result:14.6f} (simulated) | error = {rel_error_percent:6.4f}%   {fail}")
    avg_error = total_rel_error / len(result_hexes)
    print(f"Average Relative Error for Multiplication: {avg_error:.6f}%\n")

    a_bin = f"{int(float_to_ieee754_16(floatsA[99]), 16):016b}"
    b_bin = f"{int(float_to_ieee754_16(floatsB[99]), 16):016b}"
    res_bin = f"{int(result_hexes[99], 16):016b}"

    print("\nBinary Breakdown (Test 100):")
    print(f"floatsA[99] = {floatsA[99]} -> {a_bin}")
    print(f"floatsB[99] = {floatsB[99]} -> {b_bin}")
    print(f"Result[99]  = {result_hexes[99]} -> {res_bin}\n")

def test_adder():
    print("Testing Adder...")
    num_values = 100
    floatsA = generate_random_floats(num_values, 256)
    floatsB = generate_random_floats(num_values, 256)
    with open("inputs/oprA_add", "w") as f:
        for i, val in enumerate(floatsA):
            hex_val = float_to_ieee754_16(val)
            if i < len(floatsA) - 1:
                f.write(hex_val + "\n")
            else:
                f.write(hex_val)

    with open("inputs/oprB_add", "w") as f:
        for i, val in enumerate(floatsB):
            hex_val = float_to_ieee754_16(val)
            if i < len(floatsB) - 1:
                f.write(hex_val + "\n")
            else:
                f.write(hex_val)    
    run_verilog_sim_add()
    total_rel_error = 0.0
    with open("outputs/result_add.out", "r") as f:
        result_hexes = [line.strip() for line in f.readlines()]
        for i, (a, b, hex_result) in enumerate(zip(floatsA, floatsB, result_hexes), 1):
            sim_result = ieee754_16_to_float(hex_result)
            expected = a + b
            abs_error = abs(expected - sim_result)
            rel_error_percent = (abs_error / abs(expected)) * 100 if expected != 0 else 0.0
            total_rel_error += rel_error_percent
            if rel_error_percent > 1:
                fail = "FAILURE"
            else:
                fail = ""
            print(f"Test {i:03d}: {a:12.6f} + {b:12.6f} = {expected:14.6f} (expected), {sim_result:14.6f} (simulated) | error = {rel_error_percent:6.4f}%   {fail}")
    avg_error = total_rel_error / len(result_hexes)
    print(f"Average Relative Error for Addition: {avg_error:.6f}%\n\n")

def generate_random_floats_pipe(n, min, max):
    return [random.uniform(min, max) for _ in range(n)]

def test_mac():
    expected_floats = []
    result_floats = []
    print("Testing MAC...")
    for _ in range(10):
        num_values = 10
        floatsA = [abs(x) for x in generate_random_floats(num_values, 1)]
        floatsB = [abs(x) for x in generate_random_floats(num_values, 1)]
        # floatsA[0] = -0.000083
        # floatsB[0] = -0.042926
        with open("inputs/oprA_mac", "w") as f:
            for i, val in enumerate(floatsA):
                hex_val = float_to_ieee754_16(val)
                if i < len(floatsA) - 1:
                    f.write(hex_val + "\n")
                else:
                    f.write(hex_val)
        with open("inputs/oprB_mac", "w") as f:
            for i, val in enumerate(floatsB):
                hex_val = float_to_ieee754_16(val)
                if i < len(floatsB) - 1:
                    f.write(hex_val + "\n")
                else:
                    f.write(hex_val)    
        run_verilog_sim_mac()
        total_rel_error = 0.0
        expected_floats = []
        result_floats = []
        with open("outputs/result_mac.out", "r") as f:
            result_hexes = [line.strip() for line in f.readlines()]
            z = 0
            for i, (a, b, hex_result) in enumerate(zip(floatsA, floatsB, result_hexes), 1):
                sim_result = ieee754_16_to_float(hex_result)
                z_old = z
                z = a * b + z
                expected = z
                sim_result = ieee754_16_to_float(hex_result)
                expected_floats.append(expected)
                result_floats.append(sim_result)
                abs_error = abs(expected - sim_result)
                rel_error_percent = (abs_error / abs(expected)) * 100 if expected != 0 else 0.0
                total_rel_error += rel_error_percent
                if rel_error_percent > 5:
                    fail = "FAILURE"
                else:
                    fail = ""
                print(f"Test {i:03d}: ({a:12.6f} * {b:12.6f}) + {z_old:12.6f} = {expected:14.6f} (expected), {sim_result:14.6f} (simulated) | error = {rel_error_percent:6.4f}%   {fail}")
    avg_error = total_rel_error / len(result_hexes)
    squared_errors = [(a - b) ** 2 for a, b in zip(result_floats, expected_floats)]
    mse_error = np.mean(squared_errors)
    print(f"\nAverage Relative Error for MAC: {avg_error:.6f}%\n")
    print(f"MSE Error for MAC: {mse_error:.6f}\n\n")

def generate_test_vectors(num_values, max, filename):
    floatsA = [abs(x) for x in generate_random_floats(num_values, max)]
    with open(filename, "w") as f:
        for i, val in enumerate(floatsA):
            hex_val = float_to_ieee754_16(val)
            if i < len(floatsA) - 1:
                f.write(hex_val + "\n")
            else:
                f.write(hex_val)

def test_pipeline():
    print("Testing FP PIPELINE...")
    batch_size = 8
    image_size = 64
    num_values_s = batch_size * batch_size
    num_values_b = batch_size * image_size
    # floatsA = [abs(x) for x in generate_random_floats(num_values, 10)]
    # floatsB = [abs(x) for x in generate_random_floats(num_values, 10)]
    floatsA = [x for x in [random.uniform(1, 2) for _ in range(num_values_b)]]
    # floatsB = [x for x in [random.uniform(0.5, 1.5) for _ in range(num_values)]]
    floatsB = [x*random.choice([-1, 1]) for x in [random.uniform(0.5, 1.5) for _ in range(num_values_s)]]
    scalar_matrix = np.array(floatsB).reshape(8, 8)



    with open("dmem_batch.txt") as f:
        floatsA = [ieee754_16_to_float(line.strip()) for line in f if line.strip()]

    with open("dmem_scalar.txt") as f:
        floatsB = [ieee754_16_to_float(line.strip()) for line in f if line.strip()]





    scalar_matrix = np.array(floatsB).reshape(8, 8)
    inverse_scalar_matrix = np.linalg.inv(scalar_matrix)
    test_batch = []
    test_scalar = []

    with open("dmem_batch.txt", "w") as f:
        print("Batch Floats:")
        for i, val in enumerate(floatsA):
            if i%image_size == 0:
                print(f"{i}: {val}")
                test_batch.append(val)
            hex_val = float_to_ieee754_16(val)
            if i < len(floatsA) - 1:
                f.write(hex_val + "\n")
            else:
                f.write(hex_val + "\n")
    with open("dmem_scalar.txt", "w") as f:
        print("Scalar Floats:")
        for i, val in enumerate(floatsB):
            if i < batch_size:
                print(f"{i}: {val}")
                test_scalar.append(val)
            hex_val = float_to_ieee754_16(val)
            if i < len(floatsB) - 1:
                f.write(hex_val + "\n")
            else:
                f.write(hex_val + "\n")   
    with open("dmem_scalar_inverse.txt", "w") as f:
        for row in inverse_scalar_matrix:
            for i, val in enumerate(row):
                hex_val = float_to_ieee754_16(val)
                f.write(hex_val)
                if i < len(row) - 1: 
                    f.write("\n")
            f.write("\n")

    results = []
    print("Results:")
    sum = 0
    for i in range(batch_size):
        prod = test_batch[i] * test_scalar[i]
        sum = sum + prod
        results.append(sum)
        print(results[i])

    run_verilog_sim_pipeline()
    total_rel_error = 0.0
    # expected_results = [0.0 for _ in range(image_size * batch_size)]
    # for row in range(8):
    #     for col in range(8):
    #         acc = 0.0
    #         for k in range(8):
    #             scalar_idx = row * 8 + k      # scalar matrix is 8x8, row major
    #             batch_idx = k * 8 + col       # batch matrix is transposed
    #             acc += floatsB[scalar_idx] * floatsA[batch_idx]
    #         expected_results[row * 8 + col] = acc
    expected_results = [0.0 for _ in range(batch_size * image_size)]
    for row in range(batch_size):             # 0..7
        for col in range(image_size):         # 0..63
            acc = 0.0
            for k in range(batch_size):       # 0..7
                scalar_idx = row * batch_size + k          # [row][k]
                batch_idx = k * image_size + col           # [k][col]
                acc += floatsB[scalar_idx] * floatsA[batch_idx]
                # if row == 0 and col == 0:
                #     print(f"scalar[{scalar_idx}] * batch[{batch_idx}] + acc = {floatsB[scalar_idx]} * {floatsA[batch_idx]} + acc = {acc}")
            expected_results[row * image_size + col] = acc
    with open("data_encoded.txt", "r") as f:
        result_hexes = [line.strip() for line in f.readlines()]
        for i, (expected, hex_val) in enumerate(zip(expected_results, result_hexes), 1):
            sim_result = ieee754_16_to_float(hex_val)
            abs_error = abs(expected - sim_result)
            rel_error_percent = (abs_error / abs(expected)) * 100 if expected != 0 else 0.0
            total_rel_error += rel_error_percent
            if rel_error_percent > 1:
                fail = "FAILURE"
            else:
                fail = ""
            print(f"Output {i}: {expected:.6f} (expected), {sim_result:.6f} (simulated) | error = {rel_error_percent:.4f}% {fail}")
        avg_error = total_rel_error / len(result_hexes)
        print(f"Average Relative Error for Pipeline: {avg_error:.6f}%\n\n")


def main():
    test_pipeline()

if __name__ == "__main__":
    main()
