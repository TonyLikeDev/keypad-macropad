"""Usage: python read_diag.py COM3 [seconds]. Prints each distinct pin pair the first time it is seen, then a summary."""
import sys, time, serial

port, secs = sys.argv[1], float(sys.argv[2]) if len(sys.argv) > 2 else 120
seen = {}
end = time.time() + secs
with serial.Serial(port, 9600, timeout=0.5) as s:
    while time.time() < end:
        line = s.readline().decode(errors="replace").strip()
        if not line: continue
        if line not in seen: print("first seen:", line, flush=True)
        seen[line] = seen.get(line, 0) + 1
print("SUMMARY:", dict(sorted(seen.items())), flush=True)
