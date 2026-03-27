import os, struct, subprocess, socket, time

def find_alephone_pid():
    for pid in os.listdir('/proc'):
        if not pid.isdigit():
            continue
        try:
            with open(f'/proc/{pid}/cmdline', 'rb') as f:
                cmd = f.read().decode('utf-8', errors='replace')
                if 'alephone' in cmd:
                    return int(pid)
        except:
            pass
    return None

def get_symbol_addr(binary, symbol):
    out = subprocess.check_output(["nm", binary]).decode()
    for line in out.splitlines():
        if symbol in line:
            return int(line.split()[0], 16)
    return None

def read_mem(pid, addr, size):
    with open(f"/proc/{pid}/mem", "rb") as f:
        f.seek(addr)
        return f.read(size)

def read_field(pid, dw_ptr_addr, offset, fmt):
    dw_ptr = struct.unpack("<Q", read_mem(pid, dw_ptr_addr, 8))[0]
    size = struct.calcsize(fmt)
    return struct.unpack(fmt, read_mem(pid, dw_ptr + offset, size))[0]

BINARY = "/home/aled/.local/share/Steam/steamapps/common/Classic Marathon/alephone"

pid = find_alephone_pid()
if not pid:
    print("alephone not running")
    exit(1)

sym_offset = get_symbol_addr(BINARY, "dynamic_world")
if not sym_offset:
    print("symbol not found")
    exit(1)

sock = socket.create_connection(("localhost", 16834))
print("Connected to LiveSplit Server")

prev_level = read_field(pid, sym_offset, 592, "<h")
prev_ticks = read_field(pid, sym_offset, 0, "<i")
has_started = False

print("Polling...")

while True:
    curr_level = read_field(pid, sym_offset, 592, "<h")
    curr_ticks = read_field(pid, sym_offset, 0, "<i")

    # start condition: ticks just went from 0 to positive
    if not has_started and prev_ticks == 0 and curr_ticks > 0:
        print("Game started, sending start")
        sock.sendall(b"startorsplit\r\n")
        has_started = True

    # split condition: level increased
    if has_started and curr_level > prev_level:
        print(f"Level {prev_level} -> {curr_level}, splitting")
        sock.sendall(b"split\r\n")

    # reset condition: ticks went back to 0 after starting
    if has_started and curr_ticks == 0 and prev_ticks > 0:
        print("Reset detected")
        sock.sendall(b"reset\r\n")
        has_started = False

    prev_level = curr_level
    prev_ticks = curr_ticks
    time.sleep(0.05)
